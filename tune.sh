#!/bin/sh

cycle_name=$1
mkdir tune
cd ./tune

[ -e tests ] && rm -r tests
[ -e trains ] && rm -r trains
[ -e models ] && rm -r models
[ -e results ] && rm -r results
[ -e diffs ] && rm -r diffs
[ -e evaluations ] && rm -r evaluations

mkdir tests
mkdir trains
mkdir models
mkdir results
mkdir diffs
mkdir evaluations

# ここでファイル分けをする(ここ手動でもいいかも)
# まずは全体の文数のカウント
count=0
for i in `cut -d " " -f 1 ../onlyBI500/result`
    do
        count=`expr $count + $i`
    done
thresh=`expr $count / 10`
thresh=`expr $thresh \* 2`
count=0
line=0
# そしたら文を約8:2で分割できるファイルの区切りを探す
for i in `cut -d " " -f 1 ../onlyBI500/result`
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
for f in `cut -d " " -f 2 ../onlyBI500/result`
    do
        if test $count -gt $thresh
            then
                echo "train $f"
                cp ../onlyBI500/$f ./trains
        else 
            echo "test, $f"
            cp ../onlyBI500/$f ./tests
        fi
        count=`expr $count + 1`
    done
# 分割したtest, trainをそれぞれ結合する
cat ./tests/* > test.txt
cat ./trains/* > train.txt

# CRFにかける
for c in 0.01 0.1 1 10 100 1000
    do
        ts=`date +%s`
        #CRF
        t1=`date +%s`
        echo "-----------train $c-----------"
        #/home/r-miyazaki/CRF++-0.58/crf_learn -t -a MIRA -p4 -f 3 -c 4.0 template train.$c.temp models/model.$c
        /home/r-miyazaki/CRF++-0.58/crf_learn -t -p4 -f 3 -c $c /home/r-miyazaki/work/asakawa/ryosuke/CRF/template ./train.txt models/model.$c
        t2=`date +%s`
        echo `expr $t2 - $t1`sec
        t1=`date +%s`
        echo "-----------test $c-----------"
        /home/r-miyazaki/CRF++-0.58/crf_test -m models/model.$c ./test.txt > results/result.$c
        t2=`date +%s`
        echo `expr $t2 - $t1`sec
        t1=`date +%s`
        echo "-----------diff $c-----------"
        mkdir diffs/$c
        python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/diff.py results/result.$c > diffs/$c/diff
        python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/spl_diff.py diffs/$c/diff diffs/$c
        python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/get_tp.py results/result.$c > diffs/$c/tp
        python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/get_word_from_diff.py diffs/$c/fp > temp_fp
        python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/get_word_from_diff.py diffs/$c/tp > temp_tp
        python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/get_word_from_diff.py diffs/$c/fn > temp_fn
        echo -e "tp" > temp_tp2
        echo -e "\nfp" > temp_fp2
        echo -e "\nfn" > temp_fn2
        cat temp_tp2 temp_tp temp_fp2 temp_fp temp_fn2 temp_fn > diffs/$c/fptn
        rm temp_tp2 temp_tp temp_fp2 temp_fp temp_fn2 temp_fn

        t2=`date +%s`
        echo `expr $t2 - $t1`sec
        t1=`date +%s`
        echo "-----------grade $c-----------"
        #python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/grade.py results/result.$c ../dic_memo/dic_memo1.dump evaluations/eval.$c.dump diffs/$c> evaluations/eval.$c.txt
        perl ~/work/asakawa/ryosuke/CRF/scripts/conlleval.pl -d "\t" < results/result.$c > evaluations/eval.$c
        t2=`date +%s`
        echo `expr $t2 - $t1`sec
        tf=`date +%s`
        echo $c loop `expr $tf - $ts`sec
    done
#t1=`date +%s`
#echo "-------cross grade---------"
#python /home/r-miyazaki/work/asakawa/ryosuke/CRF/scripts/cross_grade.py evaluations/*.dump > evaluations/cross_evaluation
#t2=`date +%s`
#echo `expr $t2 - $t1`sec


