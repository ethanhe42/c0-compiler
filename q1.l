
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
WS  [ \t\v\n\f]

%option yylineno

%{  
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h>   
int yywrap(); 

void printToken(char* type){
    fprintf(yyout,"  <token line=\"%d\" type=\"%s\" string=\"%s\" />\n", yylineno, type,yytext);
}
static void comment(void);
%}
%%

"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"if"					{printToken("IF"); }
"else"					{printToken("ELSE");}
"while"					{printToken("WHILE");}
"return"					{printToken("RETURN");}
"void"					{printToken("VOID");}
"int"					{printToken("INT");}
"float"					{printToken("FLOAT");}

"++"				{printToken("INC_OP");} 
"--"				{printToken("DEC_OP");} 
"+"				{printToken("PLUS");}     
"-"				{printToken("MINUS");}     
"*"				{printToken("STAR");}     
"/"				{printToken("SLASH");}     
"<"				{printToken("LT");}     
"<="				{printToken("LTEQ");} 
">"				{printToken("GT");}     
">="				{printToken("GTEQ");} 
"=="				{printToken("EQ");} 
"!="				{printToken("NEQ");} 
"="				{printToken("ASSIGN");}     

("[")				{printToken("LSQUAR");}
("]")				{printToken("RSQUAR");}
("{")				{printToken("LBRACE");}
("}")				{printToken("RBRACE");}
";"				{printToken("SEMI");}
","				{printToken("COMMA");}
"("				{printToken("LPAREN");}
")"				{printToken("RPAREN");}

{L}{A}*					{printToken("ID");}
{D}+			{printToken("NUMBER");}


{WS}+					{}
.					{}


%%
#include<stdio.h>
int yywrap() {
    return 1;
}


static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    printf("unterminated comment");
    exit(-1);
}

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
printf("<?xml version=\"1.0\"?>\n<root>\n");
yylex();
printf("</root>\n");
return 0; 
} 

