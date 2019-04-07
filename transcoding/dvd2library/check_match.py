#!/usr/bin/python

# For each item in all subdirectories check if a file exists in current directory
# with a transmogrified name and sequential suffix.
#
# for example, if there is a directory "ALIENS_VS_PREDATOR_REQUIEM" with "title00.h264.mkv"
# check if a file "Aliens Vs Predator Requiem.mkv" exists in current directory
#
# Run from W:\Video\Movies\dvd

import sys
import os
import re
import utility

def main():
    for subdir in os.listdir(utility.dvd_dir):
        dvd_dir_movie_dir = utility.dvd_dir + '/' + subdir
        if os.path.isdir(dvd_dir_movie_dir):
            for file in os.listdir(dvd_dir_movie_dir):
                if re.search('h264.mkv', file):
                    source_path = subdir + '/' + file
                    target_file = utility.transmogrify_name(source_path) + '.mkv'
                    #print target_file
                    if os.path.exists(utility.dvd_dir + '/' + target_file):
                        print 'OK: ' + source_path + '  ->  ' + target_file
                    else:
                        print '!!: ' + source_path + '  ->  ' + target_file

# Standard boilerplate to call the main() function to begin the program.
if __name__ == '__main__':
    main()
