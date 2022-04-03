/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#ifndef HASH_HEADER
#define HASH_HEADER

#include <stdio.h>
#include <string.h>

#define HASH_SIZE 1021

#define VARGLOBAL 57
#define VARLOCAL  58
#define FUNCAO    59
#define LITERAL   60
#define PARAM     61
#define VECTOR    62


typedef struct argument {
    char argName[1024];
} ARGUMENT;

typedef struct HASH_NODE {
    int lineNumber; // localizacao (linha e coluna, esta opcional)
    int kind; // natureza (literal, variavel, funcao, etc)
    int type; // tipo (qual o tipo de dado deste simbolo)
    int size; // tamanho (derivado do tipo e se vetor)
    ARGUMENT argument[1024]; // Nome dos argumentos de uma função
    int argumentType[1024]; // Tipo dos argumentos
    char *text; // dados do valor do token pelo yylval
    struct HASH_NODE *next;
} HASH_NODE;

void hashInit(void);
int hashAddres(char *text);
HASH_NODE *hashFind(char *text);
HASH_NODE *hashInsert(int lineNumber, int kind, int type, int size, char *text);
// Ainda não to usando:
// HASH_NODE *hashInsertFunc(int lineNumber, int kind, int type, int size, char *text, ARGUMENT argument[], int argumentType[]);
void hashPrint();

#endif
