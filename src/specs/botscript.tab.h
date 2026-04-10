#ifndef BOTSCRIPT_TAB_H
#define BOTSCRIPT_TAB_H

/* Token definitions for Bison */
#ifndef YYSTYPE
typedef union {
    int entier;
    double reel;
    char *chaine;
} YYSTYPE;
#endif

extern YYSTYPE yylval;

#define ENTIER 258
#define REEL 259
#define IDENT 260
#define CHAINE 261
#define LET 262
#define REPEAT 263
#define IF 264
#define ELSE 265
#define WHILE 266
#define FORWARD 267
#define TURN 268
#define COLOR 269
#define PENDOWN 270
#define PENUP 271
#define EQ 272
#define NE 273
#define LE 274
#define GE 275

#endif /* BOTSCRIPT_TAB_H */
