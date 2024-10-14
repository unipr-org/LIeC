#include <iostream>
#include <list>
#include <string>

using postfix_t = std::list<std::string>*;

inline void
yyerror(const char* msg) {
  std::cerr << msg << std::endl;
  exit(1);
}
