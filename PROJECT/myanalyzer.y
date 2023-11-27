%{
	#include <stdio.h>
  #include "cgen.h"
  #include <string.h>
	#include "kappalib.h"
	
  extern int yylex(void);
  extern int line_num;

%}

%union {
	char* str;
}

%define parse.error verbose

%token <str> TK_IDENT
%token <str> TK_INT 
%token <str> TK_DECIMAL
%token <str> TK_REAL 
%token <str> TK_STRING 

%token KW_INTEGER
%token KW_SCALAR
%token KW_STR
%token KW_BOOLEAN
%token KW_DECIMAL
%token KW_TRUE
%token KW_FALSE
%token KW_CONST
%token KW_IF
%token KW_ELSE
%token KW_ENDIF
%token KW_FOR
%token KW_IN
%token KW_ENDFOR
%token KW_WHILE
%token KW_ENDWHILE
%token KW_BREAK
%token KW_CONTINUE
%token KW_NOT
%token KW_AND
%token KW_OR
%token KW_DEF
%token KW_ENDDEF
%token KW_MAIN
%token KW_RETURN
%token KW_COMP
%token KW_ENDCOMP

%token <str> OP_POWER
%token KW_HASH

%token <str> OP_EQUAL
%token <str> OP_NOT_EQUAL
%token <str> OP_LESS
%token <str> OP_LESS_EQUAL
%token <str> OP_MORE
%token <str> OP_MORE_EQUAL

%token <str> OP_PLUS_EQUAL
%token <str> OP_MINUS_EQUAL
%token <str> OP_MULT_EQUAL
%token <str> OP_DIV_EQUAL
%token <str> OP_MOD_EQUAL

%type <str> body 
%type <str> func 
%type <str> func_input
%type <str> func_body 
%type <str> func_call
%type <str> main_func 
%type <str> ident 
%type <str> ident_init 
%type <str> equations
%type <str> var 
%type <str> const 
%type <str> comp
%type <str> comp_var
%type <str> comp_var_hash 
%type <str> expr 
%type <str> stmt
//%type <str> more_stmt
%type <str> parameters 
%type <str> data_type
%type <str> keys
%type <str> if
%type <str> for_loop
%type <str> assign
%type <str> while_loop


%start input

/* -------- PRIORITIES --------- */
//%right '#'

%right KW_NOT
%right SIGN_OP //for sign operators
%right OP_POWER
//%left '(' ')'
%left '*' '/' '%'
%left '+' '-'
//%right '='
%left OP_EQUAL OP_NOT_EQUAL OP_LESS OP_LESS_EQUAL OP_MORE OP_MORE_EQUAL
%left OP_PLUS_EQUAL OP_MINUS_EQUAL OP_MULT_EQUAL OP_DIV_EQUAL OP_MOD_EQUAL
%left KW_AND
%left KW_OR
%nonassoc KW_ELSE

%%

input: 
	body  
	{
		if (yyerror_count == 0) {
			puts("#include <math.h>\n");
      puts(c_prologue);
			printf("%s\n", $1);	
    }
	}
	;

ident:
        TK_IDENT                  	{$$ = $1;}
      | TK_IDENT ',' ident    			{$$ = template("%s, %s", $1, $3);}
      //| TK_IDENT '[' ']'            {$$ = template("%s[]", $1);}
      //| TK_IDENT '[' ']' ',' ident  {$$ = template("%s[], %s", $1, $5);}
      ;

ident_init:
            TK_IDENT '=' expr ':'                   {$$ = template("%s = %s", $1, $3);}
          | TK_IDENT '=' expr ',' ident_init ':'    {$$ = template("%s = %s , %s", $1, $3, $5);}
				  ;


