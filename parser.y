%{
    /* Integrantes - Grupo E:
    Giovanna Varriale Damian   - 00264850
    Leonardo Marques Rodrigues - 00213751
    */

    #include <stdio.h>

    #include "ast.h"
    #include "lexeme.h"

    #include "semantic.h"
    #include "errors.h"
    #include "hash.h"

    int get_line_number(void);

    int yylex(void);
    void yyerror (char const *s);

    extern AST_NODE *arvore;

    char *getTipo(int type);
    void insertReturnType(int type);
    void removeReturnType(int type);

    int pilhaDeRetornos[1024];
    int numberOfParams = 0;
    int indexPilhaDeRetorno = 0;
%}
%define parse.error verbose

%union {
    struct Lexeme *lexeme;
    struct AST_NODE *tree;
}

%token <lexeme> TK_IDENTIFICADOR

%token <lexeme> TK_LIT_TRUE
%token <lexeme> TK_LIT_FALSE
%token <lexeme> TK_LIT_CHAR
%token <lexeme> TK_LIT_STRING
%token <lexeme> TK_LIT_INT
%token <lexeme> TK_LIT_FLOAT

%token ',' ';' ':' '(' ')' '[' ']' '{' '}' '.'
%token <lexeme> '+' '-' '|' '*' '<' '>' '=' '!' '&' '%' '#' '^' '$' '/' '?'

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_PR_END
%token TK_PR_DEFAULT
%token <lexeme> TK_OC_LE
%token <lexeme> TK_OC_GE
%token <lexeme> TK_OC_EQ
%token <lexeme> TK_OC_NE
%token <lexeme> TK_OC_AND
%token <lexeme> TK_OC_OR
%token <lexeme> TK_OC_SL
%token <lexeme> TK_OC_SR
%token TOKEN_ERRO


%type <tree> programa
%type <tree> decList
%type <tree> dec
%type <tree> identificadorOuLiteral
%type <tree> identificador
%type <tree> declaracaoFuncao
%type <tree> comando
%type <tree> comandoSimples
%type <tree> declaracaoVariavelLocal
%type <tree> listaVar
%type <tree> atribuicao
%type <tree> chamadaFuncao
%type <tree> listaEntradas
%type <tree> entradaSeguinte
%type <tree> comandoShift
%type <tree> numero
%type <tree> fluxoControle
%type <tree> expressao
%type <tree> aritmeticas
%type <tree> operacoes
%type <tree> unarios
%type <tree> binarios
%type <tree> ternarios
%type <tree> variavelLocal
%type <tree> blocoComandos
%type <tree> operacoesEntrada
%type <tree> operacoesSaida
%type <tree> operacoesRetorno
%type <tree> declaracaoVariavelGlobal

// Precedencias:
%left '<' '>' TK_OC_EQ TK_OC_NE TK_OC_GE TK_OC_LE
%left '+' '-'
%left '*' '/'
%left '^' '|' '%' TK_OC_AND TK_OC_OR

%nonassoc ':'

%right '&' '#' '!' '?'

%%

// 3 - A Linguagem ;
programa:
      decList   { arvore = $1 ;}
      ;

decList:
      dec decList {
                  if( $2 == NULL ) {
                        $$ = $1;
                  }
                  if( $1 != NULL ) {
                        append_node( $1, $2 );
                        $$ = $1;
                  } else {
                        $$ = $2;
                  }
            }
    |             { $$ = NULL ;}
    ;

dec:
      declaracaoVariavelGlobal
    | declaracaoFuncao
    ;

// Definições que se repetem;
identificadorOuLiteral:
      TK_IDENTIFICADOR  { $$ = create_ast_leaf( no_type, $1 ) ;}
    | TK_LIT_TRUE       { $$ = create_ast_leaf( no_type, $1 ) ;}
    | TK_LIT_FALSE      { $$ = create_ast_leaf( no_type, $1 ) ;}
    | TK_LIT_CHAR       { $$ = create_ast_leaf( no_type, $1 ) ;}
    | TK_LIT_INT        { $$ = create_ast_leaf( no_type, $1 ) ;}
    | TK_LIT_FLOAT      { $$ = create_ast_leaf( no_type, $1 ) ;}
    | TK_LIT_STRING     { $$ = create_ast_leaf( no_type, $1 ) ;}
    ;

