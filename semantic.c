/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#include "errors.h"
#include "lexeme.h"
#include "parser.tab.h"
#include "hash.h"
#include "ast.h"

// Etapa 4 - Análise Semântica

void checkUndefinedVariable(char *variableName, int lineNumber, int kind) {
    HASH_NODE *new_node;
    if ((new_node = hashFindVariable(variableName, kind)) == 0) {
        printf( "\nErro semantico! Linha %d: %s ( %s ) nunca declarada anteriormente.", lineNumber, kind, variableName );
        exit(ERR_UNDECLARED);
    }
}

void checkAlreadyDeclared(char *variableName, int lineNumber, int kind) {
    HASH_NODE *new_node;
    if ((new_node = hashFindVariable(variableName, kind)) != 0) {
        printf( "\nErro semantico! Linha %d: %s ( %s ) já declarada anteriormente.", lineNumber, kind, variableName );
        exit(ERR_DECLARED);
    }
}


// DEUS ME AJUDE KKKKRYING
// int checkArgs(char *nomeFuncao, int numeroParametros ) {

//     int numeroDeclaradoParametros = 0; //TO DOOOOOOOOOOOOOO

//     if ( numeroParametros < numeroDeclaradoParametros ) {
//         printSemanticError( "Faltam argumentos para a chamada da função!" );
//         return ERR_MISSING_ARGS;
//     }
//     if ( numeroParametros > numeroDeclaradoParametros ) {
//         printSemanticError( "Muitos argumentos para a chamada da função!" );
//         return ERR_EXCESS_ARGS;
//     }

//     // Beleza, tem o mesmo numero de argumentos, agora check dos tipos:
//     int todosOsTiposBatem = 0; // TO DO !!!
//     if ( todosOsTiposBatem ) {
//         printSemanticError( "Os tipos dos parametros não batem!" );
//         return ERR_WRONG_TYPE_ARGS;
//     }

//     return 0;
// }

void checkInput(char *variableName, int lineNumber) {
    HASH_NODE *procurado = hashFind(variableName);

    if ( procurado != NULL ) {
        if ( procurado->type != TK_PR_INT && procurado->type != TK_PR_FLOAT ) {
            printf( "\nErro semantico! Linha %d: Variavel ( %s ) deve ser do tipo int ou float, pois está retorna o comando input.", lineNumber, variableName );
            exit(ERR_WRONG_PAR_INPUT);
        }
    } else {
        printf( "Que que eu deveria fazer aqui? a variavel dada pro input não foi encontrada" );
    }
}
void checkOutput(char *variableName, int lineNumber) {
    HASH_NODE *procurado = hashFind(variableName);

    if ( procurado != NULL ) {
        if ( procurado->type != TK_PR_INT && procurado->type != TK_PR_FLOAT ) {
            printf( "\nErro semantico! Linha %d: Variavel ( %s ) deve ser do tipo int ou float, pois está retorna o comando output.", lineNumber, variableName );
            exit(ERR_WRONG_PAR_OUTPUT);
        }
    } else {
        printf( "Que que eu deveria fazer aqui? a variavel dada pro input não foi encontrada" );
    }
}

void checkShift(char *shiftNumber, int lineNumber) {
    if(atoi(shiftNumber) > 16) {
        printf( "\nErro semantico! Linha %d: O parâmetro de shift deve ser menor que 16, foi enviado: %s.", lineNumber, shiftNumber );
        exit(ERR_WRONG_PAR_SHIFT);
    }
}

// void printSemanticError(int lineNumber, char *identificador, char *natureza, char *maisExplicacoes ) {
//     printf( "\nErro semantico! Linha %d, Identificador %s, Natureza %s: %s.", lineNumber, identificador, natureza, maisExplicacoes );
// }

void printSemanticErrorInfo( char *maisExplicacoes ) {
    printf( "\nErro semantico! %s", maisExplicacoes );
}


int checkOperands(AST_NODE *node) {
    if(node == NULL) return;
    HASH_NODE *hashNode;

    if( node->lexeme->token_category != NULL ) {
        switch (node->lexeme->token_category) {
            // case (int)'+':
            // case (int)'-':
            // case (int)'*':
            // case (int)'/':
            // case (int)'%':
            case special_char:
                for(int operand = 0; operand < 2; operand++) {
                    // Operações binárias
                    AST_NODE *son = node->son[operand];
                    if((son->lexeme->token_category == (int)'+' ||
                        son->lexeme->token_category == (int)'-' ||
                        son->lexeme->token_category == (int)'*' ||
                        son->lexeme->token_category == (int)'/' ||
                        son->lexeme->token_category == (int)'%') ||
                        // Literais
                        (son->lexeme->token_category  == TK_LIT_INT  ||
                        son->lexeme->token_category  == TK_LIT_FLOAT ||
                        son->lexeme->token_category  == TK_LIT_TRUE  ||
                        son->lexeme->token_category  == TK_LIT_FALSE)) {
                            ;
                        }
                    else if (son->lexeme->token_category == identifier) {
                        HASH_NODE *tmp = hashFind(son->lexeme->literal_token_value_type.value.char_sequence);
                        if(tmp != NULL) {
                            if(tmp->type != TK_LIT_INT &&
                               tmp->type != TK_LIT_FLOAT &&
                               tmp->type != TK_LIT_TRUE  &&
                               tmp->type != TK_LIT_FALSE ) {
                                printf("\nErro semantico: Expressão não pode ser avaliada.");
                                // SERá QUE DEVERIA TER UM EXIT AQUI??
                            }
                        }
                    }
                }
                break;
            case identifier:
                hashNode = hashFind(node->lexeme->literal_token_value_type.value.char_sequence);
                if(hashNode != NULL) {
                    if(hashNode->kind == FUNCAO) {
                        printf("\nErro semantico! Linha %d: Função (%s) não pode ser utilizada como variável.", node->lexeme->line_number, node->lexeme->literal_token_value_type.value.char_sequence);
                        exit(ERR_FUNCTION);
                        // Etapa 4 - 2.3 - Uso correto de identificadores

                    } else if(hashNode->kind == VECTOR) {
                            printf("\nErro semantico! Linha %d: Vetor (%s) não pode ser utilizada como variável.", get_line_number(), node->lexeme->literal_token_value_type.value.char_sequence);
                            exit(ERR_VECTOR);
                        }
                    return hashNode->type;
                }
                break;
            case TK_LIT_INT:
                return TK_LIT_INT;
            case TK_LIT_CHAR:
                return TK_LIT_CHAR;
            case TK_PR_CHAR:
                return TK_PR_CHAR;
            case TK_LIT_STRING:
                return TK_LIT_STRING;
        }
    }
}

