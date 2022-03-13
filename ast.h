/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#ifndef ARVORE_H
#define ARVORE_H

#define MAX_SONS 4

#include <stdio.h>
#include <stdlib.h>
#include "lexeme.h"

typedef enum {

    no_type = 0,
    function_def,
    function_call,
    cmd_while,
    cmd_for,
    cmd_if,
    cmd_return,
    cmd_break,
    cmd_continue,
    cmd_output,
    cmd_input,
    vec_index,
    var_attribution,
    var_initializer,
    opr_ternary

} NodeType;

typedef struct ast_node {
    NodeType node_type;
    Lexeme *lexeme;
    struct AST_NODE *son[MAX_SONS];

} AST_NODE;

struct AST_NODE *create_ast_node( NodeType type, Lexeme *lexeme, struct AST_NODE *s0, struct AST_NODE *s1, struct AST_NODE *s2, struct AST_NODE *s3);

void export_tree(void *tree);
void tree_to_csv(AST_NODE *tree);
void node_to_label(AST_NODE *tree);
void free_tree(AST_NODE *tree);

#endif