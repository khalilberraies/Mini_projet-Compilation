%{
#include <stdio.h>
int line_count = 0;
int word_count = 0;
int char_count = 0;
int sum_numbers = 0;
int in_word = 0;
%}

%%
[0-9]+      { sum_numbers += atoi(yytext); char_count += yyleng; }
[a-zA-Z]+   { word_count++; char_count += yyleng; }
\n          { line_count++; char_count++; }
[ \t]       { char_count++; }
.           { char_count++; }
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
    
    printf("Nombre de lignes: %d\n", line_count);
    printf("Nombre de mots: %d\n", word_count);
    printf("Nombre de caractères: %d\n", char_count);
    printf("Somme des nombres: %d\n", sum_numbers);
    
    return 0;
}
