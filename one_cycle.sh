#!/bin/sh

ts=`date +%s`

# create only IB files
t1=`date +%s`

mkdir onlyBI
cd onlyBI
echo create BI nolimit file
python ../../scripts/get_BI_sent.py -1 ../label.comment > temp
python ../../scripts/sort_BI_sent.py temp > result
rm temp
cd ..

c=1000

# train
t1=`date +%s`
echo create train data
mkdir tests
mkdir trains

# ここでファイル分けをする
# まずは全体の文数のカウント
count=0
for i in `cut -d " " -f 1 ./onlyBI/result`
    do
        count=`expr $count + $i`
    done
thresh=`expr $count / 10`
thresh=`expr $thresh \* 2`
count=0
line=0
# そしたら文を約8:2で分割できるファイルの区切りを探す
for i in `cut -d " " -f 1 ./onlyBI/result`
    do
        if test $count -gt $thresh
            then
                break
        fi
        count=`expr $count + $i`
        line=`expr $line + 1`
    done
thresh=$line
count=0
# 10分割できるファイルの区切りでtrainとtestに分ける
for f in `cut -d " " -f 2 ./onlyBI/result`
    do
        if test $count -gt $thresh
            then
                echo "train $f"
                cp ./onlyBI/$f ./trains
        else 
            echo "test, $f"
            cp ./onlyBI/$f ./tests
        fi
        count=`expr $count + 1`
    done
# 分割したtest, trainをそれぞれ結合する
cat ./tests/* > test.temp
cat ./trains/* > train.txt

echo train
crf_learn -t -p4 -f 3 -c $c ../template ./train.txt model

t2=`date +%s`
echo train `expr $t2 - $t1`sec

# test
echo create test data
t1=`date +%s`
cat ./onlyBI/others test.temp > test.txt
rm test.temp
t2=`date +%s`
echo create test `expr $t2 - $t1`sec

echo test
t1=`date +%s`
crf_test -m model ./test.txt > result
t2=`date +%s`
echo test `expr $t2 - $t1`sec

echo diff
t1=`date +%s`
python ../scripts/diff.py result > diff
python ../scripts/spl_diff.py diff .
python ../scripts/get_tp.py result > tp
python ../scripts/get_word_from_diff.py fp > temp_fp
python ../scripts/get_word_from_diff.py tp > temp_tp
python ../scripts/get_word_from_diff.py fn > temp_fn
echo -e "tp" > temp_tp2
echo -e "\nfp" > temp_fp2
echo -e "\nfn" > temp_fn2
cat temp_tp2 temp_tp temp_fp2 temp_fp temp_fn2 temp_fn > fptn
rm temp_tp2 temp_tp temp_fp2 temp_fp temp_fn2 temp_fn
t2=`date +%s`
echo diff `expr $t2 - $t1`sec

echo grade
t1=`date +%s`
perl ../scripts/conlleval.pl -d "\t" < result > evaluation
t2=`date +%s`
echo grade `expr $t2 - $t1`sec

tf=`date +%s`
echo all `expr $tf - $ts`sec

