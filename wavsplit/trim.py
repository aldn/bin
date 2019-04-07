# (C)  2012  Oleksandr Dunayevskyy <oleksandr.dunayevskyy@gmail.com>

import subprocess
import os

def RomanNum(n):
    a  = [ 'I', 'II', 'III', 'IV', 'V']
    if n >= 1 and n <= 5:
        return a[n-1]
    return 'E'

def StartSox(filename, index, params):
    fullparams = ['C:\sox\sox.exe',  filename, 'out/' + filename[:-4]+' '+RomanNum(index)+'.wav',  'trim' ] + params 
    subprocess.call(fullparams)
    #print fullparams

try:
    os.mkdir('out')
except:
    print

file = open('trim_list.txt', 'r')
for line in file:
    tokens = line.rstrip().split(';')
    wavfile = tokens[0]
    timetags = tokens[1:]

    timetags2 = []
    for i in timetags:
        timetags2.append('=' + i)
    timetags = timetags2

    timetags = ['00:00'] + timetags + ['-00:00']

    for i in range(len(timetags)-1):
        StartSox( wavfile, i, [timetags[i], timetags[i+1] ] )

file.close()
