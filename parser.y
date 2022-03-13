%{
    /* Integrantes - Grupo E:
    Giovanna Varriale Damian   - 00264850
    Leonardo Marques Rodrigues - 00213751
    */

    #include <stdio.h>

    #include "ast.h"
    #include "lexeme.h"

    int get_line_number(void);

    int yylex(void);
    void yyerror (char const *s);

    extern AST_NODE *arvore;
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
%type <tree> declaracaoFuncao
%type <tree> listaParametros
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
%type <tree> declaracaoVariavelGlobal
%type <tree> opcionalListVarGlobal
%type <tree> blocoComandos
%type <tree> operacoesEntrada
%type <tree> operacoesSaida
%type <tree> operacoesRetorno
%type <tree> opcionalInit
%type <tree> parametros

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
      dec decList { if($1 == NULL){ if($2 == NULL){ $$ = NULL; } $$ = $2; } else if($2 == NULL){ $$ = $1; }
                    $$ = create_ast_node(no_type, NULL, $1, $2, NULL, NULL) ;}
    |             { $$ = NULL ;}
    ;

dec:
      declaracaoVariavelGlobal { $$ = $1 ;}
    | declaracaoFuncao         { $$ = $1 ;}
    ;

// Definições que se repetem;
identificadorOuLiteral:
      TK_IDENTIFICADOR  { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;}
    | TK_LIT_TRUE       { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;}
    | TK_LIT_FALSE      { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;}
    | TK_LIT_CHAR       { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;}
    | TK_LIT_INT        { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;}
    | TK_LIT_FLOAT      { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;}
    | TK_LIT_STRING     { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;}
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
      TK_LIT_INT { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL) ;};


// Declaração de Variavel Global - Não entram na AST;
declaracaoVariavelGlobal:
      opcionalStatic tipo TK_IDENTIFICADOR opcionalListVarGlobal ';'                { $$ = $$ ;}
    | opcionalStatic tipo TK_IDENTIFICADOR '[' numero ']' opcionalListVarGlobal ';' { $$ = $$ ;}
    ;

opcionalListVarGlobal:
      ',' TK_IDENTIFICADOR opcionalListVarGlobal                { $$ = $$ ;}
    | ',' TK_IDENTIFICADOR '[' numero ']' opcionalListVarGlobal { $$ = $$ ;}
    |                                                           { $$ = $$ ;}
    ;


// Definição da seção 3.2;
declaracaoFuncao:
        opcionalStatic tipo TK_IDENTIFICADOR '(' parametros ')' blocoComandos { $$ = create_ast_node( function_def, NULL, $3, $5, $7, NULL)   ;}
      | opcionalStatic tipo TK_IDENTIFICADOR '(' ')' blocoComandos            { $$ = create_ast_node( function_def, NULL, $3, $6, NULL, NULL) ;}
      ;

parametros:
      opcionalConst tipo TK_IDENTIFICADOR listaParametros     { $$ = create_ast_node( no_type, NULL, $3, $4, NULL, NULL) ;}
      ;

listaParametros:
        ',' parametros  { $$ = $2   ;}
      |                 { $$ = NULL ;}
      ;

// Definição da seção 3.3;
blocoComandos:
      '{' comando '}' { $$ = $2 ;}
      ;

comando:
      comandoSimples ';' comando { if($1 == NULL){ if($3 == NULL){ $$ = NULL; } $$ = $3; } else if($3 == NULL){ $$ = $1; }
                                   $$ = create_ast_node(no_type, NULL, $1, $3, NULL, NULL) ;}
    |                             { $$ = NULL ;}
    ;

comandoSimples:
      declaracaoVariavelLocal { $$ = $1 ;}
    | atribuicao              { $$ = $1 ;}
    | fluxoControle           { $$ = $1 ;}
    | operacoesEntrada        { $$ = $1 ;}
    | operacoesSaida          { $$ = $1 ;}
    | operacoesRetorno        { $$ = $1 ;}
    | blocoComandos           { $$ = $1 ;}
    | chamadaFuncao           { $$ = $1 ;}
    | comandoShift            { $$ = $1 ;}
    ;


// Definições da seção 3.4;
declaracaoVariavelLocal:
      opcionalStatic opcionalConst tipo variavelLocal { $$ = $4 ;}
      ;

variavelLocal:
      TK_IDENTIFICADOR opcionalInit listaVar { $$ = create_ast_node( no_type, $1, $2, $3, NULL, NULL ) ;}
      ;

