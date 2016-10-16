lexer: lexer.cpp y.tab.c y.tab.h lex.yy.c 
	gcc -o lexer lexer.cpp y.tab.h lex.yy.c y.tab.c
clean:
	rm -f lexer
