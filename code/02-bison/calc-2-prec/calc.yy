%{

#include "calc.hh"
#include "calc.parse.hh"

#include <cmath>
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
%token UMINUS
%token EOL
%type <d> expr

%left '+' '-'
%left '*' '/'
%right '^'
%nonassoc UMINUS

%%

calclist:
    /* epsilon */     { print_prompt(); }
  | calclist expr EOL { print_result($2); print_prompt(); }
  | calclist EOL      { print_prompt(); }

expr:
    NUMBER
  | expr '+' expr  { $$ = $1 + $3; }
  | expr '-' expr  { $$ = $1 - $3; }
  | expr '*' expr  { $$ = $1 * $3; }
  | expr '/' expr  { $$ = $1 / $3; }
  | expr '^' expr  { $$ = std::pow($1, $3); }
  | '+' expr %prec UMINUS { $$ =  $2; }
  | '-' expr %prec UMINUS { $$ = -$2; }
  | '(' expr ')' { $$ = $2; }
  ;

%%

int main() {
  return yyparse();
}
