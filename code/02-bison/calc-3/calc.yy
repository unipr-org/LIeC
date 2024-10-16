%{

#include "calc.hh"
#include "calc.parse.hh"

#include <algorithm>
#include <cstddef>
#include <iterator>

int yylex();
void yyerror(const char* msg);

void print_prompt() {
  std::cout << "> " << std::flush;
}

void make_postfix(postfix_t res,
                  postfix_t arg1, postfix_t arg2, const char* op) {
  res = arg1;
  arg1 = nullptr;
  res->splice(res->end(), *arg2);
  delete arg2;
  res->push_back(op);
}

void print_result(postfix_t res) {
  std::cout << "postfix form: ";
  std::ostream_iterator<std::string> out(std::cout, " ");
  std::copy(res->begin(), res->end(), out);
  std::cout << std::endl;
}

%}

%union{
  postfix_t postfix;
};

  /* declare tokens */
%token <postfix> NUMBER
%token EOL
%type <postfix> factor term expr

%%

calclist:
    /* epsilon */     { print_prompt(); }
  | calclist expr EOL {
                        print_result($2);
                        delete $2;
                        print_prompt();
                      }
  | calclist EOL      { print_prompt(); }

expr:
    term
  | expr '+' term  { make_postfix($$, $1, $3, "+"); }
  | expr '-' term  { make_postfix($$, $1, $3, "-"); }
  ;

term:
    factor
  | term '*' factor  { make_postfix($$, $1, $3, "*"); }
  | term '/' factor  { make_postfix($$, $1, $3, "/"); }
  ;

factor:
    NUMBER
  | '(' expr ')'     { $$ = $2; }
  ;

%%

int main() {
  return yyparse();
}
