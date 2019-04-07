import sys
import os
import re
import time
import ntpath
import httplib
import multiprocessing
from urllib2 import urlopen
from urlparse import urlparse
from urlparse import urljoin
from lxml import html
#from lxml import etree

WORKERS_COUNT = 20


# returns a tuple (image_url, image_data)
def getTumblrPostImage(source_url):
    m = re.match('^(.+)/post/(\d+)', source_url)
    if m:
        tumblr_site = m.group(1)
        post_id = m.group(2)
        image_page_url = tumblr_site + '/image/' + post_id
        try:
            doc = html.parse(image_page_url)
        except:
            #print 'error: doc failed to parse', image_page_url
            return None                   
        # check both <img> ids 'image' and 'content-image' to be sure
        def imageByXpath(id):
            return doc.xpath ('//*[@id="%s"]/@src' % id)[0]
        imageUrl = imageByXpath('content-image')
        #print 'imageUrl' , imageUrl
        return imageUrl

def pathLeaf(path):
    head, tail = ntpath.split(path)
    return tail or ntpath.basename(head)
    
    
def sourceUrlTask(sourceUrl,stopflag):
    #print 'UrlTask', sourceUrl
    imageUrl = getTumblrPostImage(sourceUrl)
    if imageUrl:
        imageFileName = sourceUrl.replace('http://', '').replace('post/','').replace('/', '_') + os.path.splitext(imageUrl)[1]
        if os.path.isfile(imageFileName):
            print imageFileName, '(exists)'
            stopflag.value = True
            return
        imageData = urlopen(imageUrl).read()
        try:
            print imageFileName
            imageFileHandle = open(imageFileName, "wb")
            imageFileHandle.write(imageData)
            imageFileHandle.close()
        except:
            print '!! failed to save ', imageUrl
    
def tumblrGetBlogUpdates(url):
    dirname = url.replace('http://', '').replace('/', '_')
    try:
        os.mkdir(dirname)
    except:
        print dirname, 'already exists, skipping creation'
    os.chdir(dirname)
    
    manager = multiprocessing.Manager()
    stopflag = manager.Value('b', False)
    taskpool = multiprocessing.Pool(WORKERS_COUNT)
    
    
    while True:
        try:
            doc = html.parse(url)
        except:
            break
        for elem in doc.iter('a'):
            if 'href' in elem.attrib.keys() and '/post/' in elem.attrib['href']:
                sourceUrl = elem.attrib['href']
                #print sourceUrl
                taskpool.apply_async(sourceUrlTask, args=(sourceUrl,stopflag))
                
        def getNextUrl():
            for elem in doc.iter('div'):
                if 'id' in elem.attrib.keys() and elem.attrib['id'] == 'next_page':                   
                    for link in elem.iter('a'):
                        return urljoin(url, link.attrib['href'])
        # if we have the stop flag, do not load the next page
        if stopflag.value:
            print 'stoppped the iterator'
            break
        nextUrl = getNextUrl()
        if nextUrl:
            url = nextUrl
        else:
            break

    taskpool.close()
    taskpool.join()
    
    os.chdir('..')

    
            
def main():
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

    for blogname in blogs:
        print blogname
        tumblrGetBlogUpdates(blogname)
    
# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()

