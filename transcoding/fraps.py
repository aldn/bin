
import sys
import os
import re
from subprocess import call


CRF = {
    'Terraria'      : 30,
    'SC2'           : 32,
    'GameClient'    : 26, # Neverwinter Online
    'Wow'           : 26,
	 'Gw2'           : 25,
    'Diablo III'    : 26,
    'bf3'           : 25,
    'bf4'           : 25,
    'TESV'          : 25,
    'chrome'        : 30
    }

defaultCRF = 25


def encAVC(input, crf):
    inputNoExt = os.path.splitext(input)[0]
    outputDir = 'encoded'
    try:
        os.mkdir(outputDir)
    except:
        None
    
    audio1 = os.path.join(outputDir, inputNoExt + ".raw")
    audio2 = os.path.join(outputDir, inputNoExt + ".wav")
    audio3 = os.path.join(outputDir, inputNoExt + ".m4a")
    video2 = os.path.join(outputDir, inputNoExt + "_video.mp4")
    output = os.path.join(outputDir, inputNoExt + ".mp4")

    call(['C:/videotools/mplayer/mplayer.exe',  '-dumpaudio',  '-dumpfile',  audio1, input])
    call(['C:/videotools/sox/sox.exe',  '-r', '44100',  '-e',  'signed',  '-b', '16',  '-c', '2', audio1, audio2])
    call(['C:/videotools/neroaac/NeroAacEnc.exe', '-q', '0.4', '-if', audio2, '-of', audio3])

    call(['C:/videotools/x264/x264.exe', 
        '--preset', 'slow', 
        '--crf', str(crf),
        '--output', video2, 
        input])

    call(['C:/videotools/GPAC/mp4box.exe', '-add',  video2+'#video',  '-add',  audio3+'#audio', output])

    os.remove(audio1)
    os.remove(audio2)
    os.remove(audio3)
    os.remove(video2)
    

def getCRF(item):
    for k,v in CRF.items():
        if k in item:
            return v
    return defaultCRF

def encode(item):
    crf = getCRF(item)
    print 'NOW PROCESSING (crf = %d)' % crf, item
    encAVC(item, crf)

def main():
    if len(sys.argv) < 2:
        for item in os.listdir('.'):
            if '.avi' in item:
                encode(item)
    else:
        encode(sys.argv[1])

# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()


