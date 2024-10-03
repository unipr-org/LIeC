%{

#include <stdio.h>
#include <string.h>

enum P_LANGUAGE {
	KEY_W = 1,
	IDENT,
	BOOL,
	INTEGER,
	LONG,
	UNSIGNED,
	FLOAT,
	DOUBLE,
	CHAR,
	STRING,
	PUNCTUATOR,
	COMMENT,
	GARBAGE
};

%}

%x COMMENT_MODE

%%

	/* RULES SECTION */

	/* Keywords */

bool {return BOOL;}
char {return CHAR;}
const {return KEY_W;}
do {return KEY_W;}
double {return DOUBLE;}
else {return KEY_W;}
float {return FLOAT;}
for {return KEY_W;}
if {return KEY_W;}
int {return INTEGER;}
long {return LONG;}
return {return KEY_W;}
unsigned {return UNSIGNED;}
while {return KEY_W;}

	/* Whitespaces */

[ \f\n\t\v] /* discard */

. {}

%%
int main() {
	char lexem[1024];
	int res = 0;

	while (1) {
		res = yylex();
		if (res > 0) {
			printf("%s\n", yytext);
		}
		else {
				break;
		}
	}

	printf("END WHILE LOOP\n");

	return 0;
}

