%{
#include <stdio.h>
int yylex(void);
int yyerror(char *s);
%}
%%
mot : S '$' { printf("mot correct\n"); getchar(); }
    ;

S : 'a' S 'a'
  | 'b' S 'b'
  | 'c'
  ;
%%
int yylex() {
    char c = getchar();
    if (c=='a' || c=='b' || c=='c' || c=='$')
        return c;
    else {
        printf("erreur lexicale\n");
        return 0;
    }
}

int yyerror(char *s) {
    printf("%s\n", s);
    return 0;
}

int main() {
    yyparse();
    printf("\n");
    return 0;
}
