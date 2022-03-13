/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#include "ast.h"
#include "lexeme.h"
#include "parser.tab.h"

struct AST_NODE *create_ast_node(NodeType type, Lexeme *lexeme, struct AST_NODE *s0, struct AST_NODE *s1, struct AST_NODE *s2, struct AST_NODE *s3) {
    AST_NODE *new_node;
    new_node = malloc(sizeof(AST_NODE));
    // new_node->lexeme = malloc(sizeof(lexeme));
    if ( lexeme != NULL ) {
        print_lexeme( *lexeme );
    }

    new_node->node_type = type;
    new_node->lexeme = lexeme;
    new_node->son[0] = s0;
    new_node->son[1] = s1;
    new_node->son[2] = s2;
    new_node->son[3] = s3;

    return new_node;
}

void node_to_label(AST_NODE *tree) {
    if (tree == NULL) { return ;}
    int son_index = 0;

    if (tree->lexeme != NULL) {
        printf("%p [label=\"", tree);
        if (tree->node_type != no_type) {
            print_node_type(tree->node_type);
        } else {
            print_literal_value(tree->lexeme->literal_token_value_type);
        }
        printf("\"]\n");
  }

  for(son_index = 0; son_index < MAX_SONS; son_index++) {
    node_to_label(tree->son[son_index]);
  }
}

void tree_to_csv(AST_NODE *tree) {
  if (tree == NULL) { return; }
  int son_index = 0;

  for(son_index = 0; son_index < MAX_SONS; son_index++) {
      if (tree->son[son_index] != NULL)
        printf("%p, %p \n", tree, tree->son[son_index]);
  }

  for(son_index = 0; son_index < MAX_SONS; son_index++) {
    tree_to_csv(tree->son[son_index]);
  }
}


void exporta(void *tree) {
    AST_NODE *root = (AST_NODE *) tree;

    node_to_label(root);
    // tree_to_csv(root);
}

void libera(void *tree) {
  free_tree((AST_NODE *) tree);

}

void free_tree(AST_NODE *tree) {
  if (tree != NULL){
    for(int son_index = 0; son_index < MAX_SONS; son_index++) {
        free_tree(tree->son[son_index]);
    }

    if (tree->lexeme != NULL) {
        free_lexeme(tree->lexeme);
    }

    free(tree);
  }
  return;
}


void print_node_type(NodeType node_type) {

    switch (node_type){

        // case function_def:
        //     break;
        case cmd_while:
            printf("while");
            break;
        case cmd_for:
            printf("for");
            break;
        case cmd_if:
            printf("if");
            break;
        case cmd_return:
            printf("return");
            break;
        case cmd_break:
            printf("break");
            break;
        case cmd_continue:
            printf("continue");
            break;
        case cmd_output:
            printf( "output" );
            break;
        case cmd_input:
            printf( "input" );
            break;
        case opr_ternary:
            printf( "?:" );
            break;
        case vec_index:
            printf( "[]" );
            break;
        case var_attribution:
            printf( "=" );
            break;
        // case var_initializer:
        //     break;
        case function_call:
            printf("call ");
            break;
        default:
            break;
    }

}