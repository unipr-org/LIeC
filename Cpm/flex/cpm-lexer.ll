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

	CONST_INT,
	CONST_FLOAT,
	CONST_CHAR,

	GARBAGE
};

%}

%option noyywrap
%option nounput
%option nodefault
%option yylineno

	/*ATTENZIONE: non mettere spazi tra `|'*/

	/* Constants */

DIGIT [0-9]
DIGIT_SEQUENCE (({DIGIT})|([1-9]{DIGIT}+))
DECIMAL_CONSTANT {DIGIT_SEQUENCE}
INTEGER_CONSTANT {DECIMAL_CONSTANT}{INTEGER_SUFFIX}?
INTEGER_SUFFIX {UNSIGNED_SUFFIX}{LONG_SUFFIX}?|{LONG_SUFFIX}{UNSIGNED_SUFFIX}?
LONG_SUFFIX [lL]
UNSIGNED_SUFFIX [uU]

FLOATING_CONSTANT {DECIMAL_FLOATING_CONSTANT}
DECIMAL_FLOATING_CONSTANT {FRACTIONAL_CONSTANT}{EXPONENT_PART}?{FLOATING_SUFFIX}?|{DIGIT_SEQUENCE}{EXPONENT_PART}{FLOATING_SUFFIX}?
FRACTIONAL_CONSTANT ({DIGIT_SEQUENCE}?"."{DIGIT_SEQUENCE})|({DIGIT_SEQUENCE}".")
EXPONENT_PART [eE]{SIGN}?{DIGIT_SEQUENCE}
SIGN [+-]
FLOATING_SUFFIX [flFL]

NONDIGIT [_a-zA-Z]

	/* String literals */
STRING_LITERAL ("\""{S_CHAR_SEQUENCE}?"\"")|("L\""{S_CHAR_SEQUENCE}?"\"")
S_CHAR_SEQUENCE {S_CHAR}+
S_CHAR [^\"\\\n]



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

	/* Integer constants */

{INTEGER_CONSTANT} {return CONST_INT;}

	/* Floating constants */

{FLOATING_CONSTANT} {return CONST_FLOAT;}

	/* String literals */
{STRING_LITERAL}

	/* Whitespaces */

[ \f\n\t\v] /* discard */

. {}

%%
int main() {
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

