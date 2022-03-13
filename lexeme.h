/* Integrantes - Grupo E:
Giovanna Varriale Damian   - 00264850
Leonardo Marques Rodrigues - 00213751
*/

#ifndef Lexeme_H
#define Lexeme_H

#define true 1
#define false 0

typedef union {
    char *char_sequence;
    int   integer;
    float floating;
    int   boolean;
    char  character;
} LiteralTokenValue;

typedef enum {
    char_sequence = 0,
    integer       = 1,
    floating      = 2,
    boolean       = 3,
    character     = 4
} LiteralTokenType;

typedef enum {
    special_char      = 0,
    composed_operator = 1,
    identifier        = 2,
    literal           = 3,
} TokenCategory;

typedef struct {

    LiteralTokenValue value;
    LiteralTokenType  type;

} LiteralTokenValueType;

typedef struct Lexeme
{
    int line_number; // Especificação 2.1 (a)
    TokenCategory token_category; // Especificação 2.1 (b)
    LiteralTokenValueType literal_token_value_type; // Especificação 2.1 (c)

    // for non-literal tokens categories literalTokenValueType always assumes:
    // LiteralTokenType: char_sequence
    // LiteralTokenValue: *char_sequence

} Lexeme;

void   print_lexeme(Lexeme lexical_value);
void   print_literal_value(LiteralTokenValueType literal_token_value_type);
Lexeme* lexemes_from_tokens(int line_number, char *value, LiteralTokenType type, TokenCategory token_category);
char*  strip_quotation_marks(char *value) ;
void   free_lexeme(Lexeme *lexeme);

#endif