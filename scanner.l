%{
    /* Integrantes - Grupo E:
    Giovanna Varriale Damian   - 00264850
    Leonardo Marques Rodrigues - 00213751
    */

    #include "parser.tab.h"
    #include "lexeme.h"
    int line_number = 1;
    int get_line_number(void);
%}

// Lex states definitions
%x MULTILINE_COMMENT

%%
 /* 3.1 - Palavras reservadas */;
"int"        { return TK_PR_INT       ;}
"float"      { return TK_PR_FLOAT     ;}
"bool"       { return TK_PR_BOOL      ;}
"char"       { return TK_PR_CHAR      ;}
"string"     { return TK_PR_STRING    ;}
"if"         { return TK_PR_IF        ;}
"then"       { return TK_PR_THEN      ;}
"else"       { return TK_PR_ELSE      ;}
"while"      { return TK_PR_WHILE     ;}
"do"         { return TK_PR_DO        ;}
"input"      { return TK_PR_INPUT     ;}
"output"     { return TK_PR_OUTPUT    ;}
"return"     { return TK_PR_RETURN    ;}
"const"      { return TK_PR_CONST     ;}
"static"     { return TK_PR_STATIC    ;}
"foreach"    { return TK_PR_FOREACH   ;}
"for"        { return TK_PR_FOR       ;}
"switch"     { return TK_PR_SWITCH    ;}
"case"       { return TK_PR_CASE      ;}
"break"      { return TK_PR_BREAK     ;}
"continue"   { return TK_PR_CONTINUE  ;}
"class"      { return TK_PR_CLASS     ;}
"private"    { return TK_PR_PRIVATE   ;}
"public"     { return TK_PR_PUBLIC    ;}
"protected"  { return TK_PR_PROTECTED ;}
"end"        { return TK_PR_END       ;}
"default"    { return TK_PR_DEFAULT   ;}

 /* 3.2 - Caracteres Especiais */;
[\,\;\:\(\)\[\]\{\}\.] { return yytext[0] ;}

[\+\-\|\*\<\>\=\!\&\%\#\^\$\/\?] { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, special_char); return yytext[0] ;}

 /* 3.3 - Operadores Compostos */;
"<="  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_LE  ;}
">="  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_GE  ;}
"=="  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_EQ  ;}
"!="  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_NE  ;}
"&&"  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_AND ;}
"||"  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_OR  ;}
">>"  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_SL  ;}
"<<"  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, composed_operator); return TK_OC_SR  ;}

 /* 3.5 - Literais */;
"false"                      { yylval.lexeme = lexemes_from_tokens(line_number, yytext, boolean, literal);       return TK_LIT_FALSE  ;}
"true"                       { yylval.lexeme = lexemes_from_tokens(line_number, yytext, boolean, literal);       return TK_LIT_TRUE   ;}
[0-9]+                       { yylval.lexeme = lexemes_from_tokens(line_number, yytext, integer, literal);       return TK_LIT_INT    ;}
[0-9]+\.[0-9]+([eE][0-9]+)?  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, floating, literal);      return TK_LIT_FLOAT  ;}
\'([^\"\\\n]|\\.)\'          { yylval.lexeme = lexemes_from_tokens(line_number, yytext, character, literal);     return TK_LIT_CHAR   ;}
\"([^\"\\\n]|\\.)*\"         { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, literal); return TK_LIT_STRING ;}

 /* 3.4 - Identificadores */;
[A-Za-z_][A-Za-z_0-9]*  { yylval.lexeme = lexemes_from_tokens(line_number, yytext, char_sequence, identifier); return TK_IDENTIFICADOR ;}

 /* 2.2 - Contagem de linhas */;
"\n"  { line_number++ ;}

 /* 2.3 - Ignorar Comentários */;
"//".*                                                    // Ignore one line comments content
"/*"                        { BEGIN(MULTILINE_COMMENT) ;} // Start MULTILINE_COMMENT lex state
<MULTILINE_COMMENT>"*/"     { BEGIN(INITIAL)           ;} // Return to inital lex state
<MULTILINE_COMMENT>"\n"     { line_number++            ;} // Increase line_number on MULTILINE_COMMENT lex state
<MULTILINE_COMMENT>.                                      // Ignore content on MULTILINE_COMMENT lex state
<MULTILINE_COMMENT><<EOF>>  { BEGIN(INITIAL);
                              return TOKEN_ERRO ;}        // Identify an EOF before exit MULTILINE_COMMENT lex state

[ \t] // Espaços devem ser ignorados

 /* 2.4 - Lançar erros léxicos */;
.  { return TOKEN_ERRO ;}

%%

/* 2.2 - Contagem de Linhas */
int get_line_number(void) { return line_number ;}