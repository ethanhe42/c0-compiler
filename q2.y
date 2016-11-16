%{

//#include "y.tab.h"
#include "ast.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

//typedef char* string;
//#define YYSTYPE string
#define STR(VAR) (#VAR)
#define release 1
#define MAXCHILD 10

extern void yyerror(const char *);  /* prints grammar violation message */
extern int yylex(void);
extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;

char* tab="  ";
char indent[100]="";

char* integer="INT";
char* none = "none";
char* assign = "=";

void incIndent(){
    strcat(indent, tab);
}
void decIndent(){
    int len = strlen(indent);
    indent[len-2]='\0';
}

struct treeNode{
    struct treeNode *child[MAXCHILD];
    char* nodeType;
    char* string;
    char* value;
    char* dataType;
    int lineNo;
    int Nchildren;
};
void printNode(struct treeNode* node){
    printf("%s<Tree lineNo=\"%d\" nodeType=\"%s\" string=\"%s\" value=\"%s\" dataType=\"%s\">\n", 
        indent,
        node->lineNo,
        node->nodeType,
        node->string,
        node->value, 
        node->dataType);
    int i;
    printf("%s<Child>\n", indent);
    incIndent();
    for (i=0;i<node->Nchildren;i++){
        printNode(node->child[i]);
    }
    decIndent();
    printf("%s</Child>\n", indent);
    printf("%s</Tree>\n", indent);
}

struct treeNode * newnode(char* nodeType, char* string, char* value, char* dataType, int lineNo, int Nchildren, ...){
    struct treeNode * node = (struct treeNode*) malloc(sizeof(struct treeNode));
    node->nodeType = nodeType;
    node->string = string;
    node->value = value;
    node->dataType = dataType;
    node->lineNo = lineNo;
    node->Nchildren = Nchildren;
    va_list ap;
    int i;
    va_start(ap, Nchildren);
    for (i=0;i<Nchildren;i++){
        node->child[i]=va_arg(ap, struct treeNode *);
    }
    va_end(ap);
    return node;
}
%}
%code requires {

}

%union {
    char* str;
    struct treeNode * ast;
}

%token IF ELSE WHILE RETURN VOID INT
%token INC_OP DEC_OP PLUS MINUS STAR SLASH  LT LTEQ GT GTEQ EQ NEQ ASSIGN  
%token SEMI COMMA LPAREN RPAREN LSQUAR RSQUAR LBRACE RBRACE LCOMMENT RCOMMENT 
%token <str> ID NUM 
%token LETTER DIGIT
%token NONTOKEN ERROR ENDFILE

%left PLUS MINUS
%left STAR SLASH

%type<ast> atree program external_declaration var_declaration init_declarator_list fun_declaration params_list compound_stmt declarator params block_item_list block_item factor call term additive_expression simple_expression unary_expression postfix_expression assignment_expression return_stmt while_stmt if_stmt expression statement args expression_stmt 
%type<str> relop declaration_specifiers 

%start atree
%%

atree:program {printNode($1);}

program 
    : external_declaration {$$=$1;}
    | program external_declaration {$$=newnode(STR(program), none, none, none, yylineno, 2, $1, $2); }
    ;

external_declaration
    : var_declaration {$$=$1;}
    | fun_declaration {$$=$1;}
    ;

var_declaration
    : declaration_specifiers init_declarator_list SEMI 
    {$$=newnode("var_declaration", none, none, $1, yylineno, 1, $2); }
    ;

init_declarator_list
    : ID {$$ = newnode("init_declarator_list", $1, none, none, yylineno, 0);}
    | ID ASSIGN expression {$$ = newnode("init_declarator_list", $1, none, none, yylineno, 1, $3);}
    | init_declarator_list COMMA ID {$$ = newnode("init_declarator_list", $3, none, none, yylineno, 1, $1);}
    ;

declarator
    : LPAREN RPAREN {$$ = newnode("declarator", none, none, none, yylineno, 0);}
    | LPAREN params RPAREN {$$ = newnode("declarator", none, none, none, yylineno, 1, $2);}
    ;

fun_declaration
    : declaration_specifiers ID declarator compound_stmt {$$=newnode(STR(fun_declaration), $2, none, $1, yylineno, 1, $4);}
    ;

declaration_specifiers
    : INT {$$=integer;}
    | VOID {$$="VOID";}
    ;

params_list
    : INT ID {$$ = newnode("params_list", $2, none, integer, yylineno, 0);}
    | params_list COMMA INT ID {$$ = newnode("params_list", $4, none, integer, yylineno, 1, $1);}

params
    : params_list {$$=$1;}
    | VOID {$$ = newnode("params", none, none, "VOID", yylineno, 0);}
    ;
    