equations:
          TK_IDENT '=' expr ';' 					        {$$ = template("%s = %s;\n", $1, $3);}
        | TK_IDENT '[' TK_INT ']' '=' expr ';'		{$$ = template("%s[%s] = %s\n;", $1, $3, $6);}
        | TK_IDENT OP_EQUAL expr ';' 					    {$$ = template("%s == %s;\n", $1, $3);}
        | TK_IDENT OP_NOT_EQUAL expr ';' 					{$$ = template("%s != %s;\n", $1, $3);}
        | TK_IDENT OP_LESS expr ';' 					    {$$ = template("%s < %s;\n", $1, $3);}
        | TK_IDENT OP_LESS_EQUAL expr ';' 				{$$ = template("%s <= %s;\n", $1, $3);}
        | TK_IDENT OP_MORE expr ';' 					    {$$ = template("%s > %s;\n", $1, $3);}
        | TK_IDENT OP_MORE_EQUAL expr ';' 				{$$ = template("%s >= %s;\n", $1, $3);}
        | TK_IDENT OP_PLUS_EQUAL expr ';' 				{$$ = template("%s += %s;\n", $1, $3);}
        | TK_IDENT OP_MINUS_EQUAL expr ';' 				{$$ = template("%s -= %s;\n", $1, $3);}
        | TK_IDENT OP_MULT_EQUAL expr ';' 				{$$ = template("%s *= %s;\n", $1, $3);}
        | TK_IDENT OP_DIV_EQUAL expr ';' 					{$$ = template("%s /= %s;\n", $1, $3);}
        | TK_IDENT OP_MOD_EQUAL expr ';' 					{$$ = template("%s %= %s;\n", $1, $3);}
        | TK_IDENT '=' func_call                  {$$ = template("%s = %s", $1, $3);}
        //| TK_IDENT'(' func_input ')' ';'          {$$ = template("%s(%s);", $1, $3);}
        //| TK_IDENT '=' '(' expr ')' ';'           {$$ = template("%s = (%s)", $1, $4);}
        //| '(' expr ')'                            {$$ = template("(%s)", $2);}
        ;

var:
		  ident ':' data_type ';'  			            {$$ = template("%s %s;\n", $3, $1);}
		| TK_IDENT'['TK_INT']'  ':' data_type ';' 	{$$ = template("%s %s[%s];\n", $6, $1, $3);}
		| TK_IDENT'['']' ':' data_type ';'  		    {$$ = template("%s %s[];\n", $5, $1);}
    | ident ':' TK_IDENT ';'                    {$$ = template("%s %s;\n", $3, $1);}
		;


const:
    	KW_CONST ident_init data_type ';'         {$$ = template("const %s %s;\n", $3, $2);}
    	;

//---------------------------------------- COMP --------------------------------------------------------

comp_var_hash:
                KW_HASH TK_IDENT                      {$$ = template("%s", $2);}
              | KW_HASH TK_IDENT ',' comp_var_hash    {$$ = template("%s, %s", $2, $4);}
              ;

comp_var:
          comp_var_hash ':' data_type ';'                   {$$ = template("%s %s;\n", $3, $1);}
        | comp_var_hash ':' data_type ';' comp_var          {$$ = template("%s %s;\n%s", $3, $1, $5);}
        ;

comp:
	    KW_COMP TK_IDENT ':' comp_var func_body KW_ENDCOMP ';'      {$$ = template("typedef struct %s{\n%s}%s\n %s\n", $2, $4, $2, $5);}
	    ;

//-------------------------------------- EXPRESSIONS ---------------------------------------------------

