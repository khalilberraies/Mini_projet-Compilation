%{
#include <stdio.h>
%}

%%
(aa|bb)*((ab|ba)(aa|bb)*(ab|ba)(aa|bb)*)*  { printf("[%s]: nombre pair de a et de b\n", yytext); }
a*b*                                         { printf("[%s]: des a d'abord et des b ensuite\n", yytext); }
[ \t\n]                                      { /* ignore whitespace */ }
.                                            { /* ignore other characters */ }
%%

int yywrap() {
    return 1;
}

int main() {
    yylex();
    return 0;
}
