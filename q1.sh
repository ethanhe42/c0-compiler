rm a.out
flex q1.l
gcc lex.yy.c
folder="test"
for f in ${folder}/*.c ;
do
    echo "\n" analysing ${f}
    ./a.out ${f} | tee ${f}.lex.xml
done
