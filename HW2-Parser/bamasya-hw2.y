%{
#include <stdio.h>
int yylex();
void yyerror (const char * s)
{
	printf("ERROR\n");
}
%}
%token tINTTYPE tINTVECTORTYPE tINTMATRIXTYPE tREALTYPE tREALVECTORTYPE tREALMATRIXTYPE tTRANSPOSE tIDENT tDOTPROD tIF tENDIF tREALNUM tINTNUM tAND tOR tGT tLT tGTE tLTE tNE tEQ
%left '+' '-'
%left '/' '*'
%left tDOTPROD
%left tTRANSPOSE
%left tOR
%left tAND
%%
prog:	 stmtlst
;
stmtlst:  stmt
        | stmt stmtlst
;
stmt:  decl
        | asgn
        | if
decl:   type vars '=' expr ';'      
;
type:	tINTTYPE
    	| tINTVECTORTYPE
	| tINTMATRIXTYPE
	| tREALTYPE
	| tREALVECTORTYPE
	| tREALMATRIXTYPE
;
vars:	tIDENT
    	| tIDENT ',' vars
;
asgn: 	tIDENT '=' expr ';'
;
if:	tIF '(' bool ')' stmtlst tENDIF
;
expr:	tIDENT
    	| tINTNUM
	| tREALNUM
	| vectorLit
	| matrixLit
	| expr '*' expr
        | expr '+' expr  
        | expr '-' expr  
        | expr '/' expr
        | expr tDOTPROD expr
	| transpose    
;
transpose:	tTRANSPOSE '(' expr ')'
;
vectorLit:	'[' row ']'
;
matrixLit:	'[' row ';' rows ']'
;
row:	value
   	| value ',' row
;
rows:	row
    	| row ';' rows
;
value:	tINTNUM
     	| tREALNUM
	| tIDENT
;
bool:   comp
        | bool tAND bool
	| bool tOR bool
;
comp:	tIDENT relation tIDENT
;
relation:	tGT
		| tLT
                | tGTE
                | tLTE
                | tNE
                | tEQ
;
%%
int main()
{
	if (yyparse())
	{
		return 1;
	}
	else
	{
		printf("OK\n");
		return 0;
	}
}
