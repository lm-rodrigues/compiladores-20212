/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexeme.h"

// Print lexeme information for debug purposes
void print_lexeme(Lexeme lexeme) {

    printf("Line Number:         %d\n", lexeme.line_number);
    printf("Token Category:      %d\n", lexeme.token_category);
    printf("Literal Token Type:  %d\n", lexeme.literal_token_value_type.type);
    printf("Literal Token Value: ");
    print_literal_value(lexeme.literal_token_value_type);
}

// Prints literals actual value
void print_literal_value(LiteralTokenValueType literal_token_value_type) {

    LiteralTokenType literal_token_type = literal_token_value_type.type;

    if (literal_token_type == char_sequence) {
        printf("%s\n", literal_token_value_type.value.char_sequence);

    } else if (literal_token_type == integer) {
        printf("%d\n", literal_token_value_type.value.integer);

    } else if (literal_token_type == floating) {
        printf("%f\n", literal_token_value_type.value.floating);

    } else if (literal_token_type == boolean) {
        printf("%d\n", literal_token_value_type.value.boolean);

    } else if (literal_token_type == character) {
        printf("%c\n", literal_token_value_type.value.character);
    }

}

Lexeme* lexemes_from_tokens(int line_number, char *value, LiteralTokenType type, TokenCategory token_category) {

    LiteralTokenValue literal_value;
    LiteralTokenType literal_type;

    if (token_category == literal){

        literal_type = type;

        switch (type) {

        case char_sequence:
            literal_value.char_sequence = strdup(strip_quotation_marks(value));
            break;

        case integer:
            literal_value.integer = atoi(value);
            break;

        case floating:
            literal_value.floating = atof(value);
            break;

        case boolean:
            literal_value.boolean = (strncmp( value, "true", 4) == 0);
            break;

        case character:
            strncpy(&literal_value.character, strip_quotation_marks(value), 1);
            break;

        default:
            break;
        }

    } else {
        literal_value.char_sequence = strdup(value);
        literal_type = char_sequence;

    }

    LiteralTokenValueType literal_token_value_type = { literal_value, literal_type };
    Lexeme lexical_value = { line_number, token_category, literal_token_value_type };
    Lexeme *lexeme = malloc(sizeof(lexical_value));
    *lexeme = lexical_value;

    return lexeme;

}

void free_lexeme(Lexeme *lexeme) {
    if (lexeme != NULL) {
        if (lexeme->literal_token_value_type.value.char_sequence != NULL) {
            free(lexeme->literal_token_value_type.value.char_sequence);
        }
        free(lexeme);
    }
}

char* strip_quotation_marks(char *value) {
    char *new_str = value;
    new_str++; /* removing first item */
    new_str[strlen(new_str) - 1] = '\0';  /* removing last item */
    return new_str;
}