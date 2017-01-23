#!/usr/bin/env python
# title              :wordcount.py
# description        :Counts the frequency of all words in the input file, and listed the top 10 in descending order of occurrence.
#
# author             :Kevin Neufeld
# Assumptions        :English words; contractions, possession, hyphenated and complex strings like email addresses are considered one word.
# date               :20161227
# usage              :python wordcount.py -i [file]
# notes              :Resources:
#                       arguments       :https://pymotw.com/2/argparse/
#                       collections     :https://docs.python.org/2/library/collections.html
#                       file Exist      :http://pythoncentral.io/check-file-exists-in-directory-python/
#                       string format   :https://docs.python.org/2/library/string.html#formatstrings
#                       regex           :https://docs.python.org/2/library/re.html
#                       tokenize        :http://www.nltk.org/index.html not used, but out of interest.
# python_version     :2.7.10

import argparse
import os.path
import sys
import re
from collections import Counter

# Parse commandline arguments.
parser = argparse.ArgumentParser(description='Word Counter')

parser.add_argument('-i', '--input', action="store", dest="input_file", required=True)

cmdline_args = parser.parse_args()

# check if the file exists, and user has read permission;
if not os.path.isfile(cmdline_args.input_file):
    sys.exit("File {0} does exists".format(cmdline_args.input_file))

if not os.access(cmdline_args.input_file, os.R_OK):
    sys.exit("Access Error: Cannot read {0}.".format(cmdline_args.input_file))

#Splitting on space, to create initial list of words from file.
raw_word_list = file(cmdline_args.input_file, "r").read().lower().split()

cleanse_word_list = []

for word in raw_word_list:
    # remove common punctuation from beginning and end of each word
    # [\x80-\xff] are non-ASCII character ranges
    tmp = re.sub(r"(^([\']|[\x80-\xff]+))|([\.?!:;,\']$)|([\x80-\xff]+)$|\" ", '', word)
    cleanse_word_list.append(tmp)

ordered_words = Counter(cleanse_word_list).most_common(10)

out_format = '{0: <16}{1: >4}'

for key, value in ordered_words:
    print out_format.format(key,value)
