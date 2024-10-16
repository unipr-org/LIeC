%option noyywrap nodefault nounput yylineno

%%

"a" |
"b" |
"(" |
")" |
">" { return *yytext; }

[ \t\n]       { /* ignore whitespace */ }
.             { abort(); }

%%
