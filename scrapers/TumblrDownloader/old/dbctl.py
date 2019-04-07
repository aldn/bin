import sys
import os
import re
import time
from threading import Thread
import multiprocessing
import sqlite3

import socket
socket.setdefaulttimeout(5)

import httplib
from urllib2 import urlopen
from urlparse import urlparse
from urlparse import urljoin
import cStringIO
from io import StringIO
from BeautifulSoup import BeautifulSoup
from lxml import html
from lxml import etree
import Image
import hashlib
import base64

from PyQt4 import QtCore, QtGui
from PyQt4.QtGui import QMessageBox
from PyQt4.QtGui import QPixmap
from PyQt4.QtCore import SIGNAL, QObject

DB_FILE = 'Chicks.sqlite'





def isUrlAlive(site, path):
    conn = httplib.HTTPConnection(site)
    conn.request('HEAD', path)
    response = conn.getresponse()
    conn.close()
    return response.status == 200

def isImageWithinSizeThreshold(img):
    return img.size[0] >= 300 and img.size[1] >= 300


def downloadImage(URL, ignore_size_limit = False):
    try:
        data = urlopen(URL).read()
        file = cStringIO.StringIO(data)
        im = Image.open(file)
        if ignore_size_limit or isImageWithinSizeThreshold(im):
            return data
        else:
            return None
    except:
        return None

def endsWithImageFileExtension(url):
    return re.search('\.gif$|\.jpg$|\.jpeg$|\.png$', url) != None

    
    
# returns a tuple (image_url, image_data)
def getTumblrPostImage(source_url):
    m = re.match('^(.+)/post/(\d+)', source_url)
    if m:
        tumblr_site = m.group(1)
        post_id = m.group(2)
        image_page_url = tumblr_site + '/image/' + post_id
        try:
            doc = html.parse(image_page_url)
            image_url = doc.xpath ('//*[@id="image"]/@src')[0]
            #print '  tumblr image:', image_url
            return (image_url, urlopen(image_url).read())
        except:
            return None


        
def getAssociatedImageUrl(source_url):
    print source_url

    # check if we can download an image directly via the source URL
    img = downloadImage(source_url)
    if img:
        return [source_url]

    ch = urlopen(source_url).read(1)
    if ch != '<':
        return []

    
    list_images_urls =[]
    # interpret the source URL as a html page
    soup1 = BeautifulSoup(urlopen(source_url).read())
    #print soup1('img')
    for img_tag in soup1('img'):
        if img_tag.parent.name == 'a':
            print " >> <img> inside <a>!"
            #print '>>>', img_tag.parent.name, img_tag.parent['href']
            # try to find <a> tag parenting the <img> and follow it
            if endsWithImageFileExtension(img_tag.parent['href']):
                list_images_urls.append(urljoin(source_url,img_tag.parent['href']))
                print " >> using the direct link to image in <a>"
            elif urlparse(img_tag.parent['href']).netloc == urlparse(source_url).netloc and urlparse(img_tag.parent['href']).path != '/':
                # got a link to the page in the same domain as source
                # go one level deeper
                print 'parent href', img_tag.parent['href'], urlparse(img_tag.parent['href']).path
                soup2 = BeautifulSoup(urlopen(urljoin(source_url,img_tag.parent['href'])).read())
                for img_tag2 in soup2('img'):
                    im2 = downloadImage(urljoin(source_url,img_tag2['src']))
                    if im2:
                        list_images_urls.append(urljoin(source_url,img_tag2['src']))
                        print " >> using the link to image in the OTHER page linked in <A>", img_tag2['src']
            else:
                im = downloadImage(urljoin(source_url,img_tag['src']))
                if im:
                    list_images_urls.append(urljoin(source_url,img_tag['src']))

    if len(list_images_urls) == 0:
        return []
    elif len(list_images_urls) > 1:
        list_images_urls_filtered =[]
        for img_url in list_images_urls:
            msgBox = QMessageBox()
            msgBox.setText(img_url)
            msgBox.setInformativeText("Press Save to store found image, press Cancel to reject it.")
            msgBox.setStandardButtons(QMessageBox.Save | QMessageBox.Cancel)
            msgBox.setDefaultButton(QMessageBox.Cancel)
            pix = QPixmap()
            pix.loadFromData(urlopen(img_url).read())
            msgBox.setIconPixmap(pix)
            if msgBox.exec_() == QMessageBox.Save:
                list_images_urls_filtered.append(img_url)
    
        return list_images_urls_filtered
    else:
        return list_images_urls

        