expr:
		  KW_NOT expr					        {$$ = template("NOT %s", $2);}
    | '+' expr %prec SIGN_OP      {$$ = template("+%s", $2);}
    | '-' expr %prec SIGN_OP      {$$ = template("-%s", $2);}
    | expr '*' expr           	  {$$ = template("%s * %s", $1, $3);}
    | expr '/' expr            	  {$$ = template("%s / %s", $1, $3);}
    | expr '%' expr            	  {$$ = template("%s %% %s", $1, $3);}
    | expr '+' expr           	  {$$ = template("%s + %s", $1, $3);}
	  | expr '-' expr          		  {$$ = template("%s - %s", $1, $3);}
    | expr OP_POWER expr	        {$$ = template("POW(%s, %s)", $1, $3);}
    | '(' expr ')'                {$$ = template("(%s)", $2);}
    | expr OP_EQUAL expr       	  {$$ = template("%s == %s", $1, $3);}
    | expr OP_NOT_EQUAL expr      {$$ = template("%s != %s", $1, $3);}
    | expr OP_LESS expr     	    {$$ = template("%s < %s", $1, $3);}
	  | expr OP_LESS_EQUAL expr  	  {$$ = template("%s <= %s", $1, $3);}
    | expr OP_MORE expr      	    {$$ = template("%s > %s", $1, $3);}
    | expr OP_MORE_EQUAL expr     {$$ = template("%s >= %s", $1, $3);}
    | expr OP_PLUS_EQUAL expr     {$$ = template("%s += %s", $1, $3);}
	  | expr OP_MINUS_EQUAL expr    {$$ = template("%s -= %s", $1, $3);}
	  | expr OP_MULT_EQUAL expr     {$$ = template("%s *= %s", $1, $3);}
	  | expr OP_DIV_EQUAL expr      {$$ = template("%s /= %s", $1, $3);}
	  | expr OP_MOD_EQUAL expr      {$$ = template("%s %= %s", $1, $3);}
    | expr KW_AND expr            {$$ = template("%s && %s", $1, $3);}
    | expr KW_OR expr             {$$ = template("%s || %s", $1, $3);}
    //| func_call                   {$$ = $1;}
    | TK_IDENT                    {$$ = $1;}
    | TK_IDENT'['expr']'          {$$ = template("%s[%s]", $1, $3);}
    | TK_STRING                   {$$ = $1;}
    | TK_REAL                     {$$ = $1;}
    | TK_INT                      {$$ = $1;}
    | TK_DECIMAL                  {$$ = $1;}
    | KW_TRUE                     {$$ = template("1");}
    | KW_FALSE                    {$$ = template("0");}
    | KW_HASH TK_IDENT            {$$ = template("#%s", $2);}
    | TK_IDENT '(' func_input ')'        {$$ = template("%s(%s)", $1, $3);}       // doulevei alla exei 1 conflict
	;

//--------------------------------- FUNCTIONS ---------------------------------------------------------

func_body: 
            %empty                    {$$ = template("");}  
          | const func_body           {$$ = template("\t%s%s", $1, $2);}
          | var func_body             {$$ = template("\t%s%s", $1, $2);} 
          | func func_body            {$$ = template("\t%s%s", $1, $2);}
          //| func_call func_body       {$$ = template("\t%s%s", $1, $2);} 
          //| equations func_body       {$$ = template("\t%s%s", $1, $2);} 
          | comp func_body            {$$ = template("\t%s%s", $1, $2);}
          | comp_var func_body        {$$ = template("\t%s%s", $1, $2);}
          | stmt func_body            {$$ = template("\t%s%s", $1, $2);}
         ;

func:
        KW_DEF TK_IDENT '('parameters')' '-'OP_MORE data_type ':' func_body KW_ENDDEF ';'   	{$$ = template("%s %s(%s){\n %s} \n", $8, $2, $4, $10);}
      | KW_DEF TK_IDENT '('parameters')' ':' func_body KW_ENDDEF ';'                          {$$ = template("%s (%s){\n %s} \n", $2, $4, $7);}
      //| KW_DEF TK_IDENT '('parameters')' '-'OP_MORE data_type ':' func_body KW_ENDDEF ';'     {$$ = template("%s %s(struct %s){\n %s}", $8, $2, $4), $10;}
      ;

parameters:
              %empty                                 		    {$$ = template("");}
            | TK_IDENT ':' data_type                       	{$$ = template("%s %s", $3, $1);}
            | TK_IDENT '['']' ':' data_type                	{$$ = template("%s* %s", $5, $1);}
            | TK_IDENT ':' data_type ',' parameters        	{$$ = template("%s %s, %s", $3, $1, $5);}
            | TK_IDENT '['']' ':' data_type ',' parameters 	{$$ = template("%s* %s, %s", $5, $1, $7);}
            ;


func_input:
            %empty                {$$ = template("");}
          | expr                  {$$ = $1;}
          | expr ',' func_input   {$$ = template("%s , %s", $1, $3);}
          ;


