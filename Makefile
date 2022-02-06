etapa1: lex.yy.o main.o
	gcc -o etapa1 lex.yy.o main.o -lfl

lex.yy.c: scanner.l
	flex scanner.l

main.o: main.c
	gcc -c main.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

clean:
	rm -rf lex.yy.c etapa1 etapa1.tgz main.o lex.yy.o

compress: clean
	tar cvzf etapa1.tgz main.c Makefile scanner.l tokens.h