%{

#include "calc.hh"
#include "calc.parse.hh"

#include <cstddef>

int yylex();

void print_prompt() {
  std::cout << "> " << std::flush;
}

void print_result(const double& d) {
  std::cout << "eval: " << d << std::endl;
}

%}

%union{
  double d;
};

  /* declare tokens */
%token <d> NUMBER
%token EOL
%type <d> factor term expr

%%

calclist:
    /* epsilon */     { print_prompt(); }
  | calclist expr EOL { print_result($2); print_prompt(); }
  | calclist EOL      { print_prompt(); }

expr:
    term
  | expr '+' term  { $$ = $1 + $3; }
  | expr '-' term  { $$ = $1 - $3; }
  ;

term:
    factor
  | term '*' factor  { $$ = $1 * $3; }
  | term '/' factor  { $$ = $1 / $3; }
  ;

factor:
    NUMBER
  | '(' expr ')'     { $$ = $2; }
  ;

%%

int main() {
  return yyparse();
}
