import sys
import pickle

#filenames
old_dic = sys.argv[1]
fptn = sys.argv[2]
new_dic = sys.argv[3]

mydic = pickle.load(open(old_dic))

fpFlag = False
isEmpty = True

for line in open(fptn):
    if line.strip() == "fp":
        fpFlag = True
        continue
    elif line.strip() == "fn":
        break
    elif line.strip() == "" or line.strip()=="tp":
        continue
    elif not fpFlag:
        continue
    isEmpty = False

    cl = line.strip().split(" ")[1]
    word = line.strip().split(" ")[0]

    mydic[cl].append(word)

pickle.dump(mydic, open(new_dic, "w"))

if isEmpty:
    print "FINISH"
else:
    print "CONTINUE"

