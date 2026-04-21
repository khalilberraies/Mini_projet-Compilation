%{
#include <stdio.h>
#include <stdlib.h>
%}

%%
[01]+      { printf("C'est un nombre binaire: %s\n", yytext); }
[01]*      { printf("Ce n'est pas un nombre binaire: %s\n", yytext); }
[ \t\n]    { /* ignore whitespace */ }
.          { /* ignore other characters */ }
%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    ++argv, --argc;
    if (argc > 0)
        yyin = fopen(argv[0], "r");
    else
        yyin = stdin;
    yylex();
    return 0;
}
