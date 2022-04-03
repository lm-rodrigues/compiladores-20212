etapa4: lex.yy.c parser objects.o
    gcc -g -w -o etapa4 lex.yy.o main.o lexeme.o ast.o -lfl parser.tab.c parser.tab.h semantic.o hash.o

lex.yy.c: scanner.l parser
    flex scanner.l

parser: parser.y
    bison -d parser.y

objects.o:
    gcc -c -w lex.yy.c parser.tab.c lexeme.c main.c ast.c semantic.c hash.c

clean:
    rm -rf lex.yy.c etapa4 etapa4.tgz main.o lex.yy.o parser.tab.c parser.tab.o parser.tab.h ast.o lexeme.o semantic.o hash.o

compress: clean
    tar cvzf etapa4.tgz main.c Makefile scanner.l parser.y lexeme.c lexeme.h ast.c ast.h semantic.c semantic.h hash.c hash.h errors.h