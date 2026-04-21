%{
#include <stdio.h>
#include <stdlib.h>
#include "exercice1.tab.h"
%}
%%
[0-9]+          { yylval.entier = atoi(yytext); return NB; }
"somme"         { return SOM; }
"produit"       { return PROD; }
"soustraction"  { return SOUS; }
"division"      { return DIV; }
[,]             { return yytext[0]; }
[.]             { return yytext[0]; }
[$]             { return FIN; }
[ \t\n\r]       { }
.               { printf("Erreur lexicale: %s\n", yytext); }
%%
int yywrap() { return 1; }
