#!/usr/bin/env python
# -*- coding:utf-8 -*-

import difflib
import string
import sys

try:
    textfile1 = sys.argv[1]
    textfile2 = sys.argv[2]
except Exception:
    print("Error:" + str(e))
    print("Usage: xxxx.py filename1 filename2")
    sys.exit()


def readfile(filename):
    try:
        fileHandle = open(filename, 'r')
        text = fileHandle.read().splitlines()
        fileHandle.close()
        return text
    except IOError as error:
        print('Read file Error:' + str(error))
        sys.exit()


if textfile1 == "" or textfile2 == "":
    print("Usage:test.py filename1 filename2")
    sys.exit()

text1_lines = readfile(textfile1)
text2_lines = readfile(textfile2)

d = difflib.HtmlDiff()
print(d.make_file(text1_lines, text2_lines))
