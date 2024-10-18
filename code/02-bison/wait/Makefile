parser: lexer.ll parser.yy
	flex -o lexer.cc lexer.ll
	bison --report=all -o parser.cc parser.yy
	g++ -Wall -Wextra -O3 -o parser lexer.cc parser.cc
