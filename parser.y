/* CMSC 430 Compiler Theory and Design
   Project 4 Skeleton
   UMGC CITE
   Summer 2023
   
   Project 4 Parser with semantic actions for static semantic errors */

%{
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

int yylex();
Types find(Symbols<Types>& table, CharPtr identifier, string tableName);
void yyerror(const char* message);

Symbols<Types> scalars;
Symbols<Types> lists;

%}

%define parse.error verbose

%union {
	CharPtr iden;
	Types type;
}

%token <iden> IDENTIFIER

%token <type> INT_LITERAL CHAR_LITERAL REAL_LITERAL HEX_LITERAL

%token ADDOP MULOP RELOP ANDOP ARROW

%token BEGIN_ CASE CHARACTER ELSE END ENDSWITCH FUNCTION INTEGER IS LIST OF OTHERS
	RETURNS SWITCH WHEN REMOP EXOP NEGOP OROP NOTOP ELSIF ENDFOLD ENDIF FOLD IF 
	LEFT REAL RIGHT THEN 

%type <type> list expressions body type statement_ statement cases case expression
	term primary

%%

function:	
	function_header optional_variable body ;
	
		
function_header:	
	FUNCTION IDENTIFIER parameters RETURNS type ';' |
	error ';';

type:
	INTEGER {$$ = INT_TYPE;} |
	REAL {$$ = REAL_TYPE;} |
	CHARACTER {$$ = CHAR_TYPE; };
	
optional_variable:
	variable_list | variable |
	%empty ;

variable_list: 
	variable |
	variable_list variable ;
    
variable:	
	IDENTIFIER ':' type IS statement ';' {checkAssignment($3, $5, "Variable Initialization"); scalars.insert($1, $3);} |
	IDENTIFIER ':' LIST OF type IS list ';' {lists.insert($1, $5);} |
	error ';';

list:
	'(' expressions ')' {$$ = $2;} ;

parameters: 
	parameter_list |
	%empty ;

parameter_list:
	parameter |
	parameter_list ',' parameter ;

parameter: 
	IDENTIFIER ':' type ;

expressions:
	expressions ',' expression | 
	expression ;

body:
	BEGIN_ statement_ END ';' {$$ = $2;} ;
    
statement_:
	statement ';' |
	error ';' {$$ = MISMATCH;} ;
	
statement:
	expression |
	WHEN condition ',' expression ':' expression {$$ = checkWhen($4, $6);} |
	SWITCH expression IS cases OTHERS ARROW statement ';' 
	ENDSWITCH {$$ = checkSwitch($2, $4, $7);} | 
	IF condition THEN statement_ elsif_statements ELSE statement_ ENDIF |
	FOLD direction operator list_choice ENDFOLD ;
	
elsif_statements: 
	elsif_statement elsif_statements |
	%empty ; 
	
elsif_statement: 
	ELSIF condition THEN statement_ ; 

direction: 
	LEFT | RIGHT ; 

operator:
	ADDOP | MULOP ; 

list_choice:
	list | IDENTIFIER ; 

cases:
	cases case {$$ = checkCases($1, $2);} |
	%empty {$$ = NONE;} ;
	
case:
	CASE INT_LITERAL ARROW statement ';' {$$ = $4;} |
	error ';' ; 

condition:
	condition ANDOP relation |
	relation ;

relation:
	expression RELOP expression |
	condition logical_operator condition |
	'(' condition ')' |
	NOTOP condition ;

logical_operator: 
	OROP | NOTOP ; 
	
expression:
	expression ADDOP term {$$ = checkArithmetic($1, $3);} |
	term ;
      
term:
	term MULOP primary {$$ = checkArithmetic($1, $3);} |
	primary ;

primary:
	'(' expression ')' {$$ = $2;} |
	expression arithmetic_operator expression |
	NEGOP expression |
	INT_LITERAL |
	HEX_LITERAL |
	CHAR_LITERAL |
	REAL_LITERAL |
	IDENTIFIER '(' expression ')' {$$ = find(lists, $1, "List");} |
	IDENTIFIER  {$$ = find(scalars, $1, "Scalar");} ;

arithmetic_operator: REMOP | EXOP

%%

Types find(Symbols<Types>& table, CharPtr identifier, string tableName) {
	Types type;
	if (!table.find(identifier, type)) {
		appendError(UNDECLARED, tableName + " " + identifier);
		return MISMATCH;
	}
	return type;
}

void yyerror(const char* message) {
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[]) {
	firstLine();
	yyparse();
	lastLine();
	return 0;
} 
