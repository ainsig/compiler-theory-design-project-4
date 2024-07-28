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
Types findList(Symbols<Types>& table, CharPtr identifier);
void yyerror(const char* message);
void checkListTypeConsistency(Types declaredType, Types elementType);
void checkListSubscript(Types subscriptType);
void checkRelationalTypes(Types left, Types right);
void checkExponentiation(Types base, Types exponent);
void checkNegation(Types value);
void checkRemainderOperator(Types left, Types right);
void checkIfElseTypes(Types ifType, Types elsifType, Types elseType);
void checkFoldListType(Types listType);
void checkFunctionReturn(Types returnType, Types bodyType);


Symbols<Types> scalars;
Symbols<Types> lists;
vector<Types> listElements;

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
    term primary relation condition elsif_statement elsif_statements list_choice
    function function_header

%%

function:	
	function_header optional_variable body {
       	    checkFunctionReturn($1, $3);
    	};
		
function_header:
    	FUNCTION IDENTIFIER parameters RETURNS type ';' {
        	$$ = $5;
    	} |
    	error ';';


type:
    	INTEGER { $$ = INT_TYPE; } |
    	REAL { $$ = REAL_TYPE; } |
    	CHARACTER { $$ = CHAR_TYPE; } |
    	LIST OF type { $$ = LIST_TYPE; } ;
	
optional_variable:
	variable_list | variable |
	%empty ;

variable_list: 
	variable |
	variable_list variable ;
    
variable:    
    	IDENTIFIER ':' type IS list ';' {
        	Types listType = checkListElements(listElements, $3);
        	listElements.clear(); 
        	//checkListTypeConsistency($3, listType); // Ensure types matc
        	lists.insert($1, $3); 
    	} |
    	IDENTIFIER ':' type IS expression ';' 
    	{ 
    	    checkAssignment($3, $5, "Variable Initialization"); scalars.insert($1, $3);

    	} |
    	error ';';


list:
    	'(' expressions ')' { $$ = $2; } ;


parameters: 
	parameter_list |
	%empty ;

parameter_list:
	parameter |
	parameter_list ',' parameter ;

parameter: 
	IDENTIFIER ':' type ;

expressions:
    	expressions ',' expression { listElements.push_back($3); $$ = $3; } | 
    	expression { listElements.push_back($1); $$ = $1; } ;


body:
    	BEGIN_ statement_ END ';' { $$ = $2; } ;
    
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
        expression RELOP expression {
            checkRelationalTypes($1, $3); // Ensure valid relational comparison
            $$ = $1; // Use the left operand type as the resulting type
        } |
        condition logical_operator condition |
        '(' condition ')' { $$ = $2; } |
        NOTOP condition { $$ = $2; } ;

logical_operator: 
	OROP | NOTOP ; 
	
expression:
        expression ADDOP term { $$ = checkArithmetic($1, $3); } |
        expression REMOP term {
            checkRemainderOperator($1, $3); // Ensure both operands are integers
            $$ = $1; // Use the left operand type as the resulting type
        } |
        term { $$ = $1; };
term:
	term MULOP primary {$$ = checkArithmetic($1, $3);} |
	primary ;

primary:
        '(' expression ')' { $$ = $2; } |
        NEGOP expression {
            checkNegation($2); // Ensure valid negation
            $$ = $2;
        } |
        INT_LITERAL { $$ = INT_TYPE; } |
        HEX_LITERAL { $$ = INT_TYPE; } |
        CHAR_LITERAL { $$ = CHAR_TYPE; } |
        REAL_LITERAL { $$ = REAL_TYPE; } |
        IDENTIFIER '(' expression ')' {
            Types listType = findList(lists, $1);
            checkListSubscript($3); // Ensure subscript is an integer
            $$ = listType;
        } |
        IDENTIFIER { $$ = find(scalars, $1, "Scalar"); } |
            expression EXOP expression {
            checkExponentiation($1, $3); // Ensure valid exponentiation
            $$ = $1; // Use the base type as the resulting type
        } ;

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

Types findList(Symbols<Types>& table, CharPtr identifier) {
    Types type;
    if (!table.find(identifier, type)) {
        appendError(UNDECLARED, "List " + string(identifier));
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