compound_stmt
    : LBRACE RBRACE {$$ = newnode("compound_stmt", none, none, none, yylineno, 0);}
    | LBRACE block_item_list RBRACE {$$ = $2;}
    ;

block_item_list
    : block_item {$$ = $1;}
    | block_item_list block_item {$$ = newnode("block_item_list", none, none, none, yylineno, 2, $1, $2);}
    ;

block_item
    : var_declaration {$$=$1;}
    | statement {$$=$1;}
    ;

statement
    : expression_stmt {$$=$1;}
    | compound_stmt {$$=$1;}
    | if_stmt {$$=$1;}
    | while_stmt {$$=$1;}
    | return_stmt {$$=$1;}
    ;

expression_stmt
    : SEMI {$$ = newnode("expression_stmt", none, none, none, yylineno, 0);}
    | expression SEMI {$$=$1;}
    ;

if_stmt
    : IF LPAREN expression RPAREN statement ELSE statement {$$ = newnode("if_stmt", none, none, none, yylineno, 3, $3, $5, $7);}
    | IF LPAREN expression RPAREN statement {$$ = newnode("if_stmt", none, none, none, yylineno, 2, $3, $5);}
    ;

while_stmt
    : WHILE LPAREN expression RPAREN statement {$$ = newnode("while_stmt", none, none, none, yylineno, 2, $3, $5);}
    ;

return_stmt
    : RETURN SEMI {$$ = newnode("return_stmt", none, none, none, yylineno, 0);}
    | RETURN expression SEMI {$$ = newnode("return_stmt", none, none, none, yylineno, 1, $2);}
    ;
    
expression
    : assignment_expression {$$=$1;}
    | simple_expression {$$=$1;}
    ;

assignment_expression
    : ID ASSIGN expression {$$ = newnode("assignment_expression", $1, none, none, yylineno, 1, $3);}
    | unary_expression  {$$=$1;}    ;

unary_expression 
    : INC_OP ID {$$ = newnode("unary_expression", $2, none, "++", yylineno, 0);}
    | DEC_OP ID {$$ = newnode("unary_expression", $2, none, "--", yylineno, 0);}
    | postfix_expression {$$=$1;}
    ;

postfix_expression
    : ID INC_OP {$$ = newnode("postfix_expression", $1, none, "++", yylineno, 0);}
    | ID DEC_OP {$$ = newnode("postfix_expression", $1, none, "--", yylineno, 0);}
    ;

simple_expression
    : additive_expression {$$=$1;}
    | additive_expression relop additive_expression {$$ = newnode("simple_expression", none, none, $2, yylineno, 2, $1, $3);}
    ;

relop 
    : LT {$$ = "<";}
    | LTEQ  {$$ = "<=";}
    | GT    {$$ = ">";}
    | GTEQ  {$$ = ">=";}
    | EQ    {$$ = "==";}
    | NEQ   {$$ = "!=";}
    ;

additive_expression
    : term {$$=$1;}
    | additive_expression PLUS term {$$ = newnode("additive_expression", none, none, "+", yylineno, 2, $1, $3);}
    | additive_expression MINUS term {$$ = newnode("additive_expression", none, none, "-", yylineno, 2, $1, $3);}
    | PLUS additive_expression %prec STAR {$$ = newnode("additive_expression", none, none, "+", yylineno, 1, $2);}
    | MINUS additive_expression %prec STAR {$$ = newnode("additive_expression", none, none, "-", yylineno, 1, $2);}
    ;

term
    : factor {$$=$1;}
    | term STAR factor {$$ = newnode("term", none, none, "*", yylineno, 2, $1, $3);}
    | term SLASH factor {$$ = newnode("term", none, none, "/", yylineno, 2, $1, $3);}
    ;

factor
    : LPAREN expression RPAREN {$$=$2;}
    | ID {$$ = newnode("factor", $1, none, none, yylineno, 0);}
    | call {$$=$1;}
    | NUM {$$ = newnode("factor", none, $1, none, yylineno, 0);}
    ;
    
call
    : ID LPAREN RPAREN {$$ = newnode("call", $1, none, none, yylineno, 0);}
    | ID LPAREN args RPAREN {$$ = newnode("call", $1, none, none, yylineno, 1, $3);}
    ;

args
    : expression {$$=$1;}
    | expression COMMA args {$$ = newnode("args", none, none, none, yylineno, 2, $1, $3);}
    ;

%%
#include <stdio.h>
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
    printf("success open %s\n", argv[1]);
}
else
{
    printf("no input file\n");
    exit(1);
}
printf("<?xml version=\"1.0\"?>\n");
yyparse();  
return 0; 
} 

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "*** %s\n", s);
}