// Não cria nada na AST;
tipo:
      TK_PR_INT
    | TK_PR_FLOAT
    | TK_PR_CHAR
    | TK_PR_BOOL
    | TK_PR_STRING
    ;
opcionalStatic:
      TK_PR_STATIC
    |
    ;
opcionalConst:
      TK_PR_CONST
    |
    ;

numero:
      TK_LIT_INT { $$ = create_ast_leaf( no_type, $1 ); };


// Declaração de Variavel Global - Não entram na AST - Precisamos liberar o lexeme criado no scanner;
declaracaoVariavelGlobal:
      opcionalStatic TK_PR_INT TK_IDENTIFICADOR opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);

        // se não deu exit na checkAlreadyDeclared, significa que ainda não temos essa variavel,
        // então vamos inseri-la na nossa hash
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_INT, sizeof(int), $3->value->char_sequence);

        // abaixo é codigo que já constava na E3
        free_lexeme( $3 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_FLOAT TK_IDENTIFICADOR opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_FLOAT, sizeof(float), $3->value->char_sequence);

        free_lexeme( $3 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_CHAR TK_IDENTIFICADOR opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_CHAR, sizeof(float), $3->value->char_sequence);

        free_lexeme( $3 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_BOOL TK_IDENTIFICADOR opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_BOOL, sizeof(char), $3->value->char_sequence);

        free_lexeme( $3 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_STRING TK_IDENTIFICADOR opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_STRING, 89, $3->value->char_sequence);

        free_lexeme( $3 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_INT TK_IDENTIFICADOR '[' TK_LIT_INT ']' opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_STRING, 89, $3->value->char_sequence);

        free_lexeme( $3 );
        free_lexeme( $5 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_FLOAT TK_IDENTIFICADOR '[' TK_LIT_INT ']' opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_STRING, 89, $3->value->char_sequence);
        free_lexeme( $3 ); free_lexeme( $5 ); $$ = NULL;
    }
    | opcionalStatic TK_PR_BOOL TK_IDENTIFICADOR '[' TK_LIT_INT ']' opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_STRING, 89, $3->value->char_sequence);

        free_lexeme( $3 );
        free_lexeme( $5 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_CHAR TK_IDENTIFICADOR '[' TK_LIT_INT ']' opcionalListVarGlobal ';' {
        checkAlreadyDeclared($3->value->char_sequence, get_line_number(), VARGLOBAL);
        hashInsert(get_line_number(), VARGLOBAL, TK_PR_STRING, 89, $3->value->char_sequence);

        free_lexeme( $3 );
        free_lexeme( $5 );
        $$ = NULL;
    }
    | opcionalStatic TK_PR_STRING TK_IDENTIFICADOR '[' TK_LIT_INT ']' opcionalListVarGlobal ';' {
        printf( "\nErro semantico! Linha %d: O vetor global %s não pode ser do tipo string.", get_line_number(), $3->value->char_sequence);

        free_lexeme( $3 ); free_lexeme( $5 );

        exit(ERR_STRING_VECTOR);
        // Definido na 2.4 da Entrega 4
        }
    ;

opcionalListVarGlobal:
      ',' TK_IDENTIFICADOR opcionalListVarGlobal { free_lexeme( $2 ); }
    | ',' TK_IDENTIFICADOR '[' TK_LIT_INT ']' opcionalListVarGlobal { free_lexeme( $2 ); free_lexeme( $4 ); }
    |
    ;


declaracaoFuncao:
        opcionalStatic tipo TK_IDENTIFICADOR '(' parametros ')' blocoComandos {
            $$ = create_ast_node( no_type, $3, $7, NULL, NULL, NULL) ;}
      | opcionalStatic tipo TK_IDENTIFICADOR '(' ')' blocoComandos            {
            $$ = create_ast_node( no_type, $3, $6, NULL, NULL, NULL)  ;}
      ;


// Não entram na AST - Precisamos liberar o lexeme criado no scanner;
parametros:
        opcionalConst tipo TK_IDENTIFICADOR listaParametros { free_lexeme( $3 ); }
      ;
listaParametros:
        ',' parametros
      |
      ;


blocoComandos:
        '{' comando '}' { $$ = $2 ;}
      | '{' '}' { $$ = NULL; }
      ;

comando:
      comandoSimples ';' comando {
                  if ( $3 == NULL ) {
                        $$ = $1;
                  }
                  if( $1 != NULL  ) {
                        append_node( $1, $3 );
                        $$ = $1;
                  } else {
                        $$ = $3;
                  }
            }
    | comandoSimples ';' { $$ = $1; }
    ;


// Todos
comandoSimples:
      declaracaoVariavelLocal
    | atribuicao
    | fluxoControle
    | operacoesEntrada
    | operacoesSaida
    | operacoesRetorno
    | blocoComandos
    | chamadaFuncao
    | comandoShift
    ;


// Definições da seção 3.4;
declaracaoVariavelLocal:
      opcionalStatic opcionalConst tipo variavelLocal { $$ = $4; }
      ;

variavelLocal:
      TK_IDENTIFICADOR listaVar {
            free_lexeme( $1 );
            $$ = NULL;
      }
      | TK_IDENTIFICADOR TK_OC_LE identificadorOuLiteral listaVar {
            $$ = create_ast_node( var_initializer, $2,
                  create_ast_leaf( no_type, $1 ),
                  $3,
                  $4,
                  NULL
            );
      }
      ;

listaVar:
      ',' variavelLocal { $$ = $2; }
    |  { $$ = NULL; }
    ;


atribuicao:
      TK_IDENTIFICADOR '=' expressao {
        checkUndefinedVariable( $1->value->char_sequence, get_line_number(), VARGLOBAL);

        int expressionType = checkOperands($3);
        printf("[DEBUG] expressionType: %d", expressionType);

        HASH_NODE *hashNode = hashFind($1->value->char_sequence);
        char *tipoDefinidoNaVariavel = getTipo(hashNode->type);

        if(getTipo(expressionType) != tipoDefinidoNaVariavel) {
            if(tipoDefinidoNaVariavel == "char") {
                printf("\nErro semantico! Linha %d: Variaveis do tipo char não podem ser convertidos!", get_line_number());
                exit(ERR_CHAR_TO_X);
                // Definido na 2.4 da Entrega 4
            }
            if(tipoDefinidoNaVariavel == "string") {
                printf("\nErro semantico! Linha %d: Variaveis do tipo string não podem ser convertidos!", get_line_number());
                exit(ERR_STRING_TO_X);
                // Definido na 2.4 da Entrega 4
            }
        }

        HASH_NODE *teste = hashFind($1->rawValue);

        if(teste->kind == VECTOR) {
            printf("\nErro semantico! Linha %d: Vetor (%s) não pode ser utilizada como variavel.", get_line_number(), $1->rawValue);
            exit(ERR_VECTOR);
        }

        if(teste->kind == FUNCAO) {
            printf("\nErro semantico! Linha %d: Função (%s) não pode ser utilizada como variavel.", get_line_number(), $1->rawValue);
            exit(ERR_FUNCTION);
            // DEF: Etapa 4 - 2.3 - Uso correto de identificadores
        }



        $$ = create_ast_node( var_attribution, $2,
            create_ast_leaf(no_type, $1 ),
            $3,
            NULL,
            NULL);
    }
    | TK_IDENTIFICADOR '[' expressao ']' '=' expressao {
        $$ = create_ast_node( var_attribution, $5,
                create_ast_node( vec_index, NULL,
                      create_ast_leaf( no_type, $1 ),
                      $3,
                      NULL,
                      NULL),
                $6,
                NULL,
                NULL);
      }
    ;


operacoesEntrada:
      TK_PR_INPUT TK_IDENTIFICADOR { $$ = create_ast_node(cmd_input, NULL,
                  create_ast_leaf( no_type, $2 ),
                  NULL, NULL, NULL) ;}
      ;

operacoesSaida:
      TK_PR_OUTPUT identificadorOuLiteral { $$ = create_ast_node(cmd_output, NULL, $2, NULL, NULL, NULL) ;}
      ;


chamadaFuncao:
      TK_IDENTIFICADOR '(' listaEntradas ')' { $$ = create_ast_node(function_call, $1, $3, NULL, NULL, NULL) ;}
    ;

listaEntradas:
      expressao entradaSeguinte       { if( $2 != NULL  ) { append_node( $1, $2 ); }  $$ = $1;  ;}
    |                                 { $$ = NULL                                               ;}
    ;

entradaSeguinte:
      ',' listaEntradas { $$ = $2   ;}
    |                   { $$ = NULL ;}
    ;


identificador:
      TK_IDENTIFICADOR { $$ = create_ast_leaf(no_type, $1 ); }
    ;


comandoShift:
      identificador TK_OC_SR TK_LIT_INT {
        // TO DO: verificar se é com o -> mesmo
        checkShift($3->value->integer, get_line_number());
        $$ = create_ast_node(no_type, $2,
            $1,
            create_ast_leaf( no_type, $3 ),
            NULL,
            NULL );
    }
    | identificador TK_OC_SL TK_LIT_INT {
        // TO DO: verificar se é com o -> mesmo
        checkShift($3->value->integer, get_line_number());
        $$ = create_ast_node(no_type, $2,
                $1,
                create_ast_leaf( no_type, $3 ),
                NULL,
                NULL );
    }
    | identificador '[' expressao ']' TK_OC_SL TK_LIT_INT {
        // TO DO: verificar se é com o -> mesmo
        checkShift($3->value->integer, get_line_number());
        $$ = create_ast_node(no_type, $5,
                create_ast_node( vec_index, NULL,
                    $1,
                    create_ast_leaf( no_type, $3 ),
                    NULL,
                    NULL),
                $6,
                NULL,
                NULL );
    }
    | identificador '[' expressao ']' TK_OC_SR TK_LIT_INT {
        // TO DO: verificar se é com o -> mesmo
        checkShift($3->value->integer, get_line_number());
        $$ = create_ast_node(no_type, $5,
                create_ast_node( vec_index, NULL,
                    $1,
                    create_ast_leaf( no_type, $3 ),
                    NULL,
                    NULL),
                $6,
                NULL,
                NULL );
    }
    ;



operacoesRetorno:
      TK_PR_RETURN expressao {
        AST_NODE *temp = $2;
        int expressionType = checkOperands(temp);

        if ( expressionType == TK_LIT_STRING || expressionType == TK_PR_STRING ) {
          exit(ERR_FUNCTION_STRING);
          // DEF: Etapa 4 - 2.5 - Retorno, argumentos e parâmetros de funções
        }

        insertReturnType(expressionType);

        $$ = create_ast_node(cmd_return, NULL, $2, NULL, NULL, NULL);
    }
    | TK_PR_CONTINUE         { $$ = create_ast_leaf(cmd_continue, NULL ) ;}
    | TK_PR_BREAK            { $$ = create_ast_leaf(cmd_break, NULL )    ;}
    ;


fluxoControle:
      TK_PR_IF '(' expressao ')' blocoComandos                                { $$ = create_ast_node(cmd_if, NULL, $3, $5, NULL, NULL)    ;}
    | TK_PR_IF '(' expressao ')' blocoComandos TK_PR_ELSE blocoComandos       { $$ = create_ast_node(cmd_if, NULL, $3, $5, $7, NULL)      ;}
    | TK_PR_FOR '(' atribuicao ':' expressao ':' atribuicao ')' blocoComandos { $$ = create_ast_node(cmd_for, NULL, $3, $5, $7, $9)       ;}
    | TK_PR_WHILE '(' expressao ')' TK_PR_DO blocoComandos                    { $$ = create_ast_node(cmd_while, NULL, $3, $6, NULL, NULL) ;}
    ;


expressao:
      aritmeticas
    | operacoes
    | '(' expressao ')' { $$ = $2 ;}
    ;

aritmeticas:
      identificador
    | identificador '[' expressao ']'     { $$ = create_ast_node( vec_index, NULL, $1, $3, NULL, NULL ) ;}
    | TK_LIT_INT                          { $$ = create_ast_leaf( no_type, $1 ) ;}
    | TK_LIT_FLOAT                        { $$ = create_ast_leaf( no_type, $1 ) ;}
    | chamadaFuncao
    ;

operacoes:
      unarios     { $$ = $1 ;}
    | binarios    { $$ = $1 ;}
    | ternarios   { $$ = $1 ;}
    ;

unarios:
      '+' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    | '-' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    | '!' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    | '&' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    | '*' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    | '?' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    | '#' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    ;

binarios:
      expressao '+' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '-' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '*' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '/' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '&' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '|' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '^' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '<' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '>' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao '%' expressao       { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao TK_OC_OR expressao  { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao TK_OC_AND expressao { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao TK_OC_GE expressao  { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao TK_OC_EQ expressao  { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao TK_OC_NE expressao  { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    | expressao TK_OC_LE expressao  { $$ = create_ast_node( no_type, $2, $1, $3, NULL, NULL) ;}
    ;

ternarios:
      expressao '?' expressao ':' expressao { $$ = create_ast_node( opr_ternary, $2, $1, $3, $5, NULL) ;}
      ;

%%
#include "ast.h"
#include "lexeme.h"

void yyerror (char const *s) {
    printf( "Erro encontrado na linha %d: %s \n", get_line_number(), s );
}


void insertReturnType(int type) {
    pilhaDeRetornos[indexPilhaDeRetorno] = type;
    indexPilhaDeRetorno++;
}

void removeReturnType(int type) {
    if(indexPilhaDeRetorno > 0) {
      if(getTipo(pilhaDeRetornos[indexPilhaDeRetorno-1]) == getTipo(type)) {
        pilhaDeRetornos[indexPilhaDeRetorno] = 0;
        if (!indexPilhaDeRetorno) indexPilhaDeRetorno--;
      } else {
        printf("\nErro semantico! Linha %d: O tipo de retorno deveria ser %s, mas recebeu: %s.", get_line_number(), getTipo(pilhaDeRetornos[indexPilhaDeRetorno-1]), getTipo(type));
        exit(ERR_WRONG_PAR_RETURN);
      }
    }
}

char *getTipo(int type) {
    switch(type) {
        case TK_PR_INT:
        case TK_LIT_INT:
          return "integer"; break;
        case TK_PR_FLOAT:
        case TK_LIT_FLOAT:
          return "float"; break;
        case TK_PR_CHAR:
        case TK_LIT_CHAR:
          return "char"; break;
        case TK_PR_BOOL:
        case TK_LIT_FALSE:
        case TK_LIT_TRUE:
          return "bool"; break;
        case TK_PR_STRING:
        case TK_LIT_STRING:
         return "string"; break;
        default: return "unknown"; break;
    }
}


// PRA QUE ESSA FUNCAO EXISTE????? WHY?
// int checkEntryList(AST_NODE *node) {
//     int result = 0;
//     if (node == NULL) return 0;

//     HASH_NODE *tmpNode = hashFind(node->value->char_sequence);
//     if (tmpNode == NULL) return 0;
//     if (tmpNode->type == TK_PR_STRING) {
//         return 1;
//     }

//     for(int son = 0; son < 4; son++) {
//         int tmpResult = checkEntryList(node->son[son]);
//         if (tmpResult == 1) {
//             return 1;
//         } else {
//             return 0;
//         }
//     }
// }