def op1():
    conn = sqlite3.connect(DB_FILE)
    conn.execute('DELETE FROM ItemsTable WHERE Id > 603')
    conn.commit()
    conn.close()

def op2():
    print urljoin('http://www.my.site/path/test.html', '/test.html')


    
# fetch image data from image_url's and set image_file_large
def op4():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT ROWID,image_url FROM images WHERE image_file_large IS NULL ')
    for row in c.fetchall():
        print row[1], '...'
        data = urlopen(row[1]).read()
        conn.execute('UPDATE images SET image_file_large = ?  WHERE ROWID = ?', [sqlite3.Binary(data), row[0]] )
        conn.commit()
    conn.close()


def dbInit(filename):
    conn = sqlite3.connect(filename)
    conn.execute('CREATE TABLE files(id INTEGER PRIMARY KEY ASC, filename TEXT)')
    conn.execute('CREATE TABLE sources(source_url TEXT, file_id INTEGER, FOREIGN KEY(file_id) REFERENCES files(id) )')
    conn.commit()
    conn.close()
    
def dbAdd(conn, source_url, image_url, data, bcommit = True):
    c = conn.cursor()
    # check if we already have this data
    c.execute('SELECT COUNT(*) FROM ItemsTable WHERE SourceUrl = ? OR ImageUrl = ?', [source_url, image_url])
    count = c.fetchone()[0]
    # do not add the same data twice
    if count == 0:
        #print 'add' 
        #print '  source_url:        ', source_url
        #print '  image_url:         ', image_url
        #print '  data(bytes):       ', len(data)        
        conn.execute('INSERT INTO ItemsTable(SourceUrl,ImageUrl,ImageFileLarge) VALUES(?,?,?)' , [source_url, image_url, sqlite3.Binary(data)])
        if bcommit:
            conn.commit()
        return True
    return False

def dbSourceUrlExists(conn, source_url):
    c = conn.cursor()
    c.execute('SELECT COUNT(*) FROM ItemsTable WHERE SourceUrl = ? ', [source_url])
    count = c.fetchone()[0]
    return count > 0
    
def dbAddList(file):
    print 'ADD'
    f = open(file)
    conn = sqlite3.connect(DB_FILE)
    for src in f:
        src = src.rstrip()
        if 'http:' in src:
            imgs = getAssociatedImageUrl(src)
            print '    IMAGE URLs=', imgs
            for img in imgs:
                data = urlopen(img).read()
                dbAdd(conn, src, img, sqlite3.Binary(data))
    conn.close()
    f.close()
    
def dbAddGallery(URL):
    print 'ADD'
    conn = sqlite3.connect(DB_FILE)   
    imgs = getAssociatedImageUrl(URL)
    print '    IMAGE URLs=', imgs
    for img in imgs:
        data = urlopen(img).read()
        dbAdd(conn, URL, img, sqlite3.Binary(data))
    conn.close()
    

# add local image files
def dbAddDir(path):
    conn = sqlite3.connect(DB_FILE)
    for direntry in os.listdir(path):
        print direntry
        source_url = direntry
        image_url = direntry
        data = open(os.path.join(path,direntry), 'rb').read()
        dbAdd(conn, source_url, image_url, sqlite3.Binary(data))
    conn.close()
    

QUEUE_TERMINATION_TOKEN = 'poisonpill'
    
def tumblrPutQueue(url, q, crawlLimit, processName):
    try:
        max_items = [crawlLimit]
        conn = sqlite3.connect(DB_FILE)
        def addArchivePage(url):
            doc = html.parse(url)
            for elem in doc.iter('a'):
                if '/post/' in elem.attrib['href']:
                    sourceUrl = elem.attrib['href']
                    #if dbSourceUrlExists(conn, sourceUrl):
                    #    return
                    tup = getTumblrPostImage(sourceUrl)
                    if tup:
                        imageUrl = tup[0]
                        imageData = tup[1]
                        #print '%s: adding %s  qsize=%d' % (processName, sourceUrl, q.qsize())
                        q.put( (sourceUrl,imageUrl,imageData) )
                    if max_items[0] == 0:
                        return
                    max_items[0] = max_items[0] - 1
            for elem in doc.iter('div'):
                if 'id' in elem.attrib.keys() and elem.attrib['id'] == 'next_page':
                    for link in elem.iter('a'):
                        addArchivePage(urljoin(url, link.attrib['href']))       
        # start the crawler
        addArchivePage(url)
        conn.close()   
    except KeyboardInterrupt:
        print '%s: keyboard interrupt' % processName
    print processName + ' exited.'

