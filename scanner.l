/* CMSC 430 Compiler Theory and Design
   Project 4 Skeleton
   UMGC CITE
   Summer 2023 */

/* This file contains flex input file */

%{
#include <cstdio>
#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"
#include "tokens.h"

%}

%option noyywrap

ws		[ \t\r]+
comment		"//".*\n
comment_2	"--".*\n
line		[\n]
id		[A-Za-z][A-Za-z0-9]*(_{0,2}[A-Za-z0-9]+)*
digit		[0-9]
hexd		[0-9a-fA-F]
hex		#{hexd}+
real        	{dec}*\.{dec}+([eE][+-]?{dec}+)?
dec		{digit}+
char		'([^'\\]|\\[btnrf])'
punc		[\(\),:;]
%%

{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine(); }
{comment_2}	{ ECHO; nextLine(); }
{line}		{ ECHO; nextLine(); }
"+"		{ ECHO; return(ADDOP); }
"-"		{ ECHO; return(ADDOP); }
"/"		{ ECHO; return(MULOP); } 
"*"		{ ECHO; return(MULOP); }
"%"		{ ECHO; return(REMOP); }
"&"		{ ECHO; return(ANDOP); }
"^"		{ ECHO; return(EXOP); }
"~"		{ ECHO; return(NEGOP); } 
"<"		{ ECHO; return(RELOP); }
"=>"		{ ECHO; return(ARROW); }
"|"		{ ECHO; return(OROP); } 
"!"		{ ECHO; return(NOTOP); } 
"="		{ ECHO; return(RELOP); }
"<>"		{ ECHO; return(RELOP); }
">"		{ ECHO; return(RELOP); }
">="		{ ECHO; return(RELOP); }
"<="		{ ECHO; return(RELOP); }
begin		{ ECHO; return(BEGIN_); }
case		{ ECHO; return(CASE); }
character	{ ECHO; return(CHARACTER); }
end		{ ECHO; return(END); }
endswitch	{ ECHO; return(ENDSWITCH); }
function	{ ECHO; return(FUNCTION); }
integer		{ ECHO; return(INTEGER); }
is		{ ECHO; return(IS); }
list		{ ECHO; return(LIST); }
of		{ ECHO; return(OF); }
others		{ ECHO; return(OTHERS); }
returns		{ ECHO; return(RETURNS); }
switch		{ ECHO; return(SWITCH); }
when		{ ECHO; return(WHEN); }
else		{ ECHO; return(ELSE); }
elsif		{ ECHO; return(ELSIF); }
endfold		{ ECHO; return(ENDFOLD); }
endif		{ ECHO; return(ENDIF); }
fold		{ ECHO; return(FOLD); }
if		{ ECHO; return(IF); }
left		{ ECHO; return(LEFT); }
real		{ ECHO; return(REAL); }
right		{ ECHO; return(RIGHT); }
then		{ ECHO; return(THEN); }

{id}		{ ECHO; yylval.iden = (CharPtr)malloc(yyleng + 1); 
			strcpy(yylval.iden, yytext); return(IDENTIFIER);}
{hex}		{ ECHO; return(HEX_LITERAL); }
{dec}		{ ECHO; yylval.type = INT_TYPE; return(INT_LITERAL); }
{char}		{ ECHO; yylval.type = CHAR_TYPE; return(CHAR_LITERAL); }
{punc}		{ ECHO; return(yytext[0]); }
{real}		{ ECHO; return(REAL_LITERAL); }
.		{ ECHO; appendError(LEXICAL, yytext); }
%%
