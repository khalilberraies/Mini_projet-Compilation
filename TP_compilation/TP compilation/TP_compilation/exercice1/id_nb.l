%{
#include <stdio.h>
%}

%%
[0-9]+                 { printf("NB (entier naturel): %s\n", yytext); }
[a-zA-Z][a-zA-Z0-9]*  { printf("ID: %s\n", yytext); }
[ \t\n]               { /* ignore whitespace */ }
.                     { printf("Caractère non reconnu: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}

int main() {
    yylex();
    return 0;
}
