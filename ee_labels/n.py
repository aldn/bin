import os, sys

ht = open ('n1.html', 'w')

f = open('n.txt', 'r')

ht.write('<html><head><style>')
ht.write('\
body\
{\
	font-family: sans-serif;\
	font-size: 10pt;\
}\
#content\
{\
	display:block;\
	border-collapse:collapse;\
}\
.box\
{\
	display: block;\
	float: left;\
	border: solid #cccccc 1px;\
	width: 25mm; \
	height: 13mm; \
	margin: 0mm;\
	padding: 0mm;\
	margin:-1px 0 0 -1px;\
}\
.nominal\
{\
	display: inline-block;\
	font-weight: bold;\
	font-size: 160%;\
	text-align: center;\
	margin-top: 1mm;\
	width: 100%;\
}\
.group12\
{\
    width: 100%;\
    text-align: center;\
}\
')

ht.write('</style></head><body>')

ht.write('<div id=content></div>')

for line in f:
	tokens = line.split()
	if len(tokens) > 0:
		#print(tokens)
		ht.write('<div class=box>')
		ht.write('<div class=nominal>%s</div>' % ( tokens[0] ) )
		tokens = tokens[1:]
		ht.write('<div class=group12>%s</div>' % ( '&nbsp;&nbsp;'.join(tokens)))
		ht.write('</div>') # .box

ht.write('</body></html>')
ht.close()
f.close()
