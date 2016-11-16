# c-compiler
c compiler with lex and yacc


### q1

### q2
Note: There are 1 shift/reduce conflicts, correctly resolved by default:
  IF '(' expression ')' statement _ ELSE statement

Solve unary via %prec

Solve ++ with lexer INC_OP

union define tokens, pass yylval.str from lex to yacc

%option yylineno use linenon

yacc recursive $$ $1

### c0 tokens
	public enum TokenType 
	{
		//关键字
		IF,ELSE,WHILE,RETURN,VOID,INT, 
		//运算符 + - * /  =  <  <=  >  >=  !=  … 
		PLUS,MINUS,STAR,SLASH, LT,LTEQ,GT,GTEQ,EQ,NEQ,ASSIGN,
		//界符 ;  ,  (  )  [  ]  {  }  /*  */
		SEMI,COMMA,LPAREN,RPAREN,LSQUAR,RSQUAR,LBRACE,RBRACE,
		LCOMMENT,RCOMMENT,
		ID, 				//标识符
		NUMBER, 			//数字常量
『 ID→letter(letter|didit)* 
           NUMBER→digit digit * 
               letter→a|b|…|z|A|B|…|Z 
               digit→0|…|9  』
		NONTOKEN,ERROR,ENDFILE 	// 其它
	};


### c0 pattern
program→ { var-declaration | fun-declaration }
 var-declaration→ int ID { , ID }    
 fun-declaration→ ( int | void ) ID ( params ) compound-stmt
 params → int ID { , int ID } | void | empty
 compound-stmt→ { { var-declaration } { statement } }
 statement→ expression-stmt∣compound-stmt ∣if-stmt ∣while-stmt 
 |return-stmt 
 expression-stmt→ [ expression ] ; 
 if-stmt→ if( expression ) statement [ else statement ]
 while-stmt→ while( expression ) statement 
 return-stmt→ return [ expression ] ;
 expression→ ID = expression | simple-expression
 simple-expression→ additive-expression [ relop additive-expression ]
 relop → < | <= | > | >= | == | != 
 additive-expression→ term [( + | - ) term ]
 term→ factor [ ( * | / ) factor ]
factor→ ( expression )| ID | call | NUM
call→ ID( args ) 
args→ expression { , expression } | empty
ID →…	;参见C语言标识符定义
NUM →… ;参见C语言数的定义