def tumblrGetQueue(q):
    try:
        addCount = 0
        conn = sqlite3.connect(DB_FILE)
        lastTime = time.time()
        while True:
            qitem = q.get()
            if qitem == QUEUE_TERMINATION_TOKEN:
                break
            # unpack
            (sourceUrl,imageUrl,imageData) = qitem
            shouldCommitThisTime = False
            currentTime = time.time()
            if currentTime - lastTime > 10:
                lastTime = currentTime
                shouldCommitThisTime = True
            addResult = dbAdd(conn, sourceUrl, imageUrl, imageData, shouldCommitThisTime)
            if addResult:
                addCount = addCount + 1
            print '%s  %s (%d in queue)' % ( '+' if addResult else  '.', sourceUrl,  q.qsize())
        conn.commit()
        conn.close()
        print 'Added %d items to database.' % addCount
    except KeyboardInterrupt:
        print 'DB-Writer: keyboard interrupt'

def dbAddNewTumblrPosts(crawlLimit):
    print 'Will fetch up to %d items from each archive only' % crawlLimit
    haveBrokenBlogUrls = False
    blogfile = open('tumblr.txt', 'r')
    blogs = []
    if blogfile:
        for blog in blogfile:
            blogname = blog.rstrip() 
            if blogname != '':
                if False:#not isUrlAlive(blogname, ''):
                    print 'cannot load blog page:  %s' % blogname
                    haveBrokenBlogUrls = True
                blogs.append(blogname)
    blogfile.close()
    if haveBrokenBlogUrls:
        return
        

    q = multiprocessing.Queue()
    producerProcesses = []
    for blogIndex in range(len(blogs)):
        producerName = 'Downloader-' + str(blogIndex)
        process = multiprocessing.Process(target=tumblrPutQueue, name= producerName, args=(blogs[blogIndex], q, crawlLimit, producerName))
        process.start()
        producerProcesses.append(process)
    
    writerProcess = multiprocessing.Process(target=tumblrGetQueue, name= 'DB-Writer', args=(q,))
    writerProcess.start()

    #print "Now waiting for Downlaoder processes"
    #while True:
    #    activeProcessesSet = filter (lambda x: x.isActive() == True,  producerProcesses )
    #    if len(activeProcessesSet) == 0:
    #        break
    #    time.wait(0.1)
    for process in producerProcesses:
        process.join()
            

    # send terminator
    q.put(QUEUE_TERMINATION_TOKEN)
    print 'Now waiting for %s process' % writerProcess.name
    writerProcess.join()
    print 'All child processes exited.'
        
    

def dbQueryRandom():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT url FROM url_table ORDER BY RANDOM() LIMIT 1')
    print c.fetchone()[0]
    conn.close()

def dbQuery(index):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT url FROM url_table WHERE ROWID=%d' % index)
    result = c.fetchone()
    if result:
        print result[0]
    conn.close()

# rename ImageUrl to reduce collision
def dbRenameImageUrl(conn, id, beforeImageUrl):
    (original_path, filename) = os.path.split(beforeImageUrl)
    afterFilename = base64.urlsafe_b64encode(hashlib.md5(beforeImageUrl).digest()).replace('=', '') + '.jpg'
    
    #afterImageUrl = os.path.join(original_path, afterFilename)
    afterImageUrl = afterFilename
    
    print 'renamed ImageUrl:', original_path, ':', filename, '->', afterFilename
    conn.execute('UPDATE ItemsTable SET ImageUrl = ?  WHERE Id = ?', [afterImageUrl, id] )
    conn.commit()
    return afterFilename
    

def dbSaveImageFilesToDisk(save_path):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT ImageFileLarge,ImageUrl,Id FROM ItemsTable')
    while True:
        row = c.fetchone()
        if row == None:
            break
        print 'writing', row[1]
        (original_path, filename) = os.path.split(row[1])
        
        if os.path.exists(os.path.join(save_path, filename)):
            #filename = dbRenameImageUrl(conn, row[2], row[1])
            continue
            
        filehandle = open(os.path.join(save_path, filename), 'wb')           
        filehandle.write(row[0])
        filehandle.close()        
    conn.close()
    

