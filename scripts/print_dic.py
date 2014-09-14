#coding:utf-8
import sys
import pickle

class_dict = pickle.load(open(sys.argv[1]))

count = 0
for c, wlist in class_dict.items():
    print
    print c, "\n------", len(wlist), "words in class-------"
    for w in sorted(wlist):
        count += 1
        print "\t", w
print "---------\nall words", count
