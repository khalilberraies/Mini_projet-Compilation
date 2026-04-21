%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int line_num = 1;
int error_count = 0;

void print_token(char *type, char *value) {
    printf("%-12s: %s\n", type, value);
}

void print_error(char *type, char *value) {
    printf("** Erreur ligne %d: %s - %s\n", line_num, type, value);
    error_count++;
}
%}

DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENT       {LETTER}({LETTER}|{DIGIT})*
ENTIER      {DIGIT}+
REEL1       {DIGIT}+"."[0-9]+
REEL2       {DIGIT}+[Ee][+-]?{DIGIT}+
REEL3       {DIGIT}+"."[0-9]+[Ee][+-]?{DIGIT}+
REEL4       "."[0-9]+([Ee][+-]?{DIGIT}+)?
ESPACE      [ \t]

%%
"if"                    { print_token("MOTCLE", "if"); }
"else"                  { print_token("MOTCLE", "else"); }
"while"                 { print_token("MOTCLE", "while"); }

{REEL1}|{REEL2}|{REEL3}|{REEL4}  { print_token("REEL", yytext); }
{ENTIER}                { print_token("ENTIER", yytext); }

"+"                     { print_token("OP-ARTHM", "+"); }
"-"                     { print_token("OP-ARTHM", "-"); }
"*"                     { print_token("OP-ARTHM", "*"); }
"/"                     { print_token("OP-ARTHM", "/"); }

"<"                     { print_token("OP-REL", "<"); }
">"                     { print_token("OP-REL", ">"); }
"<="                    { print_token("OP-REL", "<="); }
">="                    { print_token("OP-REL", ">="); }
"=="                    { print_token("OP-REL", "=="); }
"!="                    { print_token("OP-REL", "!="); }

"="                     { print_token("AFFECT", "="); }

{IDENT}                 { print_token("IDENT", yytext); }

\"[^\"]*\"              { print_token("CHAINE", yytext); }

"#".*                   { print_token("COMMENT", yytext); }

\n                      { line_num++; }

{ESPACE}                { }

.                       { print_error("caractère non reconnu", yytext); }
%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc > 1)
        yyin = fopen(argv[1], "r");
    else
        yyin = stdin;
    
    printf("=== Analyse lexicale ===\n");
    printf("=======================\n\n");
    
    yylex();
    
    printf("\n=======================\n");
    printf("Total des erreurs: %d\n", error_count);
    
    return 0;
}
