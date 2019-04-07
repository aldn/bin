import sys
import os
from lxml import html

def getImageUrls(tag):
    url = 'http://joyreactor.cc/tag/%s'% tag
    doc = html.parse(url)
    print doc
    for elem in doc.iter('div'):
        print elem.attrib.keys()
        if 'class' in elem.attrib.keys():
            print 'class ' + elem.attrib['class']
        if 'class' in elem.attrib.keys() and 'postContainer' in elem.attrib['class']:
            for elem1 in elem.iter('div'):
                if 'class' in elem1.attrib.keys() and 'post_content' in elem1.attrib['class']:
                    for img in elem1.iter('img'):
                        print img.attrib['src']


def main():
    if len(sys.argv) < 2:
        print 'error: no tag specified'
        quit()
    op_tag = sys.argv[1]
    getImageUrls(op_tag)


# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()
