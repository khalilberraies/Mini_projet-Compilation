%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sql.tab.h"
%}
%%
"CREATE"    { return CREATE; }
"TABLE"     { return TABLE; }
"varchar"   { return VARCHAR; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.chaine = strdup(yytext); return ID; }
[0-9]+      { yylval.entier = atoi(yytext); return NB; }
[(),]       { return yytext[0]; }
[ \t\n\r]   { }
.           { printf("Erreur lexicale: %s\n", yytext); }
%%
int yywrap() { return 1; }
