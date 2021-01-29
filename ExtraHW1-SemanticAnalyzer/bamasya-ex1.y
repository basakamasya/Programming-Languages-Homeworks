%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h> 
#include <stdbool.h>
extern int linenovar;
extern int len;
int linenoident;
extern char * currentyytext;
int isitlocal = 0;
int yylex();
void yyerror (const char * s)
{
        printf("ERROR\n");
}
typedef struct Node
{
	char * ident;
	struct Node * next;

} Node;

Node * add(Node * head, char * currentvar);
void printList(struct Node * n);
bool search(Node * head, char * currentvar);
Node * localscope = NULL;
Node * globalscope = NULL;
Node * identassign = NULL;

%}
%token tINT tSTRING tRETURN tPRINT tLPAR tRPAR tCOMMA tMOD tASSIGNM tMINUS tPLUS tDIV tSTAR tSEMI tLBRAC tRBRAC tIDENT tINTVALPOS tINTVALNEG tSTRINGVAL
%left tPLUS tMINUS
%left tSTAR tDIV tMOD
%left tLPAR tRPAR tLBRAC tRBRAC

%union {
        struct Node * node;
	int lineno;
}

%start prog
%%
prog:           stmtlst
    ;
stmtlst:        stmtlst stmt
                              | stmt
;
stmt: funcdef
        	| vardef
	| assgn
	| print
;
funcdef: type tIDENT tLPAR tRPAR funcstarter funcbody endoffunc
              	|  type tIDENT tLPAR formalparameters tRPAR funcstarter funcbody endoffunc  
;
funcstarter: tLBRAC {isitlocal = 1;}
	   ;
endoffunc: tRBRAC {localscope = NULL; isitlocal = 0;}
	 ;
formalparameters: type tIDENT {char currentparam[len+1];
			       				memcpy(currentparam,currentyytext, len);
					 currentparam[len] = '\0';
					isitlocal = 1;
					 //printf("%s\n",currentparam);
						if (!search(globalscope,currentparam) && !search(localscope,currentparam)){
					  localscope = add(localscope,currentparam); }					
						else { printf("%d Redefinition of variable\n",linenovar); return 1; } }
		 | formalparameters tCOMMA type tIDENT {char currentparam[len+1];
                                        memcpy(currentparam,currentyytext, len);
                                         currentparam[len] = '\0';
                                        isitlocal = 1;
                                        //printf("%s\n",currentparam);
                                                if (!search(globalscope,currentparam)&& !search(localscope,currentparam)){
                                          localscope = add(localscope,currentparam);    }
                                                else { printf("%d Redefinition of variable\n",linenovar); return 1; } }
;
funcbody: funcstmts returnstmt
		| returnstmt
;
funcstmts: funcstmts funcstmt
	 		| funcstmt
;
funcstmt: vardef
		 | assgn
	 | print
;
returnstmt: tRETURN expr tSEMI
	  ;
vardef: type tIDENT { char currentvariable[len+1]; memcpy(currentvariable,currentyytext, len); currentvariable[len] = '\0';
           							identassign = add(identassign,currentvariable); linenoident = linenovar;
                                                        //printf("%s \n",currentvariable);
							 } 
							 tASSIGNM expr tSEMI { if (isitlocal == 0 && !search(globalscope,identassign->ident))
                                                        { //printf("%s declaring to global\n Global scope is", currentvariable);
                                                        globalscope = add(globalscope,identassign->ident); identassign = NULL;
                                                        }
                                                        else if (isitlocal == 1 &&
                                                                 !search(globalscope,identassign->ident) && !search(localscope,identassign->ident))
                                                        { //printf("%s declaring to local\n Local scope is", currentvariable);
                                                         localscope = add(localscope,identassign->ident); identassign = NULL; }
                                                        else
                                                         { printf("%d Redefinition of variable\n",linenoident); return 1; } }
;
expr: value
        	| funccall
	| expr tSTAR expr
	| expr tPLUS expr
	| expr tMINUS expr
	| expr tDIV expr
	| expr tMOD expr
	| expr tINTVALNEG
;
value: tIDENT { char currentvariable[len+1];
                     memcpy(currentvariable,currentyytext, len);
                currentvariable[len] = '\0';
                //printf("%s\n",currentvariable);
                if (isitlocal == 0 && !search(globalscope,currentvariable))
                { printf("%d Undefined variable\n", linenovar);
		  return 1;
                }
                else if (isitlocal == 1 && !search(globalscope,currentvariable) && !search(localscope,currentvariable))
                { printf("%d Undefined variable\n", linenovar);
               	  return 1;
		}
                }
	| tINTVALNEG
	| tINTVALPOS
	| tSTRINGVAL
;
funccall: funcname tLPAR tRPAR
		 | funcname tLPAR parameters tRPAR
;
funcname: tIDENT
	;
parameters: value
	  	   | parameters tCOMMA value
;
type: tINT 
        | tSTRING
;
assgn: tIDENT { char currentvariable[len+1]; memcpy(currentvariable,currentyytext, len); currentvariable[len] = '\0';
                                                                 identassign = add(identassign,currentvariable); linenoident = linenovar;
                                                        //printf("%s \n",currentvariable);
                                                         }
                tASSIGNM expr tSEMI {
                if (isitlocal == 0 && !search(globalscope,identassign->ident))
                { //printList(globalscope);
		  printf("%d Undefined variable\n", linenoident);
                  return 1;
                }
                else if (isitlocal == 1 && !search(globalscope,identassign->ident) && !search(localscope,identassign->ident))
                { //printList(localscope);
		  printf("%d Undefined variable\n", linenoident);
                  return 1;
                } }
;
print: tPRINT tLPAR expr tRPAR tSEMI
     ;

%%

Node * add(Node* head, char * currentvar) 
{ 
    Node* newnode = (struct Node*) malloc(sizeof(struct Node));
    newnode->ident = malloc(len * sizeof(char));
    strcpy(newnode->ident, currentvar);
    //newnode->ident  = currentvar;
    newnode->next = head; 
    head   = newnode; 
    return head;
}
bool search(Node* head, char * currentvar) 
{ 
    Node* current = head; 
    while (current != NULL) 
    { 
	if (!strcmp(current->ident,currentvar))
	{
            return true; 
	}
        current = current->next; 
    } 
    return false; 
}
void printList(struct Node* head) 
{ 
    Node * n = head;
    while (n != NULL) { 
        printf(" %s ", n->ident); 
        n = n->next; 
  }
	printf("\n");
} 

int main()
{
  if (yyparse()) {
       //printf("ERROR\n");
       return 1;
   }
   else {
      printf("OK\n");
      return 0;
   }
}

