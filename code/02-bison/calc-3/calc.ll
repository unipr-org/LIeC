%{

#include "calc.hh"
#include "calc.parse.hh"
#include <string>

%}

%option noyywrap nodefault nounput yylineno

DIGITS [0-9]+
FRAC   ({DIGITS}?"."{DIGITS})|({DIGITS}".")
EXP    [Ee][-+]?{DIGITS}
FLOAT  {FRAC}{EXP}?
INT    {DIGITS}

%%

"+" |
"-" |
"*" |
"/" |
"(" |
")"           { return *yytext; }

{INT}|{FLOAT} {
                yylval.postfix = new std::list<std::string>;
                yylval.postfix->push_back(yytext);
                return NUMBER;
              }

"\n"          { return EOL; }

"//".*        { /* ignore comments */ }
[ \t]         { /* ignore whitespace */ }
.             {
                auto msg = std::string("Unknown character: ") + *yytext;
                yyerror(msg.c_str());
              }

%%

