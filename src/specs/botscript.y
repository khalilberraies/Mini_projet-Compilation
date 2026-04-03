%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);
%}

%union {
    int entier;
    double reel;
    char *chaine;
}

%token <entier> ENTIER
%token <reel> REEL
%token <chaine> IDENT CHAINE
%token LET REPEAT IF ELSE WHILE FORWARD TURN COLOR PENDOWN PENUP
%token EQ NE LE GE

%left '+' '-'
%left '*' '/'
%nonassoc '<' '>' EQ NE LE GE

%%

program:
    statements
    ;

statements:
    statement
    | statements statement
    ;

statement:
    var_decl
    | assignment
    | repeat_loop
    | if_stmt
    | command
    ;

var_decl:
    LET IDENT '=' expression ';' { printf("Déclaration de variable: %s\n", $2); }
    ;

assignment:
    IDENT '=' expression ';' { printf("Affectation: %s\n", $1); }
    ;

repeat_loop:
    REPEAT expression '{' statements '}' { printf("Boucle repeat\n"); }
    ;

if_stmt:
    IF '(' expression ')' '{' statements '}'
    | IF '(' expression ')' '{' statements '}' ELSE '{' statements '}'
    ;

command:
    FORWARD '(' expression ')' ';'
    | TURN '(' expression ')' ';'
    | COLOR '(' CHAINE ')' ';'
    | PENDOWN '(' ')' ';'
    | PENUP '(' ')' ';'
    ;

expression:
    ENTIER          { $$ = $1; }
    | REEL          { $$ = $1; }
    | IDENT         { /* lookup variable */ }
    | expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression { $$ = $1 / $3; }
    | '(' expression ')' { $$ = $2; }
    | expression '<' expression { $$ = $1 < $3; }
    | expression '>' expression { $$ = $1 > $3; }
    | expression EQ expression { $$ = $1 == $3; }
    | expression NE expression { $$ = $1 != $3; }
    | expression LE expression { $$ = $1 <= $3; }
    | expression GE expression { $$ = $1 >= $3; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erreur syntaxique à la ligne %d: %s\n", yylineno, s);
}

int main() {
    yyparse();
    return 0;
}
