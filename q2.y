%token IF ELSE WHILE RETURN VOID INT  
%token PLUS MINUS STAR SLASH  LT LTEQ GT GTEQ EQ NEQ ASSIGN  
%token SEMI COMMA LPAREN RPAREN LSQUAR RSQUAR LBRACE RBRACE LCOMMENT RCOMMENT 
%token ID NUM LETTER DIGIT
%token NONTOKEN ERROR ENDFILE

%start program
%%

program
    : external_declaration
    | program external_declaration
    ;

external_declaration
    : var_declaration 
    | fun_declaration
    ;

var_declaration
    : declaration_specifiers init_declarator_list {if ($1 == VOID) {yyerror();} }
    ;

init_declarator_list
    : ID
    | init_declarator_list COMMA ID
    ;

declarator
    : LPAREN RPAREN
    | LPAREN params RPAREN
    ;

fun_declaration
    : declaration_specifiers ID declarator compound_stmt
    ;

declaration_specifiers
    : INT
    | VOID
    ;

params_list
    : INT ID
    | params_list COMMA INT ID

params
    : params_list
    | VOID 
    ;
    
compound_stmt
    : LBRACE RBRACE
    | LBRACE block_item_list RBRACE
    ;

block_item_list
    : block_item 
    | block_item_list block_item
    ;

block_item
    : var_declaration
    | statement
    ;

statement
    : expression_stmt
    | compound_stmt
    | if_stmt 
    | while_stmt 
    | return_stmt 
    ;

expression_stmt
    : SEMI 
    | expression SEMI 
    ;

if_stmt
    : IF LPAREN expression RPAREN statement ELSE statement
    | IF LPAREN expression RPAREN statement
    ;

while_stmt
    : WHILE LPAREN expression RPAREN statement 
    ;

return_stmt
    : RETURN SEMI
    | RETURN expression SEMI
    ;
    
expression
    : ID ASSIGN expression 
    | simple_expression
    ;

simple_expression
    : additive_expression
    | additive_expression relop additive_expression
    ;

relop 
    : LT
    | LTEQ 
    | GT
    | GTEQ 
    | EQ 
    | NEQ 
    ;

additive_expression
    : term 
    | additive_expression PLUS term
    | additive_expression MINUS term
    ;

term
    : factor
    | term STAR factor
    | term SLASH factor
    ;

factor
    : LPAREN expression RPAREN
    | ID 
    | call 
    | NUM
    ;
    
call
    : ID LPAREN RPAREN 
    | ID LPAREN args RPAREN 
    ;

args
    : expression
    | expression COMMA args
    ;

%%
#include <stdio.h>
char *progname;

main(argc, argv)
int argc;
char** argv;
{
progname = argv[0];
yyparse();
return 0; 
}

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "*** %s\n", s);
}