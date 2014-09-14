# fpがなくなるまでoncycleを回すスクリプト
start=`date +%s`
i=1
fin="CONTINUE"
while [ $fin = "CONTINUE" ]
    do
        echo $i cycle
        
        # relabeling
        echo labeling
        t1=`date +%s`
        if test $i -eq 1; then
            python scripts/relabeling.py featured.comment 1/dic.dump > 1/label.comment
        else
            python scripts/relabeling.py `expr $i -1`/label.comment $i/dic.dump > $i/label.comment
        fi
        t2=`date +%s`
        echo labeling `expr $t2 - $t1`sec

        cd $i
        bash ../one_cycle.sh
        cd ..

        prei=$i
        i=`expr $i + 1`
        mkdir $i
        fin=`python scripts/add_fp_to_dic.py $prei/dic.dump $prei/fptn $i/dic.dump`
        echo $fin
    done

echo `expr $i -1` cycle
#rm -r $i

end=`date +%s`
echo all cycle `expr $end - $start`sec

