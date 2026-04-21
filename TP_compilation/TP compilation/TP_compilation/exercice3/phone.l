%{
#include <stdio.h>
#include <string.h>
%}

/* Regular definitions for Exercise 3 */
NOM         [A-Z][a-zA-Z]*
PRENOM      [a-z]+
TELEPHONE   [0-9]{2}[[:space:]][0-9]{2}[[:space:]][0-9]{2}[[:space:]][0-9]{2}[[:space:]][0-9]{2}

%%
{NOM}       { printf("NOM: %s\n", yytext); }
{PRENOM}    { printf("PRENOM: %s\n", yytext); }
{TELEPHONE} { printf("TELEPHONE: %s\n", yytext); }
"@"         { /* ignore @ symbol */ }
[ \t]+      { /* ignore spaces */ }
\n          { /* ignore newlines */ }
.           { /* ignore other characters */ }
%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc > 1)
        yyin = fopen(argv[1], "r");
    else
        yyin = stdin;
    
    yylex();
    return 0;
}
