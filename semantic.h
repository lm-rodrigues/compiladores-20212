/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#ifndef SEMANTIC_H
#define SEMANTIC_H

#include "errors.h"
#include "lexeme.h"
#include "parser.tab.h"
#include "hash.h"
#include "ast.h"

// Etapa 4 - Análise Semântica


// Etapa 4 - 2.1 - Implementar uma tabela de simbolos
// Descrição do topico em hash.h



// Etapa 4 - 2.2 - Verificação de declarações

// Todos os identificadores devem ter sido declarados no momento do seu uso,
// seja como vari ́avel, como vetor ou como funcao.
// Todas as entradas na tabela de sımbolos devem ter um tipo associado conforme
// a declaração, verificando-se se nao houve dupla declaracao ou se o sımbolo nao foi declarado
// Caso o identificador já tenha sido declarado, deve-se lançar o erro ERR DECLARED
// Caso o identificador nao tenha sido declarado no seu uso, deve-se lançar o erro ERR UNDECLARED.
void checkAlreadyDeclared(char *variableName, int lineNumber, int variableKind);
void checkUndefinedVariable(char *variableName, int lineNumber, int variableKind);

// Vari ́aveis com o mesmo nome podem co-existir em escopos diferentes,
// efetivamente mascarando as vari ́aveis que est ̃ao em escopos superiores.

// Regras de escopo: A verificacao de declaracao previa de tipos deve considerar o escopo da linguagem.
// O escopo pode ser global, local da função e local de um bloco,
// sendo que este pode ser recursivamente aninhado.
// Uma forma de se implementar estas regras de escopo  ́e atrav ́es de uma pilha de tabelas de s ́ımbolos.
// Para verificar se uma variavel foi declarada, verifica-se primeiramente no escopo atual (topo da pilha)
// e enquanto n ̃ao encontrar, deve-se descer na pilha ate chegar no escopo global (base da pilha, sempre presente).
// Caso o identificador nao seja encontrado, isso indica que ele nao foi declarado.
// Para se ”declarar” um sımbolo, basta inseri-lo na tabela de sımbolos do escopo que encontra-se no topo da pilha.



// Etapa 4 - 2.3 - Uso correto de identificadores
// O uso de identificadores deve ser compat ́ıvel com sua declaracao e com seu tipo.
// Variaveis somente podem ser usadas sem indexacao, vetores somente podem ser utilizados com indexacao,
// e func ̧  ̃oes apenas devem ser usadas como chamada de funcao, isto  ́e, seguidas da lista de argumentos,
// esta possivelmente vazia conforme a sintaxe da E2, entre parˆenteses.
// Caso o identificador dito variavel seja usado como vetor ou como funcao, deve-se lancr o erro ERR_VARIABLE.
// Caso o identificador dito vetor seja usado como variavel ou funcao, deve-se lancar o erro ERR_VECTOR.
// Enfim, caso o identificador dito funcao seja utilizado como variavel ou vetor, deve-se lancar o erro ERR_FUNCTION.
int checkDeclarationAndType();



// Etapa 4 - 2.4 - Verificação de tipos e tamanho dos dados

// Uma declaracao de vari ́avel deve permitir ao compilador definir o tipo
//e a ocupacao em memoria da vari ́avel na sua entrada na tabela de s ́ımbolos.
//Com o aux ́ılio desta informacao, quando necess ́ario, os tipos de dados corretos
//devem ser inferidos onde forem usados, em express  ̃oes aritm ́eticas, relacionais, logicas, ou para  ́ındices de vetores.
//Por simplificacao, isso nos leva a situacao onde todos os nos da AST devem
//ser anotados com um tipo definido de acordo com as regras de inferˆencia de tipos.

// Um no da AST deve ter portanto um novo campo que registra o seu tipo de dado.

// O processo de inferencia de tipos esta descrito abaixo.
// Como n ̃ao temos coerçao de vari ́aveis do tipo string e char,
// o compilador deve lançar o erro ERR STRING TO X quando a vari ́avel do tipo string es-
// tiver em uma situacao onde ela deve ser convertida para qualquer outro tipo.
// De maneira análoga,
// o erro ERR CHAR TO X deve ser lançado quando uma vari ́avel do tipo char deve ser convertida implicitamente.
// Enfim, vetores n ̃ao podem ser do tipo string.
// Caso um vetor tenha sido declarado com o tipo string, o erro ERR STRING VECTOR deve ser lançado.
int checkTypeAndSize(); // não tenho codigo pra isso - é feito direto no parse (?)



// Etapa 4 - 2.5 - Retorno, argumentos e parâmetros de funções

// A lista de argumentos fornecidos em uma chamada de função deve ser verificada
// contra a lista de parametros formais na declaracao da mesma função.
// Cada chamada de função deve prover um argumento para cada parametro, e ter o seu tipo compat ́ıvel.
// Tais verificac ̧  ̃oes devem ser realizadas levando-se em conta as informac ̧  ̃oes registradas na tabela de s ́ımbolos,
// registradas no momento da declaracao/definicao da função.
// Na hora da chamada da função, caso houver um numero menor de argumentos que o necess ́ario,
// deve-se lançar o erro ERR MISSING ARGS.
// Caso houver um numero maior de argumentos que o necess ́ario, deve-se lançar o erro ERR EXCESS ARGS.
// Enfim, quando o numero de argumentos  ́e correto, mas os tipos dos argumentos s ̃ao incompat ́ıveis com
// os tipos registrados na tabela de s ́ımbolo, deve-se lançar o erro ERR WRONG TYPE ARGS.

// Feito no parser:
// Retorno, argumentos e parametros de funcoes nao podem ser do tipo string.
// Quando estes casos acontecerem, lançar o erro ERR_FUNCTION_STRING.
int checkArgs();



// Etapa 4 - 2.6 - Verificação de tipos de comandos

// Prevalece o tipo do identificador que recebe um valor em um comando de atribuicao.
// O erro ERR WRONG TYPE deve ser lançado quando o tipo do valor a ser atribu ́ıdo a um
// identificador for incompat ́ıvel com o tipo deste identificador.
// Os demais comandos simples da linguagem devem ser verificados semanticamente para obedecer as seguintes regras.
// O comando input deve ser seguido obrigatoriamente por um identificador do tipo int e float.
// Caso contr ́ario, o compilador deve lançar o erro ERR WRONG PAR INPUT.
// De maneira an ́aloga, o comando output deve ser seguido por um identificador ou literal do tipo int e float.
// Caso contr ́ario, deve ser lançado o erro ERR WRONG PAR OUTPUT.
// O comando de retorno return deve ser seguido obrigatoriamente por uma express ̃ao cujo tipo  ́e compat ́ıvel
// com o tipo de retorno da funcao. Caso n ̃ao seja o caso, o erro ERR WRONG PAR RETURN deve ser lançado pelo compilador.
// Nos comandos de shift (esquerda e direta), deve-se lançar o erro ERR WRONG PAR SHIFT
// caso o parametro apos o token de shift for um numero maior que 16.

void checkInput(char *variableName, int lineNumber);
void checkOutput(char *variableName, int lineNumber);
void checkShift(char *shiftNumber, int lineNumber);



// Etapa 4 - 2.7 - Mensagens de erro

// Mensagens de erro significativas devem ser fornecidas. Elas devem descrever em linguagem natural o erro semantico,
// as linhas envolvidas, os identificadores e a natureza destes.
// void printSemanticError(int lineNumber, char *identificador, char *natureza, char *maisExplicacoes ) {

#endif