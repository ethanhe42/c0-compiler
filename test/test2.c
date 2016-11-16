int foo(int a,int b){
    return a+b;
}
void bar(int a){
    if (a==0){
        exit(-1);
    }
    else{
        exit(0);
    }
}
void main(){
    int yylineno;
    int t;
    int yytext;
    t = foo(3,4);
    bar(t);
}
