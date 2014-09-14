#!/usr/bin/python
#coding:utf-8
import sys
import pickle
from collections import defaultdict


class_dict = defaultdict(list)
class_dict.update(pickle.load(open(sys.argv[1])))
try:
    print "word"
    for line in iter(sys.stdin.readline, ""):
        word = line.strip()
        print "class"
        clas = raw_input().strip()
        if clas == "o":
            clas = "onomatopoeia"
        elif clas == "p":
            clas = "parts"
        elif clas == "s":
            clas = "system"

        print word, clas, "?"
        if raw_input().strip() == "y":
            if word in reduce(lambda x,y: x+y, class_dict.values()):
                print word+"is already in dict, skip"
            else:
                class_dict[clas].append(word)
        else:
            print "dont submit"
        print
        print "word"
except KeyboardInterrupt:
    pickle.dump(class_dict, open(sys.argv[1], "w"))
    print "\dump done"

