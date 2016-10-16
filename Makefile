CC=gcc
YFLAG=-d
PROGRAM=parser
OBJS=y.tab.o lex.yy.o
SRCS=y.tab.c lex.yy.c

all: $(PROGRAM)

.c.o: $(SRCS)
	$(CC) -c $*.c -o $@ -O

lex.yy.c: q2.l 
	flex q2.l

y.tab.c: q2.y
	yacc $(YFLAG) q2.y

parser: $(OBJS)
	$(CC) $(OBJS) -o $@ -lfl -lm

clean:
	rm -f $(OBJS) core *~ \#* *.o $(PROGRAM) lex.yy.* y.tab.*
