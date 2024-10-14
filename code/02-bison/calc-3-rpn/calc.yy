%{

#include "calc.hh"
#include "calc.parse.hh"

#include <cstddef>

int yylex();

void print_prompt() {
  std::cout << "> " << std::flush;
}

void print_result(double d) {
  std::cout << "eval: " << d << std::endl;
}

%}

%union{
  double d;
};

  /* declare tokens */
%token <d> NUMBER
%token EOL
%type <d> expr

%%

calclist:
    /* epsilon */     { print_prompt(); }
  | calclist expr EOL {
                        print_result($2);
                        print_prompt();
                      }
  | calclist EOL      { print_prompt(); }

expr:
    NUMBER
  | expr expr '+' { $$ = $1 + $2; }
  | expr expr '-' { $$ = $1 - $2; }
  | expr expr '*' { $$ = $1 * $2; }
  | expr expr '/' { $$ = $1 / $2; }
  ;

%%

int main() {
  return yyparse();
}
