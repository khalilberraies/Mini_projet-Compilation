#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "botscript.tab.h"

/* Global variables mimicking Flex */
char *yytext;
int yylineno = 1;
YYSTYPE yylval;

/* Simplified yylex function */
int yylex() {
    static char buffer[1024];
    int c;

    /* Skip whitespace */
    while ((c = getchar()) != EOF && (c == ' ' || c == '\t' || c == '\r' || c == '\n')) {
        if (c == '\n') yylineno++;
    }

    if (c == EOF) return 0;

    /* Handle numbers */
    if (isdigit(c)) {
        int i = 0;
        buffer[i++] = c;
        while ((c = getchar()) != EOF && (isdigit(c) || c == '.')) {
            buffer[i++] = c;
        }
        ungetc(c, stdin);
        buffer[i] = '\0';
        yytext = buffer;
        if (strchr(buffer, '.')) {
            yylval.reel = atof(buffer);
            return REEL;
        } else {
            yylval.entier = atoi(buffer);
            return ENTIER;
        }
    }

    /* Handle identifiers and keywords */
    if (isalpha(c) || c == '_') {
        int i = 0;
        buffer[i++] = c;
        while ((c = getchar()) != EOF && (isalnum(c) || c == '_')) {
            buffer[i++] = c;
        }
        ungetc(c, stdin);
        buffer[i] = '\0';
        yytext = buffer;

        if (strcmp(buffer, "let") == 0) return LET;
        if (strcmp(buffer, "repeat") == 0) return REPEAT;
        if (strcmp(buffer, "if") == 0) return IF;
        if (strcmp(buffer, "else") == 0) return ELSE;
        if (strcmp(buffer, "while") == 0) return WHILE;
        if (strcmp(buffer, "forward") == 0) return FORWARD;
        if (strcmp(buffer, "turn") == 0) return TURN;
        if (strcmp(buffer, "color") == 0) return COLOR;
        if (strcmp(buffer, "penDown") == 0) return PENDOWN;
        if (strcmp(buffer, "penUp") == 0) return PENUP;

        yylval.chaine = strdup(buffer);
        return IDENT;
    }

    /* Handle operators and punctuation */
    buffer[0] = c;
    buffer[1] = '\0';
    yytext = buffer;
    return c;
}
