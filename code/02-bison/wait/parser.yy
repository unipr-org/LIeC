%{

#include <iostream>

int yylex();

void yyerror(const char* s) {
  std::cerr << s << std::endl;
}

%}

%%

S : A
  | B;

A : 'a'
  | '(' A ')'
  ;

B : 'b'
  | '(' B '>'
  ;

%%

int main() {
  return yyparse();
}
