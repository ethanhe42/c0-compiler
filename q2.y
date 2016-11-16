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
};
void printNode(struct treeNode* node){
    printf("%s<Tree lineNo=%d nodeType=%s string=%s value=%s dataType=%s>\n", 
        indent,
        node->lineNo,
        node->nodeType,
        node->string,
        node->value, 
        node->dataType);
}

struct treeNode * newnode(char* nodeType, char* string, char* value, char* dataType, int lineNo, int Nchildren, ...){
    struct treeNode * node = (struct treeNode*) malloc(sizeof(struct treeNode));
    node->nodeType = nodeType;
    node->string = string;
    node->value = value;
    node->dataType = dataType;
    node->lineNo = lineNo;
    printNode(node);

    va_list ap;
    int i;
    va_start(ap, Nchildren);
    for (i=0;i<Nchildren;i++){
        printf("%s<Child>\n", indent);
        incIndent();
        printNode(va_arg(ap, struct treeNode *));
        decIndent();
        printf("%s</Child>\n", indent);
    }
    va_end(ap);
    printf("</Tree>\n");
    return node;
}
char* none = "none";
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

%type<ast> program external_declaration var_declaration init_declarator_list fun_declaration params_list expression declaration_specifiers compound_stmt

%start program
%%

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
    {$$=newnode("var_declaration", none, none, none, yylineno, 1, $2); }
    ;

init_declarator_list
    : ID {$$ = newnode("init_declarator_list", none, none, none, yylineno, 0); printf("ID %d", yylineno);}
    | ID ASSIGN expression {$$ = newnode("init_declarator_list", none, none, none, yylineno, 0);}
    | init_declarator_list COMMA ID {$$ = newnode("init_declarator_list", none, none, none, yylineno, 0);}
    ;

declarator
    : LPAREN RPAREN {printf("declarator->LPAREN RPAREN");}
    | LPAREN params RPAREN {printf("declarator->LPAREN params RPAREN\n");}
    ;

fun_declaration
    : declaration_specifiers ID declarator compound_stmt {$$=newnode(STR(fun_declaration), $2, none, $1, yylineno, 1, $4);}
    ;

declaration_specifiers
    : INT {$$="INT";}
    | VOID {$$="VOID";}
    ;

params_list
    : INT ID {printf("INT ID\n");}
    | params_list COMMA INT ID {printf("params_list COMMA INT ID\n");}

params
    : params_list {printf("params_list\n");}
    | VOID {printf("params->VOID\n");}
    ;
    
compound_stmt
    : LBRACE RBRACE {printf("compound_stmt->LBRACE RBRACE\n");}
    | LBRACE block_item_list RBRACE {printf("compound_stmt->LBRACE block_item_list RBRACE\n");}
    ;

block_item_list
    : block_item {printf("block_item_list->block_item\n");}
    | block_item_list block_item {printf("block_item_list->block_item_list block_item\n");}
    ;

block_item
    : var_declaration {printf("var_declaration\n");}
    | statement {printf("statement\n");}
    ;

statement
    : expression_stmt {printf("expression_stmt\n");}
    | compound_stmt {printf("init_declarator_list\n");}
    | if_stmt {printf("init_declarator_list\n");}
    | while_stmt {printf("init_declarator_list\n");}
    | return_stmt {printf("init_declarator_list\n");}
    ;

expression_stmt
    : SEMI {printf("init_declarator_list\n");}
    | expression SEMI {printf("init_declarator_list\n");}
    ;

if_stmt
    : IF LPAREN expression RPAREN statement ELSE statement {printf("init_declarator_list\n");}
    | IF LPAREN expression RPAREN statement {printf("init_declarator_list\n");}
    ;

while_stmt
    : WHILE LPAREN expression RPAREN statement {printf("init_declarator_list\n");}
    ;

return_stmt
    : RETURN SEMI {printf("init_declarator_list\n");}
    | RETURN expression SEMI {printf("init_declarator_list\n");}
    ;
    
expression
    : assignment_expression {printf("assignment_expression\n");}
    | simple_expression {printf("init_declarator_list\n");}
    ;

assignment_expression
    : ID ASSIGN expression {printf("assigment\n");}
    | unary_expression  {printf("unary_assigment\n");}    ;

unary_expression 
    : INC_OP ID
    | DEC_OP ID
    | postfix_expression
    ;

postfix_expression
    : ID INC_OP
    | ID DEC_OP
    ;

simple_expression
    : additive_expression {printf("init_declarator_list\n");}
    | additive_expression relop additive_expression {printf("init_declarator_list\n");}
    ;

relop 
    : LT {printf("init_declarator_list\n");}
    | LTEQ  {printf("init_declarator_list\n");}
    | GT {printf("init_declarator_list\n");}
    | GTEQ  {printf("init_declarator_list\n");}
    | EQ  {printf("init_declarator_list\n");}
    | NEQ  {printf("init_declarator_list\n");}
    ;

additive_expression
    : term {printf("init_declarator_list\n");}
    | additive_expression PLUS term {printf("init_declarator_list\n");}
    | additive_expression MINUS term {printf("init_declarator_list\n");}
    | PLUS additive_expression %prec STAR {printf("unary\n");}
    | MINUS additive_expression %prec STAR {printf("unary\n");}
    ;

term
    : factor {printf("init_declarator_list\n");}
    | term STAR factor {printf("init_declarator_list\n");}
    | term SLASH factor {printf("init_declarator_list\n");}
    ;

factor
    : LPAREN expression RPAREN {printf("init_declarator_list\n");}
    | ID {printf("init_declarator_list\n");}
    | call {printf("init_declarator_list\n");}
    | NUM {printf("init_declarator_list\n");}
    ;
    
call
    : ID LPAREN RPAREN {printf("init_declarator_list\n");}
    | ID LPAREN args RPAREN {printf("init_declarator_list\n");}
    ;

args
    : expression {printf("init_declarator_list\n");}
    | expression COMMA args {printf("init_declarator_list\n");}
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