listaVar:
      ',' variavelLocal { $$ = $2   ;}
    |                   { $$ = NULL ;}
    ;
opcionalInit:
      TK_OC_LE identificadorOuLiteral { $$ = $2   ;}
    |                                 { $$ = NULL ;}
    ;


atribuicao:
      TK_IDENTIFICADOR '=' expressao                   { $$ = create_ast_node( var_attribution, $2, $1, $3, NULL, NULL) ;}
    | TK_IDENTIFICADOR '[' expressao ']' '=' expressao { $$ = create_ast_node( var_attribution, $5, $1, $3, $6, NULL)   ;}
    ;


operacoesEntrada:
      TK_PR_INPUT TK_IDENTIFICADOR { $$ = create_ast_node(cmd_input, NULL, $2, NULL, NULL, NULL) ;}
      ;

operacoesSaida:
      TK_PR_OUTPUT identificadorOuLiteral { $$ = create_ast_node(cmd_output, NULL, $2, NULL, NULL, NULL) ;}
      ;


chamadaFuncao:
      TK_IDENTIFICADOR '(' listaEntradas ')' { $$ = create_ast_node(function_call, $1, $3, NULL, NULL, NULL) ;}
      ;
listaEntradas:
      TK_IDENTIFICADOR entradaSeguinte { $$ = create_ast_node(no_type, $1, $2, NULL, NULL, NULL) ;}
    |                                  { $$ = NULL                                               ;}
    ;

entradaSeguinte:
      ',' listaEntradas { $$ = $2   ;}
    |                   { $$ = NULL ;}
    ;


comandoShift:
      TK_IDENTIFICADOR TK_OC_SR numero { $$ = create_ast_node(no_type, $2, $1, $3, NULL, NULL ) ;}
    | TK_IDENTIFICADOR TK_OC_SL numero { $$ = create_ast_node(no_type, $2, $1, $3, NULL, NULL ) ;}
    ;



operacoesRetorno:
      TK_PR_RETURN expressao { $$ = create_ast_node(cmd_return, NULL, $2, NULL, NULL, NULL)     ;}
    | TK_PR_CONTINUE         { $$ = create_ast_node(cmd_continue, NULL, NULL, NULL, NULL, NULL) ;}
    | TK_PR_BREAK            { $$ = create_ast_node(cmd_break, NULL, NULL, NULL, NULL, NULL)    ;}
    ;


fluxoControle:
      TK_PR_IF '(' expressao ')' blocoComandos                                { $$ = create_ast_node(cmd_if, NULL, $3, $5, NULL, NULL)    ;}
    | TK_PR_IF '(' expressao ')' blocoComandos TK_PR_ELSE blocoComandos       { $$ = create_ast_node(cmd_if, NULL, $3, $5, $7, NULL)      ;}
    | TK_PR_FOR '(' atribuicao ':' expressao ':' atribuicao ')' blocoComandos { $$ = create_ast_node(cmd_for, NULL, $3, $5, $7, $9)       ;}
    | TK_PR_WHILE '(' expressao ')' TK_PR_DO blocoComandos                    { $$ = create_ast_node(cmd_while, NULL, $3, $6, NULL, NULL) ;}
    ;


expressao:
      aritmeticas       { $$ = $1 ;}
    | operacoes         { $$ = $1 ;}
    | '(' expressao ')' { $$ = $2 ;}
    ;

aritmeticas:
      TK_IDENTIFICADOR                    { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL ) ;}
    | TK_IDENTIFICADOR '[' expressao ']'  { $$ = create_ast_node( no_type, $1, $3, NULL, NULL, NULL )   ;}
    | TK_LIT_INT                          { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL ) ;}
    | TK_LIT_FLOAT                        { $$ = create_ast_node( no_type, $1, NULL, NULL, NULL, NULL ) ;}
    | chamadaFuncao                       { $$ = $1                                                     ;}
    ;

operacoes:
      unarios     { $$ = $1 ;}
    | binarios    { $$ = $1 ;}
    | ternarios   { $$ = $1 ;}
    ;

unarios:
     '+' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    |'-' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    |'!' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    |'&' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    |'*' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    |'?' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
    |'#' expressao { $$ = create_ast_node( no_type, $1, $2, NULL, NULL, NULL) ;}
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

void yyerror (char const *s) {
    printf( "Erro encontrado na linha %d: %s \n", get_line_number(), s );
}