func_call:
            //TK_IDENT'('func_input ')'           {$$ = template("%s(%s)", $1, $3);}
           TK_IDENT'('func_input ')' ';'       {$$ = template("%s(%s);\n", $1, $3);}
          ;


main_func:
          KW_DEF KW_MAIN '(' ')' ':' func_body KW_ENDDEF ';' {$$ = template("int main(){\n%s\n}\n", $6);}
          ;


body: 
        %empty                {$$ = template("");}
      | body const            {$$ = template("%s%s", $1, $2);}
      | body var              {$$ = template("%s%s", $1, $2);}
      //| body equations        {$$ = template("%s%s", $1, $2);}
      | body comp             {$$ = template("%s%s", $1, $2);}
      | body comp_var         {$$ = template("%s%s", $1, $2);}
      | body func	            {$$ = template("%s%s", $1, $2);}
      | body main_func        {$$ = template("%s%s", $1, $2);}
      //| body func_call        {$$ = template("%s%s", $1, $2);}
      | body stmt             {$$ = template("%s%s", $1, $2);}
      ;

//----------------------------- STATEMENTS -----------------------------------------

keys:
          KW_BREAK ';'               {$$ = template("break;\n");}
        | KW_CONTINUE ';'            {$$ = template("continue;\n");}
        | KW_RETURN ';'              {$$ = template("return;\n");}
        | KW_RETURN expr ';'         {$$ = template("return %s;\n", $2);}
        | if                         {$$ = $1;}
        | for_loop                   {$$ = $1;}
        | while_loop                 {$$ = $1;}
        | equations                  {$$ = $1;}
        | func_call                  {$$ = $1;}
        ;


stmt:
          keys stmt                  {$$ = template("%s %s", $1,$2);}
        //| keys                    {$$ = $1;}
        | func_call                  {$$ = $1;}
        | KW_BREAK ';'               {$$ = template("break;\n");}
        | KW_CONTINUE ';'            {$$ = template("continue;\n");}
        | KW_RETURN ';'              {$$ = template("return;\n");}
        | KW_RETURN expr ';'         {$$ = template("return %s;\n", $2);}
        | equations                  {$$ = $1;}
        | if                         {$$ = $1;}
        | for_loop                   {$$ = $1;}
        | while_loop                 {$$ = $1;}
        ;


 /*       
more_stmt:
            keys      {$$ = template("$s", $1);}
          | keys more_stmt {$$ = template("%s%s", $1, $2);}
*/

if:
          KW_IF '('expr')' ':' stmt KW_ENDIF ';'             	 		 		 {$$ = template("if (%s){ \n\t%s} \n", $3, $6);}
        | KW_IF '('expr')' ':' stmt KW_ELSE ':' stmt KW_ENDIF ';'      {$$ = template("if (%s){ \n\t%s} \nelse{ \n\t%s} \n", $3, $6, $9);}
        ;

for_loop:
          KW_FOR TK_IDENT KW_IN '['assign ':' expr ']' ':' stmt KW_ENDFOR ';'                    {$$ = template("for (%s; %s){\n%s}", $5, $7, $10);}
        | KW_FOR TK_IDENT KW_IN '['assign ':' expr ':' assign ']' ':' stmt KW_ENDFOR ';'         {$$ = template("for (%s; %s; %s){\n%s}", $5, $7, $9, $12);}
        ;

assign:
        TK_IDENT '=' expr     {$$ = template("%s = %s", $1, $3);}
        ;

while_loop:
              KW_WHILE '(' expr ')' ':' stmt KW_ENDWHILE ';'     {$$ = template("while (%s){ \n%s}", $3, $6);}
            ;


data_type:  	
			      KW_INTEGER  	{$$ = template("int");}
          | KW_BOOLEAN 	  {$$ = template("int");}
          | KW_STR  		  {$$ = template("char*");}
          | KW_SCALAR   	{$$ = template("double");} 
          | KW_DECIMAL    {$$ = template("float");}
          ;

%%
int main ()
{
   if ( yyparse() == 0 )
		printf("//Accepted!\n");
	else
		printf("Rejected!\n");
}