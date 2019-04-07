#!/usr/bin/env python3
#
# A scraper for widespread types of image galleries.
# Downloads full size images by following links around.
#
# (c) 2018 Alexander Dunayevskyy <>
#

import os
import sys
import re
import urllib.request
import urllib.parse

re_pattern_htmldoc='[a-zA-Z0-9:_/.-]+?\.html'
re_pattern_img='[a-zA-Z0-9:_/.-]+?\.jpg'


main_doc_url = sys.argv[1]

def url_path(u):
	return re.match('(^.+)/.*$', u).group(1)

main_doc_url_path = url_path(main_doc_url)
print('main_doc_url_path', main_doc_url_path)

save_dir = urllib.parse.urlparse(main_doc_url).path.replace('/','-').replace('.html', '')
while save_dir[0]== '-':
	save_dir = save_dir[1:]
while save_dir[-1]== '-':
	save_dir = save_dir[:-1]	
print('save_dir', save_dir)

def fetch_by_url(u):
	f = urllib.request.urlopen(u)
	return str(f.read())

def fetch_by_url_bytes(u):
	f = urllib.request.urlopen(u)
	return f.read()

def make_url_absolute(u, base):
	m0 = re.match('^\./(.+$)', u)
	m1 = re.match('^http', u)
	if m0:
		return base + '/' + m0.group(1)
	elif m1:
		return u #already is an absolute URL
	else:
		return base + '/' + u

def create_save_dir():
	try:
		os.mkdir(save_dir)
	except:
		None

def save_images(urls):
	create_save_dir()
	os.chdir(save_dir)
	c = 1
	for u in urls:
		print('fetching image from:', u)
		img_data = fetch_by_url_bytes(u)
		img_file_name = 'img_%.2d.jpg'%(c)
		print('saving image:', img_file_name)
		with open(img_file_name, 'wb') as f:
			f.write(img_data)
		c = c + 1

###############################################################
#
# Let's parse some HTML with regexes!
# We must be quick before Zalgo comes to harvest our souls.
#
###############################################################


def fetch_gallery_1(main_doc_data):
	ms = re.finditer('href="({0}/)"'.format(re_pattern_img), main_doc_data)
	image_urls = []
	for m in ms:
		if m:
			img_url = m.group(1)
			img_url = make_url_absolute(img_url, main_doc_url_path)
			image_urls.append(img_url)
	save_images(image_urls)


def fetch_gallery_2(main_doc_data):
	image_urls = []

	ms = re.finditer('a href="({0})".+?img src="{1}".+?</a>'.format(re_pattern_htmldoc, re_pattern_img), main_doc_data)
	for m in ms:
		if m:
			aux_doc_url = m.group(1)
			aux_doc_url = make_url_absolute(aux_doc_url, main_doc_url_path)
			print("aux_doc_url", aux_doc_url)
			# fetch aux_doc
			aux_doc_data = fetch_by_url(aux_doc_url)
			aux_ms = re.finditer('img src="({0})"'.format(re_pattern_img), aux_doc_data)
			for aux_m in aux_ms:
				if aux_m:
					img_url = aux_m.group(1)
					img_url = make_url_absolute(img_url, url_path(aux_doc_url))
					print("img_url", img_url)
					image_urls.append(img_url)
	save_images(image_urls)
	



main_doc_data = fetch_by_url(main_doc_url)




# detect type of the gallery layout

#1. main document has <a> links to exact image data as follows:  <a href=http://url/file.jpg/" >
#2. main document has <a> links to other documents (one per image) which in turn contains direct <a> link to image data

gallery_type = 0

matches1 = re.findall('href="{0}/"'.format(re_pattern_img), main_doc_data)
if len(matches1) > 2:  # let's consider document a gallery if it contains more than two items with similar layout 
	gallery_type = 1
else:
	matches2 = re.findall('a href="{0}".+?img src="{1}".+?</a>'.format(re_pattern_htmldoc, re_pattern_img), main_doc_data)
	#print(len(matches2))
	if len(matches2) > 2:
		gallery_type = 2


if gallery_type == 0:
	print("error: unknown gallery type")
	quit()
else:
	print("detected gallery type : %d" %(gallery_type))

if gallery_type == 1:
	fetch_gallery_1(main_doc_data)
elif gallery_type == 2:
	fetch_gallery_2(main_doc_data)

with open('info.txt', "w") as f:
	f.write(main_doc_url)

