calc: calc.hh calc.ll calc.yy
	flex -o calc.lex.cc calc.ll
	bison --report=all --defines=calc.parse.hh -o calc.parse.cc calc.yy
	g++ -Wall -Wextra -O3 -o calc.lex.o -c calc.lex.cc
	g++ -Wall -Wextra -O3 -o calc.parse.o -c calc.parse.cc
	g++ -o calc calc.lex.o calc.parse.o

clean:
	rm -f calc.lex.* calc.parse.* calc.output calc
