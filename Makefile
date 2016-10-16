CC=gcc
YFLAG=-d
PROGRAM=parser
OBJS=y.tab.o lex.yy.o lexer.o
SRCS=y.tab.c lex.yy.c lexer.cpp

all:
	$(PROGRAM)

.c.o: $(SRCS)
	$(CC) -c $*.c -o $@ -O

lex.yy.c: q2.l 
	flex q2.l

y.tab.c: q2.y
	yacc $(YFLAG) q2.y

parser: $(OBJS)
	$(CC) $(OBJS) -o $@ -lfl -lm

clean:
	rm -f $(OBJS) core *~ \#* *.o $(PROGRAM) y.* lex.yy.* calcparse.tab.*
