%{
	#include <stdio.h>
	#include <string.h>
	#include "cgen.h"
	#include <math.h>
	#include "myanalyzer.tab.h"

	int line_num = 1;

%}

ID      	[a-zA-Z][0-9a-zA-Z_]*   
DIGIT   	[0-9]
INT  		{DIGIT}{DIGIT}*
DECIMAL 	("."{INT})|({INT}("."{INT}?)?)
REAL   		{DECIMAL}([eE][+-]?{INT})?
CHARACTER   [., a-zA-Z0-9\-+\*\/:_$!#@&~^()]|[\\n]|[\\t]|[\\r]|[\\\\]
STRING 		\"{CHARACTER}*\"

%x comment 

%%

integer 	 return KW_INTEGER;
scalar 		 return KW_SCALAR;
str 		 return KW_STR;
boolean 	 return KW_BOOLEAN;
True 		 return KW_TRUE;
False 		 return KW_FALSE;
const 		 return KW_CONST;
if 		 	 return KW_IF;
else 		 return KW_ELSE;
endif 		 return KW_ENDIF;
for 		 return KW_FOR;
in 		 	 return KW_IN;
endfor 		 return KW_ENDFOR;
while 		 return KW_WHILE;
endwhile 	 return KW_ENDWHILE;
break 		 return KW_BREAK;
continue 	 return KW_CONTINUE;
not 		 return KW_NOT;
and 		 return KW_AND;
or 			 return KW_OR;
def 		 return KW_DEF;
enddef 		 return KW_ENDDEF;
main 		 return KW_MAIN;
return 		 return KW_RETURN;
comp 		 return KW_COMP;
endcomp 	 return KW_ENDCOMP;


{ID}        { yylval.str = strdup(yytext); return TK_IDENT; }
{INT}    	{ yylval.str = strdup(yytext); return TK_INT; }
{DECIMAL}	{ yylval.str = strdup(yytext); return TK_DECIMAL; }
{REAL}      { yylval.str = strdup(yytext); return TK_REAL; }
{STRING} 	{ yylval.str = strdup(yytext); return TK_STRING;}

"-"		return '-';
"+"		return '+';
"*"		return '*';
"/"		return '/';
"%"		return '%';

"="		return '=';
";" 	return ';';
")"		return ')';
"("		return '(';
"["		return '[';
"]"		return ']';
","		return ',';
":"		return ':';

"**" 	return OP_POWER;

"=="	return OP_EQUAL;
"!="	return OP_NOT_EQUAL;
"<"		return OP_LESS;
"<="	return OP_LESS_EQUAL;
">"		return OP_MORE;
">="	return OP_MORE_EQUAL;

"+="    return OP_PLUS_EQUAL;
"-="	return OP_MINUS_EQUAL;
"*="	return OP_MULT_EQUAL;
"/="	return OP_DIV_EQUAL;
"%="	return OP_MOD_EQUAL;

"#" 	return KW_HASH;

"--"[^\n]*  printf("//Line %d: line comment: %s\n", line_num, yytext); /* skip line comments */


"/*"                    { BEGIN(comment); printf("comment started at line: %d\n", line_num); }

<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n             ++line_num;
<comment>"*"+"/"        { BEGIN(INITIAL); printf("comment ended at line: %d\n", line_num); }


[ \r\t]+		/* skip whitespace */
\n 				++line_num;

<<EOF>> 		return EOF;
.           { printf("Line %d Lexical Error: Unrecognized literal %s\n", line_num, yytext); }

%%