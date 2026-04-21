%{
#include <stdio.h>
%}

%%
[a-zA-Z][a-zA-Z0-9]*  { printf("IDENTIFIANT: %s\n", yytext); }
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
