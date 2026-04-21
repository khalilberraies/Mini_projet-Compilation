%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int yylex(void);
int yyerror(char *s);
int nb_colonnes = 0;
%}

%union {
    int   entier;
    char *chaine;
}

%token CREATE TABLE VARCHAR
%token <entier> NB
%token <chaine> ID

%%
requete : CREATE TABLE ID '(' colonnes ')'
            {
              printf("Requete valide !\n");
              printf("Table : %s\n", $3);
              printf("Nombre de colonnes : %d\n", nb_colonnes);
            }
        ;

colonnes : colonne
         | colonnes ',' colonne
         ;

colonne : ID VARCHAR '(' NB ')'
            {
              printf("  - colonne '%s'  type varchar(%d)\n", $1, $4);
              nb_colonnes++;
            }
        ;
%%
#include "lex.yy.c"

int yyerror(char *s) {
    printf("Erreur syntaxique : %s\n", s);
    return 0;
}
int main() {
    int res = yyparse();
    if (res == 0) printf("Analyse reussie (YYACCEPT).\n");
    else          printf("Analyse echouee (YYABORT).\n");
    return 0;
}
