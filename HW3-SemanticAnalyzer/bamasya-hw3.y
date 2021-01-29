%{

#include <stdio.h>

int e = 0;
extern int lineno;
extern int multlineno;
extern int addlineno;
extern int sublineno;
extern int divlineno;
extern int transposelineno;
extern int dplineno;
int yylex();
void yyerror (const char *s)
{
       // printf ("%s\n", s);
}

typedef struct Node
{
	int row;
	int column;
	int line;
} Node;

Node * CreateNode(int, int, int);

%}

%token tINTTYPE tINTVECTORTYPE tINTMATRIXTYPE tREALTYPE tREALVECTORTYPE tREALMATRIXTYPE tTRANSPOSE tIDENT tDOTPROD tIF tENDIF tREALNUM tINTNUM tAND tOR tGT tLT tGTE tLTE tNE tEQ

%left '='
%left tOR
%left tAND
%left tEQ tNE
%left tLTE tGTE tLT tGT
%left '+' '-'
%left '*' '/'
%left tDOTPROD
%left '(' ')'
%left tTRANSPOSE

%start prog

%union {
	struct Node * node;
	int num;
}

%type <node> expr;
%type <node> row;
%type <node> rows;
%type <node> vectorLit;
%type <node> matrixLit;
%type <node> transpose;
%type <num> leftbracket;

%%

prog:           stmtlst
;
stmtlst:        stmtlst stmt
                | stmt
;
stmt:       decl
            | asgn
            | if
;
decl:           type vars '=' expr ';'
;
asgn:           tIDENT '=' expr ';'
;
if:             tIF '(' bool ')' stmtlst tENDIF
;
type:           tINTTYPE
            | tINTVECTORTYPE
            | tINTMATRIXTYPE
            | tREALTYPE
            | tREALVECTORTYPE
            | tREALMATRIXTYPE
;
vars:           vars ',' tIDENT
                | tIDENT
;
expr:        value { $$ = CreateNode(0,0,lineno); }
            | vectorLit { $$ = $1; }
            | matrixLit { $$ = $1; }
            | expr '*' expr { if ($1->row == 0 && $1->column == 0)
				{		
					$$ = CreateNode($3->row,$3->column, multlineno);
				}
				else if ($3->row == 0 && $3->column == 0)
				{			
					$$ = CreateNode($1->row,$1->column, multlineno);
				}
				else if ($1->column != $3->row)
				{		
					printf("ERROR 2: %d dimension mismatch\n", multlineno);
        				return 1;
				}
				else
				{
					$$ = CreateNode($1->row,$3->column, multlineno);
				}
                            }
            | expr     '/'  expr { if ($1->row == 0 && $1->column == 0 && $3->column == $3->row)
					{
	 					$$ = CreateNode($3->row,$3->column, divlineno);
					}
					else if ($3->row == 0 && $3->column == 0)
					{
	 					$$ = CreateNode($1->row,$1->column, divlineno);
					}
					else if ( ($1->column != $3->row) || ($3->column != $3->row) ){
                                        	printf("ERROR 2: %d dimension mismatch\n",divlineno);
                                        	return 1;
					}
					else
					{
         					$$ = CreateNode($1->row,$3->column, divlineno);
					}
				}
            | expr '+' expr	{ if (($1->row != $3->row) || ($1->column != $3->column)) {
                                        printf("ERROR 2: %d dimension mismatch\n", addlineno);
                                        return 1;
                                        }
                                        else
                                        {
                                                $$ = CreateNode($1->row,$1->column, addlineno);
                                        }
                                }
            | expr      '-'  expr { if (($1->row != $3->row) || ($1->column != $3->column)) {
                                        printf("ERROR 2: %d dimension mismatch\n", sublineno);
                                        return 1;
                                        }
                                        else
                                        {
                                                $$ = CreateNode($1->row,$1->column, sublineno);
                                        }
                                }
            | expr tDOTPROD expr { if (($1->row != 1) || ($3->row != 1) || ($1->column != $3->column ))
					{
						printf("ERROR 2: %d dimension mismatch\n", dplineno);
						return 1;
					}
					else	$$ = CreateNode(0,0,dplineno);
				}
            | transpose { $$ = CreateNode($1->column,$1->row,transposelineno); }
;
transpose:      tTRANSPOSE '(' expr ')' {$$ = $3; }
;
vectorLit:      leftbracket row ']' { $$ = CreateNode($2->row,$2->column,$1); }
;
row:            row ',' value { $$ = CreateNode(1,$1->column + 1,lineno); }
                | value { $$ = CreateNode(1,1,lineno); }
;
matrixLit:      leftbracket rows ']' { $$ = CreateNode($2->row, $2->column,$1); 
	 				if (e == 1)
                                        {
					printf("ERROR 1: %d inconsistent matrix size\n", $$->line);
                                        return 1;
                        		}
                                     }
;
leftbracket: '[' { $$ = lineno; }
;
rows:           row ';' row { if ($1->column != $3->column) {
                                    e =1;
                              }
                              else $$ = CreateNode($1->row + $3->row, $1->column, lineno);}
                | rows ';' row { if ($1->column != $3->column) {
                                e = 1;
                                }
                                else $$ = CreateNode($1->row + $3->row, $1->column, lineno);}
;
value:          tINTNUM
                | tREALNUM
;
bool:           comp
                | bool tAND bool
                | bool tOR bool
;
comp:           tIDENT relation tIDENT
;
relation:       tGT
	        | tLT
                | tGTE
                | tLTE
                | tEQ
                | tNE
;

%%

Node * CreateNode(int row, int column, int line)
{
        Node * node = (Node *) malloc(sizeof(Node));
        node->row = row;
        node->column = column;
        node->line = line;
        return node;
}

int main ()
{
   if (yyparse()) {
   // parse error
       //printf("ERROR\n");
       return 1;
   }
   else {
   // successful parsing
      printf("OK\n");
      return 0;
   }
}
