/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"

HASH_NODE *Table[HASH_SIZE];

void hashInit(void) {
    for(int i=0; i<HASH_SIZE; i++) Table[i]=NULL;
}

int hashAddress(char *text) {
    int address = 1;
    for(int i=0; i<strlen(text); i++) {
        address = (address * text[i]) % HASH_SIZE + 1;
    }
    return address - 1;
}

HASH_NODE *hashFind(char *text) {
    HASH_NODE *node;
    int address = hashAddress(text);
    for(node=Table[address]; node; node = node->next) {
        if (!strcmp(node->text, text)) return node;
    }
    return NULL;
}

HASH_NODE *hashFindVariable(char *text, int variableKind) {
    HASH_NODE *node;
    int address = hashAddress(text);
    for(node=Table[address]; node; node = node->next) {
        if (!strcmp(node->text, text) && node->kind == variableKind ) {
            return node;
        }
    }
    return NULL;
}

HASH_NODE *hashInsert(int lineNumber, int kind, int type, int size, char *text) {
    HASH_NODE *new_node;
    if ((new_node = hashFind(text))!=0) return NULL;

    int address = hashAddress(text);

    new_node = (HASH_NODE*) calloc(1, sizeof(HASH_NODE));
    new_node->lineNumber = lineNumber;
    new_node->kind = kind;
    new_node->type = type;
    new_node->size = size;
	new_node->text = (char*) calloc(strlen(text)+1, sizeof(char));
	strcpy(new_node->text, text);
	new_node->next = Table[address];
	Table[address] = new_node;

    return new_node;
}

HASH_NODE *hashInsertFunc(int lineNumber, int kind, int type, int size, char *text, ARGUMENT argument[], int argumentType[]) {
    HASH_NODE *new_node;
    if ((new_node = hashFind(text))!=0) return new_node;

    int address = hashAddress(text);

    new_node = (HASH_NODE*) calloc(1, sizeof(HASH_NODE));
    new_node->lineNumber = lineNumber;
    new_node->kind = kind;
    new_node->type = type;
    new_node->size = size;

    memcpy(new_node->argument, argument, sizeof(ARGUMENT) * 1024);
    memcpy(new_node->argumentType, argumentType, sizeof(ARGUMENT) * 1024);

	new_node->text = (char*) calloc(strlen(text)+1, sizeof(char));
	strcpy(new_node->text, text);
	new_node->next = Table[address];
	Table[address] = new_node;

    return new_node;
}

void hashPrint(void)
{
	HASH_NODE *node;
	for(int i=0; i<HASH_SIZE; i++)
		for(node=Table[i]; node; node = node->next)
			printf("[Table %d] has %s\n", i, Table[i]->text);
}