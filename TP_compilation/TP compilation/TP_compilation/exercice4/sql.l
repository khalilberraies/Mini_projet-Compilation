%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>

void print_token(char *type, char *value) {
    printf("<%s, %s>\n", type, value);
}
%}

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENT       {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     {DIGIT}+
WHITESPACE  [ \t\n]

%%
[Cc][Rr][Ee][Aa][Tt][Ee]               { print_token("MOT_CLE", "CREATE"); }
[Tt][Aa][Bb][Ll][Ee]                   { print_token("MOT_CLE", "TABLE"); }
[Ii][Nn][Tt]                           { print_token("TYPE", "INT"); }
[Vv][Aa][Rr][Cc][Hh][Aa][Rr]           { print_token("TYPE", "VARCHAR"); }
[Dd][Aa][Tt][Ee]                       { print_token("TYPE", "DATE"); }
[Pp][Rr][Ii][Mm][Aa][Rr][Yy]           { print_token("MOT_CLE", "PRIMARY"); }
[Kk][Ee][Yy]                           { print_token("MOT_CLE", "KEY"); }
"("                                      { print_token("PARENTHESE", "("); }
")"                                      { print_token("PARENTHESE", ")"); }
","                                      { print_token("VIRGULE", ","); }
";"                                      { print_token("FIN_COMMANDE", ";"); }
{IDENT}                                  { print_token("IDENTIFIANT", yytext); }
{INTEGER}                                { print_token("NOMBRE", yytext); }
{WHITESPACE}                             { }
.                                        { printf("Erreur: caractère non reconnu '%s'\n", yytext); }
%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc > 1)
        yyin = fopen(argv[1], "r");
    else
        yyin = stdin;
    
    printf("=== Analyse lexicale de la requête SQL ===\n\n");
    yylex();
    printf("\n=== Fin de l'analyse ===\n");
    
    return 0;
}
