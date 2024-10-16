%{

#include "calc.hh"
#include "calc.parse.hh"

int yylex();

void print_prompt() {
  std::cout << "> " << std::flush;
}

%}

  /* declare tokens */
%token NUMBER
%token EOL

%%

calclist:
    /* epsilon */     { print_prompt(); }
  | calclist expr EOL { print_prompt(); }
  | calclist EOL      { print_prompt(); }

expr:
    term
  | expr '+' term
  | expr '-' term
  ;

term:
    factor
  | term '*' factor
  | term '/' factor
  ;

factor:
    NUMBER
  | '(' expr ')'
  ;

%%

int main() {
  return yyparse();
}
