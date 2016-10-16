flex q1.l
gcc lex.yy.c
folder=test
cd ${folder}
for f in testparser.c testlex.c ; 
do
    echo "\n" ${f}
    ../a.out ${f} ;
done
