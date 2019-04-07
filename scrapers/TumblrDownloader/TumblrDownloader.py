import sys
import os
import os.path
import re
import time

import multiprocessing

import urllib.request
import urllib.parse

import lxml.html
# import lxml.etree

# define maximum number of concurrent downloads
WORKERS_COUNT = 1


def get_id(source_url):
    m = re.match('^(.+)/post/(\d+)', source_url)
    return m.group(2) if m else None


def fetch_post_single_image(source_url):
    # print(source_url, '1')
    stream = urllib.request.urlopen(source_url)
    # print(source_url, '2')
    doc = lxml.html.parse(stream)
    # print(source_url, '3')
    image_elements = doc.xpath('//*[@class="photo-wrapper-inner"]/img')
    if image_elements:
        image_url = image_elements[0].attrib['src']
        print(source_url, 'singe image:', image_url)
        return image_url
    else:
        print(source_url, 'is a multi-image')
        return None


def fetch_post_images(source_url):
    def get_photoset_iframe(id, source_url):
        stream = urllib.request.urlopen(source_url)
        doc = lxml.html.parse(stream)
        iframe_url = doc.xpath('//*[@id="photoset_iframe_%s"]'%id)[0].attrib['src']
        # print('iframe', iframe_url)
        return iframe_url

    def get_images(id, iframe_url):
        # print('iframe+', iframe_url)
        images = []
        stream = urllib.request.urlopen(iframe_url)
        doc = lxml.html.parse(stream)
        for elem in doc.xpath('//*[contains(@id,"photoset_link_%s")]'%id):
            # print('link', elem)
            if 'href' in elem.attrib.keys():
                images.append(elem.attrib['href'])
        # print('images', images)
        return images

    hostname = urllib.parse.urlparse(source_url)[1]
    id = get_id(source_url)
    iframe_url = get_photoset_iframe(id, source_url)
    images = get_images(id, 'http://' + hostname + iframe_url)
    return images

def write_image_file(url, subdir):
    # def get_basename(url):
    #     m = re.match('.+/([a-z0-9_]+)$', url)
    #     return m.group(1) if m else None
    def get_basename(url):
        return os.path.basename(url)

    # print('write_image_file', url, subdir)
    file_name = get_basename(url)
    # print('file_name', file_name)
    file_path = subdir + '/' + file_name
    # print('file path', file_path)
    if os.path.isfile(file_path):
        print('not overwriting existing file', file_path)
        return
    try:
        data = urllib.request.urlopen(url).read()
        h = open(file_path, "wb")
        h.write(data)
        h.close()
    except:
        print('!! failed to save ', url)

def source_url_task(source_url):
    print('post task', source_url)
    id = get_id(source_url)
    # first, try to detect a post with single image
    image_url = fetch_post_single_image(source_url)
    if image_url:
        print(source_url, ' [ ] ', image_url)
        write_image_file(image_url, '.')
    else:
        # this must be a post with multiple images
        image_urls = fetch_post_images(source_url)
        try:
            os.mkdir(id)
        except:
            None
        subdir = id
        i = 0
        for image_url in image_urls:
            print(source_url, ' [%d] '%(i), image_url)
            i = i + 1
            write_image_file(image_url, subdir)


def fetch_posts(url):
    dir_name = urllib.parse.urlparse(url)[1] #use host name as directory name
    try:
        os.mkdir(dir_name)
    except:
        print(dir_name, 'already exists, skipping creation')
    os.chdir(dir_name)
    task_pool = multiprocessing.Pool(WORKERS_COUNT)

    while True:
        stream = urllib.request.urlopen(url)
        doc = lxml.html.parse(stream)
        for elem in doc.iter('a'):
            if 'href' in elem.attrib.keys() and '/post/' in elem.attrib['href']:
                source_url = elem.attrib['href']
                # print('schedule task for fetching post', source_url)
                task_pool.apply_async(source_url_task, (source_url,))

        def get_next_url():
            for elem in doc.iter('div'):
                if 'id' in elem.attrib.keys() and elem.attrib['id'] == 'next_page':
                    for link in elem.iter('a'):
                        return urllib.parse.urljoin(url, link.attrib['href'])
        next_url = get_next_url()
        # print('next page url:', next_url)
        if next_url:
            url = next_url
        else:
            break

    task_pool.close()
    task_pool.join()


def main():
    if len(sys.argv) > 1:
        fetch_posts(sys.argv[1])
    else:
        print('usage: %s  http://blog.tumblr.com/archive' % sys.argv[0])


# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()
