#include <iostream>

inline void
yyerror(const char* msg) {
  std::cerr << msg << std::endl;
  exit(1);
}
