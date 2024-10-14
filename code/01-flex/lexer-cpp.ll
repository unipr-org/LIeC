  /* THIS IS THE DEFINITION SECTION */

%{

#include <iostream>
#include <string>

inline int print_token(const char* kind) {
  std::cout << "token at line " << yylineno << ": (" << kind << " -> \"" << yytext << "\")" << std::endl;
  return 1;
}

inline int print_keyword() { return print_token("keyword"); }
inline int print_identifier() { return print_token("identifier"); }
inline int print_integer() { return print_token("integer"); }
inline int print_floating() { return print_token("floating"); }
inline int print_character() { return print_token("character"); }
inline int print_string() { return print_token("string"); }
inline int print_punctuator() { return print_token("punctuator"); }
inline int print_comment() { return print_token("comment"); }

inline void print_error() {
  std::cerr << "ERROR: rejecting lexeme <LEXEME>"
            << yytext
            << "<LEXEME>" << std::endl;
  yy_fatal_error("Exiting");
}

%}

%option noyywrap
%option nounput
%option nodefault
%option yylineno

%x comment_mode

DIGIT           [0-9]
NONZERO_DIGIT   [1-9]
BIN_DIGIT       [01]
OCT_DIGIT       [0-7]
HEX_DIGIT       [0-9a-fA-F]

HEX_QUAD        {HEX_DIGIT}{4}
UCN             "\\u"{HEX_QUAD}|"\\U"{HEX_QUAD}{HEX_QUAD}

NONDIGIT        [a-zA-Z_]

IDENT_NONDIGIT  {NONDIGIT}|{UCN}

BIN_PREFIX      "0b"|"0B"
HEX_PREFIX      "0x"|"0X"
SEP_OPT         "'"?

BIN_SEQ         {BIN_DIGIT}({SEP_OPT}{BIN_DIGIT})*
DEC_SEQ         {DIGIT}({SEP_OPT}{DIGIT})*
HEX_SEQ         {HEX_DIGIT}({SEP_OPT}{HEX_DIGIT})*

BIN_LITERAL     {BIN_PREFIX}{BIN_SEQ}
OCT_LITERAL     0({SEP_OPT}{OCT_DIGIT})*
DEC_LITERAL     {NONZERO_DIGIT}({SEP_OPT}{DIGIT})*
HEX_LITERAL     {HEX_PREFIX}{HEX_SEQ}

U_SUFFIX        u|U
L_SUFFIX        l|L
LL_SUFFIX       ll|LL
INT_SUFFIX      ({U_SUFFIX}{L_SUFFIX}?)|({U_SUFFIX}{LL_SUFFIX})|({L_SUFFIX}{U_SUFFIX}?)|({LL_SUFFIX}{U_SUFFIX}?)

ENC_PREFIX      u8|u|U|L
SIMPLE_ESCAPE   [\\]['"\?\\abfnrtv]
OCT_ESCAPE      [\\]{OCT_DIGIT}{1,3}
HEX_ESCAPE      [\\]x{HEX_DIGIT}+
ESCAPED_CHAR    {SIMPLE_ESCAPE}|{OCT_ESCAPE}|{HEX_ESCAPE}

C_CHAR          [^'\\\n]|{ESCAPED_CHAR}|{UCN}
S_CHAR          [^"\\\n]|{ESCAPED_CHAR}|{UCN}

FRACT           ({DEC_SEQ}?"."{DEC_SEQ})|({DEC_SEQ}".")
EXP             [eE][+-]?{DEC_SEQ}
HEX_FRACT       ({HEX_SEQ}?"."{HEX_SEQ})|({HEX_SEQ}".")
BIN_EXP         [pP][+-]?{DEC_SEQ}
FLOAT_SUFFIX    [flFL]

%%
  /* THIS IS THE RULE SECTION */

  /* -------------------- keywords -------------------- */

alignas |
alignof |
asm |
auto |
bool |
break |
case |
catch |
char |
char16_t |
char32_t |
class |
concept |
const |
constexpr |
const_cast |
continue |
decltype |
default |
delete |
do |
double |
dynamic_cast |
else |
enum |
explicit |
export |
extern |
false |
float |
for |
friend |
goto |
if |
inline |
int |
long |
mutable |
namespace |
new |
noexcept |
nullptr |
operator |
private |
protected |
public |
register |
reinterpret_cast |
requires |
return |
short |
signed |
sizeof |
static |
static_assert |
static_cast |
struct |
switch |
template |
this |
thread_local |
throw |
true |
try |
typedef |
typeid |
typename |
union |
unsigned |
using |
virtual |
void |
volatile |
wchar_t |
while { return print_keyword(); }


  /* -------------------- punctuators -------------------- */

"{"|"<%" |
"}"|"%>" |
"["|"<:" |
"]"|":>" |
"#"|"%:" |
"##"|"%:%:" |
"(" |
")" |
";" |
":" |
"..." |
"?" |
"::" |
"." |
".*" |
"->" |
"->*" |
"~"|compl |
"!"|not |
"+" |
"-" |
"*" |
"/" |
"%" |
"^"|xor |
"&"|bitand |
"|"|bitor |
"=" |
"+=" |
"-=" |
"*=" |
"/=" |
"%=" |
"^="|xor_eq |
"&="|and_eq |
"|="|or_eq |
"==" |
"!="|not_eq |
"<" |
">" |
"<=" |
">=" |
"<=>" |
"&&"|and |
"||"|or |
"<<" |
">>" |
"<<=" |
">>=" |
"++" |
"--" |
","  { return print_punctuator(); }


  /* -------------------- identifiers -------------------- */

{IDENT_NONDIGIT}({IDENT_NONDIGIT}|{DIGIT})*  { return print_identifier(); }


  /* -------------------- literals -------------------- */

  /* (binary, octal, decimal, or hex) integer literal */
{BIN_LITERAL}{INT_SUFFIX}? |
{OCT_LITERAL}{INT_SUFFIX}? |
{DEC_LITERAL}{INT_SUFFIX}? |
{HEX_LITERAL}{INT_SUFFIX}? { return print_integer(); }

  /* char literal */
{ENC_PREFIX}?"'"{C_CHAR}+"'"  { return print_character(); }

  /* (decimal or hex) floating literal */
{FRACT}{EXP}?{FLOAT_SUFFIX}? |
{DEC_SEQ}{EXP}{FLOAT_SUFFIX}? |
{HEX_PREFIX}{HEX_FRACT}{BIN_EXP}{FLOAT_SUFFIX}? |
{HEX_PREFIX}{HEX_SEQ}{BIN_EXP}{FLOAT_SUFFIX}?   { return print_floating(); }

  /* string literal (except raw string literals) */
{ENC_PREFIX}?\"{S_CHAR}*\"  { return print_string(); }


  /* -------------------- comments -------------------- */

  /* C++ single line comment */
"//".*             { return print_comment(); }

  /* C style comment */
"/*"               { BEGIN comment_mode; }  /* enter comment mode */
<comment_mode>"*/" { BEGIN INITIAL; }       /* exit comment mode */
<comment_mode>.    /* discard any char but \n */
<comment_mode>"\n" /* discard new line */


  /* -------------------- whitespace -------------------- */

[ \f\n\t\v]        /* discard */

"\\\n"             /* discard */

  /* -------------------- errors -------------------- */

. { print_error(); return 0; }


%%
  /* THIS IS THE USER CODE SECTION */

int main() {
  while (yylex() != 0);
  return 0;
}
