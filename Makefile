etapa2: lex.yy.o main.o parser
	gcc -o etapa2 lex.yy.o main.o -lfl parser.tab.c parser.tab.h

lex.yy.c: parser
	flex scanner.l

main.o: main.c
	gcc -c main.c

parser:
	bison -d parser.y

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

clean:
	rm -rf lex.yy.c etapa2 etapa2.tgz main.o lex.yy.o parser.tab.c parser.tab.h

compress: clean
	tar cvzf etapa2.tgz main.c Makefile scanner.l parser.y
