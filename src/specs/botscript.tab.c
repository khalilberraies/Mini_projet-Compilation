#include <stdio.h>
#include <stdlib.h>
#include "botscript.tab.h"

/* Externals from Lexer */
extern int yylex();
extern char *yytext;
extern int yylineno;

/* Parser state */
int yychar;
YYSTYPE yylval;

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

/* Simplified yyparse function */
int yyparse() {
    yychar = yylex();
    while (yychar != 0) {
        /* This would normally be a large state machine */
        /* For demonstration, we just print the tokens */
        printf("Parsed token %d with value %s\n", yychar, yytext);
        yychar = yylex();
    }
    return 0;
}

/* Main entry point for the C version */
int main(int argc, char **argv) {
    if (argc > 1) {
        if (!(freopen(argv[1], "r", stdin))) {
            perror(argv[1]);
            return 1;
        }
    }
    return yyparse();
}
