// exam.c : Defines the entry point for the console application.
//



#include <stdlib.h>
#include <stdio.h>
int lexverbose=0;
extern int yylex (void);
extern int yyparse (void);

int main(int argc, char* argv[])
{
	extern FILE *yyin;

	printf("Compiling...!\n");
	if((yyin=fopen("test/test.c","rt"))==NULL){
			perror("can not open file test.txt\n") ;
			exit(1);
		}
	if (yyparse()==1){
		fprintf(stderr,"parser error\n");
		exit(1);
	}
	printf("yyparse() completed successfully!\n");
	return 0;
}
