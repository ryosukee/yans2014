#!/usr/bin/python
#coding:utf-8
import sys

limit = int(sys.argv[1])
files = sys.argv[2:]
out_strs = dict()
count = dict()
nonlimitFlag = False 

if limit == -1:
    nonlimitFlag = True


for f in files:
    sent = str()
    fo_name = list()
    BFlag = False
    IFlag = False
    keyword = str()
    cl = str()

    for line in open(f):
        sent += line
        words = line.strip().split()

        # EOS
        if not words:
            if len(fo_name) != 1:
                open("others", "a").write(sent)
            else:
                c = fo_name[0][1]
                fo_name = fo_name[0][0]
                fo_name += ".txt"
                out_strs[fo_name] = out_strs.get(fo_name, str())
                if count.get(fo_name, (0,c))[0] != limit or nonlimitFlag:
                    out_strs[fo_name] += sent
                    count[fo_name] = (count.get(fo_name, (0,c))[0] + 1, c)
            fo_name = list() 
            sent = str()
            continue
        
        # label
        if words[-1][0] == "B" and not BFlag:
            BFlag = True
            keyword += words[0]
            cl = words[-1][2:]
        elif words[-1][0] == "I" and BFlag:
            BFlag = False
            IFlag = True
            keyword += words[0]
        elif words[-1][0] == "I" and IFlag:
            keyword += words[0]
        elif words[-1][0] == "B" and (BFlag or IFlag):
            BFlag = True
            IFlag = False
            fo_name.append((keyword,cl))
            keyword = words[0]
            cl = words[-1][2:]
        else:
            BFlag = False
            IFlag = False
            if keyword:
                fo_name.append((keyword,cl))
            keyword = str()

map(lambda x: open(x[0], "w").write(x[1]), out_strs.items())
map(lambda x:  sys.stdout.write(str(x[1][0])+" "+x[0]+" "+x[1][1]+"\n"), sorted(count.items(), key=lambda x: -x[1][0]))

