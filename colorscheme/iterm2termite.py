#!/usr/bin/env python3

# Converts iTerm color schemes to Termite color scheme
# (c) 2016 Oleksandr Dunayevskyy

# Usage: iterm2termite.py <SCHEME>.itermcolors
# Prints converted scheme to stdout.

import sys
import re
import xml.etree.ElementTree as ET


class Parser:
    def __init__(self):
        pass
    def add_colortable_entry(self,entry):
        self.current_entry = entry
        self.colortable[self.current_entry] = {}
    def parse(self):
        tree = ET.parse(sys.argv[1])
        root = tree.getroot()
        self.current_entry = None
        self.current_color_component = None
        self.colortable = {}
        for dict1 in root:
            if dict1.tag == 'dict':
                for child in dict1:
                    if child.tag == 'key':
                        m = re.search('Ansi (\d+) Color', child.text)
                        if m != None:
                            colorIndex = int(m.group(1))
                            self.add_colortable_entry('color%d'%(colorIndex))
                        elif child.text == 'Background Color':
                            self.add_colortable_entry('background')
                        elif child.text == 'Bold Color':
                            self.add_colortable_entry('foreground_bold')
                        elif child.text == 'Foreground Color':
                            self.add_colortable_entry('foreground')
                        elif child.text == 'Selection Color':
                            self.add_colortable_entry('highlight')
                        elif child.text == 'Cursor Color':
                            self.add_colortable_entry('cursor')
                        elif child.text == 'Cursor Text Color':
                            self.add_colortable_entry('cursor_foreground')
                        else:
                            self.current_entry = None
                    elif self.current_entry!= None and child.tag == 'dict':
                        for tag_color_comp in child:
                            if tag_color_comp.tag == 'key':
                                current_color_component = tag_color_comp.text
                            elif tag_color_comp.tag == 'real':
                                # print(tag_color_comp.text)
                                # print(self.current_entry)
                                # print(current_color_component)
                                self.colortable[self.current_entry][current_color_component]\
                                    = float(tag_color_comp.text)
parser = Parser()
parser.parse()

# print(parser.colortable)
def scale255(c):
    return int(c*255)
def format_color(entry):
    r = scale255(entry['Red Component'])
    g = scale255(entry['Green Component'])
    b = scale255(entry['Blue Component'])
    color = '#%.2x%.2x%.2x'%(r,g,b)
    return color

def emit_st():
    print('static const char *colorname[] = {')
    for i in range(0,16):
        entry = parser.colortable['color%d'%(i)]
        hexcolor = format_color(entry)
        print('    "%s",'%(hexcolor))
    print('    [255] = 0,')
    entry_cursor = parser.colortable['cursor']
    print('    "%s",'%(format_color(entry_cursor)))
    entry_bg = parser.colortable['background']
    print('    "%s",'%(format_color(entry_bg)))
    entry_fg = parser.colortable['foreground']
    print('    "%s",'%(format_color(entry_fg)))
    print('};')

def emit_termite():
    print('[colors]')
    def put_key(k):
        print('%s = %s'%(k,format_color(parser.colortable[k])))
    for i in range(0,16):
        put_key('color%d'%(i))
    put_key('background')
    put_key('foreground')
    put_key('foreground_bold')
    put_key('cursor')
    put_key('cursor_foreground')
    put_key('highlight')

emit_termite()

