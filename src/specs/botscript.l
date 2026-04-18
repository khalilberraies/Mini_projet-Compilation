%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "botscript.tab.h"
#include "wasm_bridge.h"

/* yylineno is enabled by %option yylineno */
extern int yylineno;

/* local column tracking for lexer */
static int yycol = 1;

static void bump_col(const char* txt) {
  yycol += (int)strlen(txt);
}

static void tok_keyword(const char* kw, int token) {
  wasm_record_token(TOK_MOTCLE, kw, yylineno, yycol);
  bump_col(yytext);
  yylval.chaine = strdup(yytext);
}

static void tok_simple(WasmTokenType t) {
  wasm_record_token(t, yytext, yylineno, yycol);
  bump_col(yytext);
}

static char* unescape_string(const char* s) {
  size_t n = strlen(s);
  char* out = (char*)malloc(n + 1);
  size_t j = 0;
  for (size_t i = 0; i < n; i++) {
    if (s[i] == '\\' && i + 1 < n) {
      i++;
      switch (s[i]) {
        case 'n': out[j++] = '\n'; break;
        case 'r': out[j++] = '\r'; break;
        case 't': out[j++] = '\t'; break;
        case '"': out[j++] = '"'; break;
        case '\\': out[j++] = '\\'; break;
        default: out[j++] = s[i]; break;
      }
    } else {
      out[j++] = s[i];
    }
  }
  out[j] = '\0';
  return out;
}
%}

%option noyywrap
%option yylineno

%x COMMENT

DIGIT   [0-9]
INT     {DIGIT}+
EXP     [eE][+-]?{DIGIT}+
FLOAT   ({INT}"."{DIGIT}*|{DIGIT}*"."{DIGIT}+)
NUM     ({FLOAT}|{INT})({EXP})?

%%

[ \t\r]+                { bump_col(yytext); }
\n                      { yycol = 1; }

"//".*                  { bump_col(yytext); }
"#".*                   { bump_col(yytext); }


"/*"                 { bump_col(yytext); BEGIN(COMMENT); }
<COMMENT>[^*\n]+      { bump_col(yytext); }
<COMMENT>"*"+[^*/\n]* { bump_col(yytext); }
<COMMENT>\n           { yycol = 1; }
<COMMENT>"*/"         { bump_col(yytext); BEGIN(INITIAL); }

"let"                   { tok_keyword("let", LET); return LET; }
"repeat"                { tok_keyword("repeat", REPEAT); return REPEAT; }
"if"                    { tok_keyword("if", IF); return IF; }
"else"                  { tok_keyword("else", ELSE); return ELSE; }
"while"                 { tok_keyword("while", WHILE); return WHILE; }
"forward"               { tok_keyword("forward", FORWARD); return FORWARD; }
"turn"                  { tok_keyword("turn", TURN); return TURN; }
"color"                 { tok_keyword("color", COLOR); return COLOR; }
"penDown"               { tok_keyword("penDown", PENDOWN); return PENDOWN; }
"penUp"                 { tok_keyword("penUp", PENUP); return PENUP; }


{FLOAT}{EXP}?           {
                          yylval.reel = atof(yytext);
                          wasm_record_token(TOK_REEL, yytext, yylineno, yycol);
                          bump_col(yytext);
                          return REEL;
                        }

{INT}{EXP}              {
                          yylval.reel = atof(yytext);
                          wasm_record_token(TOK_REEL, yytext, yylineno, yycol);
                          bump_col(yytext);
                          return REEL;
                        }

{INT}                   {
                          yylval.entier = atoi(yytext);
                          wasm_record_token(TOK_ENTIER, yytext, yylineno, yycol);
                          bump_col(yytext);
                          return ENTIER;
                        }

[a-zA-Z_][a-zA-Z0-9_]*  {
                          yylval.chaine = strdup(yytext);
                          wasm_record_token(TOK_IDENT, yytext, yylineno, yycol);
                          bump_col(yytext);
                          return IDENT;
                        }


\"([^\"\\]|\\.)*\"      {
                          size_t len = (size_t)yyleng;
                          char* raw = (char*)malloc(len - 1);
                          memcpy(raw, yytext + 1, len - 2);
                          raw[len - 2] = '\0';
                          char* un = unescape_string(raw);
                          yylval.chaine = un;
                          wasm_record_token(TOK_CHAINE, un, yylineno, yycol);
                          free(raw);
                          bump_col(yytext);
                          return CHAINE;
                        }

"=="                    { tok_simple(TOK_OP_REL); return EQ; }
"!="                    { tok_simple(TOK_OP_REL); return NE; }
"<="                    { tok_simple(TOK_OP_REL); return LE; }
">="                    { tok_simple(TOK_OP_REL); return GE; }

"&&"                    { tok_simple(TOK_OP_REL); return AND; }
"||"                    { tok_simple(TOK_OP_REL); return OR; }
"!"                     { tok_simple(TOK_OP_REL); return NOT; }

"<"                     { tok_simple(TOK_OP_REL); return '<'; }
">"                     { tok_simple(TOK_OP_REL); return '>'; }
"="                     { tok_simple(TOK_AFFECT); return '='; }

"+"                     { tok_simple(TOK_OP_ARTHM); return '+'; }
"-"                     { tok_simple(TOK_OP_ARTHM); return '-'; }
"*"                     { tok_simple(TOK_OP_ARTHM); return '*'; }
"/"                     { tok_simple(TOK_OP_ARTHM); return '/'; }

"{"                     { tok_simple(TOK_PUNCT); return '{'; }
"}"                     { tok_simple(TOK_PUNCT); return '}'; }
"("                     { tok_simple(TOK_PUNCT); return '('; }
")"                     { tok_simple(TOK_PUNCT); return ')'; }
";"                     { tok_simple(TOK_PUNCT); return ';'; }
","                     { tok_simple(TOK_PUNCT); return ','; }

.                       {
                          char msg[128];
                          snprintf(msg, sizeof(msg), "Caractère inattendu: '%s'", yytext);
                          wasm_record_error("LEXICAL", msg, yylineno, yycol);
                          wasm_record_token(TOK_ERROR, yytext, yylineno, yycol);
                          bump_col(yytext);
                          return yytext[0];
                        }

%%