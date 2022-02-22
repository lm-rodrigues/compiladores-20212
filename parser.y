%{
    /* Integrantes - Grupo E:
    Giovanna Varriale Damian   - 00264850
    Leonardo Marques Rodrigues - 00213751
    */

    #include <stdio.h>

    int get_line_number(void);

    int yylex(void);
    void yyerror (char const *s);
%}
%define parse.error verbose

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
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO

// Precedencias:
%left '<' '>' TK_OC_EQ TK_OC_NE TK_OC_GE TK_OC_LE
%left '+' '-'
%left '*' '/'
%left '^' '|' '%' TK_OC_AND TK_OC_OR

%nonassoc ':'

%right '&' '#' '!' '?'

%%

// 3 - A Linguagem ;
programa: decList;

decList: dec decList
    |
    ;

dec: declaracaoVariavelGlobal
    | declaracaoFuncao
    ;

// -- Definições que se repetem;
identificadorOuLiteral: TK_IDENTIFICADOR
    | TK_LIT_TRUE
    | TK_LIT_FALSE
    | TK_LIT_CHAR
    | TK_LIT_INT
    | TK_LIT_FLOAT
    | TK_LIT_STRING
    ;

tipo: TK_PR_INT
    | TK_PR_FLOAT
    | TK_PR_CHAR
    | TK_PR_BOOL
    | TK_PR_STRING
    ;

opcionalStatic: TK_PR_STATIC
    |
    ;
opcionalConst: TK_PR_CONST
    |
    ;


// 3.2 - Definição de Funções;

declaracaoFuncao: cabecalho blocoComandos;

cabecalho: opcionalStatic tipo TK_IDENTIFICADOR '(' listaParametros ')';

listaParametros: opcionalConst tipo TK_IDENTIFICADOR listaParametros
 | ',' opcionalConst tipo TK_IDENTIFICADOR listaParametros
 |
 ;

blocoComandos: '{' comando '}' ;

comando: comandoSimples ';' comando
    |
    ;
comandoSimples: declaracaoVariavelLocal
    | atribuicao
    | fluxoControle
    | opEntrada
    | opSaida
    | opRetorno
    | blocoComandos
    | chamadaFuncao
    | comandoShift
    ;

// 3.1 - Declaração de Variavel Global;
declaracaoVariavelGlobal: opcionalStatic tipo varGlobal opcionalListVarGlobal ';' ;

opcionalListVarGlobal: ',' varGlobal
    |
    ;

varGlobal: TK_IDENTIFICADOR
    | TK_IDENTIFICADOR '[' numero ']'
    ;

// 3.4 - subtitle 1 - Declaração de Variavel Local
declaracaoVariavelLocal: opcionalStatic opcionalConst tipo variavelLocal;

variavelLocal: TK_IDENTIFICADOR opcionalInit listaVar;

listaVar: ',' variavelLocal
    |
    ;
opcionalInit: TK_OC_LE identificadorOuLiteral
    |
    ;

// 3.4 - subtitle 2 - Comando de Atribuição;
atribuicao: TK_IDENTIFICADOR '=' expressao
    | TK_IDENTIFICADOR '[' expressao ']' '=' expressao
    ;

// 3.4 - subtitle 3 - Comando de Entrada e Saida;
opEntrada: TK_PR_INPUT TK_IDENTIFICADOR;
opSaida: TK_PR_OUTPUT identificadorOuLiteral;

// 3.4 - subtitle 4 - Chamada de Função;
chamadaFuncao: nomeFuncao '(' listaEntradas ')';

nomeFuncao: TK_IDENTIFICADOR;
listaEntradas: entrada entradaSeguinte
    |
    ;
entrada: TK_IDENTIFICADOR;
entradaSeguinte: ',' listaEntradas
  |
  ;


// 3.4 - subtitle 5 - Comandos de Shift;
comandoShift: TK_IDENTIFICADOR shifts numero;
shifts: TK_OC_SR | TK_OC_SL;
// Como garantir que vai ser positivo??
numero: TK_LIT_INT;

// 3.4 - subtitle 6
opRetorno: TK_PR_RETURN expressao
    | TK_PR_CONTINUE
    | TK_PR_BREAK
    ;

// 3.4 - subtitle 7
fluxoControle: TK_PR_IF '(' expressao ')' blocoComandos opcionalElse
    | TK_PR_FOR '(' atribuicao ':' expressao ':' atribuicao ')' blocoComandos
    | TK_PR_WHILE '(' expressao ')' TK_PR_DO blocoComandos
    ;

opcionalElse: TK_PR_ELSE blocoComandos
    |
    ;

// 3.5 - Expr. Aritmeticas, Logicas;
expressao: aritmeticas
    | operacoes
    | '(' expressao ')'
    | TK_LIT_TRUE
    | TK_LIT_FALSE
    ;

aritmeticas: TK_IDENTIFICADOR
    | TK_IDENTIFICADOR '[' expressao ']'
    | TK_LIT_INT
    | TK_LIT_FLOAT
    | chamadaFuncao
    ;

operacoes: unarios | binarios | ternarios;
unarios: '+' expressao
    |'-' expressao
    |'!' expressao
    |'&' expressao
    |'*' expressao
    |'?' expressao
    |'#' expressao
    ;
binarios: expressao '+' expressao
    | expressao '-' expressao
    | expressao '*' expressao
    | expressao '/' expressao
    | expressao '&' expressao
    | expressao '|' expressao
    | expressao '^' expressao
    | expressao '<' expressao
    | expressao '>' expressao
    | expressao '%' expressao
    | expressao TK_OC_OR expressao
    | expressao TK_OC_AND expressao
    | expressao TK_OC_GE expressao
    | expressao TK_OC_EQ expressao
    | expressao TK_OC_NE expressao
    | expressao TK_OC_LE expressao
    ;
ternarios: expressao '?' expressao ':' expressao;

%%

void yyerror (char const *s) {
    printf( "Erro encontrado na linha %d: %s \n", get_line_number(), s );
}