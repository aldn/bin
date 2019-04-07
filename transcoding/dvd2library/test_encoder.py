#!/usr/bin/python

# encode short samples from the files using different x264 quality settings

import sys
import os
import re
import utility
import shutil
import subprocess

def process_title(src_movie_path, test_dir):
    subprocess.call('mencoder -ss 00:05:00.0 -endpos 00:00:20.0 -oac copy -ovc copy  -o %s %s' % (test_dir + '/sample1.mkv', src_movie_path))
    subprocess.call('mencoder -ss 00:20:00.0 -endpos 00:00:20.0 -oac copy -ovc copy  -o %s %s' % (test_dir + '/sample2.mkv', src_movie_path))
    subprocess.call('mencoder -ss 00:55:00.0 -endpos 00:00:20.0 -oac copy -ovc copy  -o %s %s' % (test_dir + '/sample3.mkv', src_movie_path))
    
    
    for sample_file_prefix in ['sample1', 'sample2', 'sample3']:
        sample_file = test_dir + '/' + sample_file_prefix + '.mkv'
        qualitylist = [19 ]
        for quality in qualitylist:
            subprocess.call('x264 --crf %d --preset veryslow --tune film -o %s %s' %(quality, test_dir + '/' + sample_file_prefix + '_crf' + str(quality) + '.mkv', sample_file) )

def remove_dir_recursive(path):
    if os.path.isdir(path):
        shutil.rmtree(path)

def main():
    if len(sys.argv) < 2:
        print 'usage: %s  DIR' % sys.argv[0]
        print '   DIR     root directory for the test'
        exit(1)
    test_root_dir = sys.argv[1]
    if not os.path.exists(test_root_dir):
        print 'error: test root does not exist'
        exit(1)
    new_root  = test_root_dir + '/encoder_test'
    remove_dir_recursive(new_root)
    print 'Creating %s' % new_root
    os.mkdir(new_root)
    test_root_dir = new_root
    
    for subdir in os.listdir(utility.dvd_dir):
        dvd_dir_movie_dir = utility.dvd_dir + '/' + subdir
        if os.path.isdir(dvd_dir_movie_dir):
            os.mkdir(test_root_dir + '/' + subdir)
            for file in os.listdir(dvd_dir_movie_dir):
                if re.match('title\d\d.mkv', file):
                    process_title(dvd_dir_movie_dir + '/' + file, test_root_dir + '/' + subdir)
                    break

# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()
