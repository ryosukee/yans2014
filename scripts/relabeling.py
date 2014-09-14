#coding:utf-8
# 事前にラベル付されているファイルに対して、新しい辞書で追加された部分だけもう一度ラベリングし直す
# ラベリングは辞書内の単語の最長一致を優先に付ける。(e.g. 「リヤサスペンション」「サスペンション」ともに辞書にある場合は「リヤサスペンション」が優先して付けられる)
# mecab形式のファイルからラベル付して素性も付け直すのは、素性を付け直す部分が無駄、あと同じラベルを付け直すのも無駄
# IOB tagging、形態素の切れ目単位で辞書とマッチしてつける

import sys
import pickle

labeled = sys.argv[1]
dic = pickle.load(open(sys.argv[2]))

sent = list()
for line in open(labeled):
    if line.strip()=="":
        for starti in range(len(sent)):
            for endi in map(lambda x: x+1, range(len(sent))[::-1]):
                word = "".join(line.split(" ")[0] for line in sent[starti:endi])
                # pruning
                if word == "" or len(filter(lambda line: line.split(" ")[-1] != "O", sent[starti:endi]))!=0:
                    continue
                # relabeling
                for c in dic.keys():
                    if word in dic[c]:
                        sent[starti:endi] = map(lambda line: line+" I-"+c,  map(lambda line: " ".join(line.split(" ")[:-1]), sent[starti:endi]))
                        sent[starti] = " ".join(sent[starti].split(" ")[:-1]) + " B-"+c
        # output
        for line in sent:
            print line
        print

        sent = list()
        continue
        
    sent.append(" ".join(line.strip().split(" ")[:-1])+" O")

