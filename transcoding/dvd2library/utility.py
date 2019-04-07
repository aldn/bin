
import sys
import os
import re

dvd_dir = 'W:/Video/Movies/dvd'

# convert 'A_MOVIE_NAME/titleNUMBER' to 'a movie name [NUMBER]'
# if onlyone == True  omit [NUMBER]
def transmogrify_name(name):
    matchobj = re.match('([A-Za-z0-9_]+)/title(\d\d)', name)
    if matchobj:
        title = matchobj.group(1).lower().replace('_',' ').title()
        files = os.listdir(dvd_dir + '/' + matchobj.group(1))
        onlyone = len(files) < 3
        if onlyone:
            return title
        else:
            return "%s [%s]" % (title, matchobj.group(2))

