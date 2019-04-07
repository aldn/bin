import sys
import csv
import PyRTF
import PyRTF.Elements
import PyRTF.Renderer
import PyRTF.document.section
import PyRTF.document.paragraph


#def open_rtf_file(name):
#    return open('%s.rtf' % name, 'w')


def encode_text(txt):
    return txt
    #return txt.encode('cp1251', 'replace')
    """Encode our text in codepage 1251."""
    #return txt
    #try:
    #    return txt.encode('cp1251','strict')
    #except:
    #    try:
    #        return txt.encode('cp1251','strict')
    #    except:
    #        return txt.encode('cp1251','replace')


def ljust_nbsp(s,width):
    n = width - len(s)
    s_res = s
    while n > 0:
        s_res += '&nbsp;'
        n = n - 1
    return s_res



class HtmlExporter:
    def __init__(self, name):
        self.f = open(name,'w')
        self._add_header()

    def __del__(self):
        self._add_footer()
        self.f.close()

    def _add_header(self):
        self._wr('<html>')
        self._wr('<head><style> body {font-family: Menlo,Andale Mono; font-size: 12}</style></head>')
        self._wr('<body>')

    def _add_footer(self):
        self._wr('</body></html>')

    def _wr(self,txt):
        self.f.write(txt)

    def add_entry(self, items):
        self._wr('<br/>')
        items2 =[]
        first = True
        for i in items:
            if 'http' in i:
                items2.append(self._enc_url(i))
            else:
                if first:
                    items2.append(ljust_nbsp(i,40))
                    first = False
                else:
                    items2.append(i)
        self._wr(' '.join(items2))

    def _enc_url(self,url):
        short_name = url
        if 'amazon' in url:       short_name = 'amzn'
        elif 'ebay' in url:       short_name = 'ebay'
        elif 'price.ua' in url:   short_name = 'priceua'
        elif 'hotline.ua' in url: short_name = 'hotline'
        elif '27.ua' in url:      short_name = '27ua'
        elif 'aliexpress' in url: short_name = 'ali'
        elif 'olx' in url:        short_name = 'olx'
        elif 'etsy' in url:       short_name = 'etsy'
        elif 'jysk' in url:       short_name = 'jysk'
        elif 'ikea' in url:       short_name = 'ikea'
        elif 'prom' in url:       short_name = 'prom'
        elif 'rozetka' in url:    short_name = 'roz'
        elif 'f.ua' in url:       short_name = 'fotos'
        elif 'roznica' in url:    short_name = 'roznica'
        elif 'lampa.kiev' in url: short_name = 'lampa'
        elif 'stevian' in url:    short_name = 'stevian'
        elif 'brille' in url:     short_name = 'brille'
        elif 'l-ua' in url:       short_name = 'liebherr'
        elif 'signal' in url:     short_name = 'signal'
        elif 'audiovideomir' in url:short_name = 'audiovideomir'
        elif 'jam.ua' in url:     short_name = 'jam.ua'
        elif 'foxtrot' in url:    short_name = 'foxtrot'


        return '<a href=\'%s\'>%s</a>'%(url,short_name)


with open(sys.argv[1]) as csvfile:
    r = csv.reader(csvfile, delimiter=';')

    # doc = PyRTF.Elements.Document()
    # #ss = doc.StyleSheet
    #section = PyRTF.document.section.Section()
    #doc.Sections.append(section)

    ex = HtmlExporter('output.html')


    for row in r:
        row_stripped = row
        while row_stripped[-1] == '':
            row_stripped.pop()

        #text = '  '.join(row_stripped)
        #p = PyRTF.document.paragraph.Paragraph()
        #p.append(encode_text(text))
        #section.append(p)
        ex.add_entry(row_stripped)

    #dr = PyRTF.Renderer.Renderer()
    #dr.Write(doc, open_rtf_file('output'))
