%{  
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h>   
int yywrap(); 
int lineno=1; 
%}   

delim [ \t]  
ws {delim}+    
letter [A-Za-z] 
digit [0-9]  
id {letter}({letter}|{digit})* 
number {digit}+  
error_id ({digit})+({letter})+ 
enter [ \n]  
spchar ("{"|"}"|"["|"]"|"("|")"|";"|"="|",") 
ariop ("+"|"-"|"*"|"/")  
relop ("<"|"<="|">"|">="|"=="|"!=") 
comment \/\*(\*[^/]|[^*])*\*\/
reswd (int|else|return|void|if|while|include)
 
%% 

{ws} {}  
{comment} {}  
{enter} {lineno++;}  
{reswd} {fprintf(yyout,"%d行\t关键字\t%s\n",lineno,yytext);} 
{spchar} {fprintf(yyout,"%d行\t标识符\t%s\n",lineno,yytext);} 
{id} {fprintf(yyout,"%d行\t保留字\t%s\n",lineno,yytext);} 
{number} {fprintf(yyout,"%d行\t数字\t%s\n",lineno,yytext);} 
{error_id} {fprintf(yyout,"%d行\t出错\t%s\n",lineno,yytext);} 
{ariop} {fprintf(yyout,"%d行\t左括号\t%s\n",lineno,yytext);} 
{relop} {fprintf(yyout,"%d行\t右括号\t%s\n",lineno,yytext);} 

%%

int yywrap() {return 1;}   

main(argc, argv)
int argc;
char** argv;
{
if (argc > 1)
{
    FILE *file;
    file = fopen(argv[1], "r");
    if (!file)
    {
        fprintf(stderr, "failed open");
        exit(1);
    }
    yyin=file;
}
yylex();  
return 0; 
} 