# if ImageUrl contains invalid characters or is too long, replace it with image hash string
def dbFixInvalidImagePaths():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute('SELECT Id,ImageUrl FROM ItemsTable')
    for row in c.fetchall():
        beforeImageUrl = row[1]
        (original_path, filename) = os.path.split(beforeImageUrl)
        (dummy, extension) = os.path.splitext(filename)
        # check if path is invalid
        def containsInvalidCharacters(s):
            for c in s:
                if not c.isalnum() and c != '.' and  c != '-' and c != '_':
                    return True
            return False
        if len(filename) > 50 or containsInvalidCharacters(filename) or extension == '':
            dbRenameImageUrl(conn, row[0], beforeImageUrl)

    conn.close()
    

class ImageView(QtGui.QDialog):
    def OnAccept(self):
        self.accepted = True
        self.accept()

    def __init__(self, parent, image_url, image_data, prompt_mode = False):
        super(ImageView,self).__init__(parent)
        self.accepted = False
        
        imgview = QtGui.QLabel(self)
    #    if '.gif' in image_url:
    #        movie = QtGui.QMovie(image_data)
    #        movie.start()
    #        imgview.setMovie(movie)
    #    else:
        pixmap = QPixmap()
        pixmap.loadFromData(image_data)
        imgview.setPixmap(pixmap)
        textbox_url = QtGui.QLineEdit(self)
        textbox_url.setText(image_url)
        textbox_url.setReadOnly(True)
        
        if prompt_mode:
            ok_button = QtGui.QPushButton('ADD', self)
            self.connect(ok_button, SIGNAL("clicked()"), self.OnAccept)
        
        hbox = QtGui.QHBoxLayout()
        hbox.addWidget(textbox_url)
        if prompt_mode:
            hbox.addWidget(ok_button)
        vbox = QtGui.QVBoxLayout(self)
        vbox.addWidget(imgview)
        vbox.addLayout(hbox)
        self.setLayout(vbox)
        self.show()
        

    
def dbDisplay(row_id):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    if row_id == 0:
        c.execute('SELECT ImageFileLarge,SourceUrl,ImageUrl FROM ItemsTable ORDER BY RANDOM() LIMIT 1')
    else:
        c.execute('SELECT ImageFileLarge,SourceUrl,ImageUrl FROM ItemsTable WHERE Id = ?', [row_id])
    row = c.fetchone()
    if row == None:
        print 'error: no such item in the database.'
        return
    data = row[0]
    print row[1]
    print row[2]    
    conn.close()
    #
    widget = ImageView(None, row[1], data)
    widget.exec_()

    
    
def usage():
    print 'usage:'
    print sys.argv[0], 'AddUrlList FILE'
    print sys.argv[0], 'AddGallery URL'
    print sys.argv[0], 'AddTumblrArchive URL'
    print sys.argv[0], 'AddNewTumblrPosts'
    print sys.argv[0], 'AddLocalDir PATH'
    print sys.argv[0], 'Query [random | ID]'
    print sys.argv[0], 'Display [random | ID]'

    
def main():
    app = QtGui.QApplication(sys.argv)

    if len(sys.argv) < 2:
        quit()

    op = sys.argv[1]

    if op == 'AddUrlList' and len(sys.argv) > 2:
        dbAddList(sys.argv[2])
    elif op == 'AddGallery' and len(sys.argv) > 2:
        dbAddGallery(sys.argv[2])
    elif op == 'AddLocalDir' and len(sys.argv) > 2:
        dbAddDir(sys.argv[2])
    elif op == 'AddTumblrArchive' and len(sys.argv) > 2:
        dbAddTumblrArchive(sys.argv[2])
    elif op == 'SaveImageFilesToDisk' and len(sys.argv) > 2:
        dbSaveImageFilesToDisk(sys.argv[2])  
    elif op == 'FixInvalidImagePaths':
        dbFixInvalidImagePaths()
    elif op == 'AddNewTumblrPosts':
        crawlLimit = 100
        if len(sys.argv) > 2:
            crawlLimit = int(sys.argv[2])
        dbAddNewTumblrPosts(crawlLimit)
    elif op == 'Query' and len(sys.argv) > 2:
        if sys.argv[2] == 'random':
            dbQueryRandom()
        else:
            dbQuery(int(sys.argv[2]))
    elif op == 'Display' and len(sys.argv) > 2:
        if sys.argv[2] == 'random':
            dbDisplay(0)
        else:
            dbDisplay(int(sys.argv[2]))
    elif op == 'op1':
        op1()
    elif op == 'op2':
        op2()
    elif op == 'op3':
        op3()
    elif op == 'op4':
        op4()
    else:
        usage()
        
    
# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()

