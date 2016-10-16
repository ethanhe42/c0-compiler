%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
WS  [ \t\v\n\f]

%{
#define ifprint 1
#define VAR2STR(VAR) (#VAR)

#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "y.tab.h"

extern void yyerror(const char *);  /* prints grammar violation message */

extern int sym_type(const char *);  /* returns type from symbol table */

#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

static void comment(void);
%}

%%
"/*"                                    { comment(); }
"//".*                                    { /* consume //-comment */ }

"if"					{ return(IF); }
"else"					{ return(ELSE); }
"while"					{ return(WHILE); }
"return"					{ return(RETURN); }
"void"					{ return(VOID); }
"int"					{ return(INT); }

"+"				{ return PLUS; }
"-"				{ return MINUS; }
"*"				{ return STAR; }
"/"				{ return SLASH; }
"<"				{ return LT; }
"<="				{ return LTEQ; }
">"				{ return GT; }
">="				{ return GTEQ; }
"=="				{ return EQ; }
"!="				{ return NEQ; }
"="				{ return ASSIGN; }

("["|"<:")				{ return LSQUAR; }
("]"|":>")				{ return RSQUAR; }
("{"|"<%")				{ return LBRACE; }
("}"|"%>")				{ return RBRACE; }
";"				{ return SEMI; }
","				{ return COMMA; }
"("				{ return LPAREN; }
")"				{ return RPAREN; }

{L}{A}*					{ return ID; }
{D}+			{ return I_CONSTANT; }


{WS}+					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
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
    yyerror("unterminated comment");
}
