module EFAL::Syntax

layout Whitespace = [\t-\n\r\ ]*; 

//To be filled in
keyword Keywords = "TRANS" | "TRUE" | "FALSE" | "TAKES" | "TO" | "IF" | "ELSE" | "FI" | "PROCESSING_CHAR" | "INT" | "BOOL";
	 
lexical IntegerLiteral = [0-9]+;
lexical Boolean = "TRUE" | "FALSE";
lexical Char = [a-zA-Z];
lexical Label = (Char [a-zA-Z0-9_]*) \Keywords;

start syntax Automata
	= AutomataType Alphabet DeclarationList StateList
	| AutomataType Alphabet StateList
	;
	
syntax AutomataType
	= "DFA"
	| "NFA"
	| "ENFA"
	;

//ALPHABET
syntax Alphabet
	= "ALPHABET" ":=" CharList;
	
syntax CharList
	= Char
	| Char "," CharList
	;

//Declarations
syntax DeclarationList
	= Declaration
	| Declaration DeclarationList
	;

syntax Declaration
	= "TRANS" Label ":=" Transition
	| "INT" Label ":=" IntegerLiteral
	| "BOOL" Label ":=" Boolean
	;

syntax Transition
	= "TAKES" CharList "TO" Label;

//States
syntax StateList
	= State
	| State StateList
	;

syntax State
	= "INITIAL" "STATE" Label StateContentListOrEmpty
	| "FINAL" "STATE" Label StateContentListOrEmpty
	| "INITIAL" "FINAL" "STATE" Label StateContentListOrEmpty
	| "FINAL" "INITIAL" "STATE" Label StateContentListOrEmpty
	| "STATE" Label StateContentListOrEmpty
	;	

syntax StateContentListOrEmpty
	= ":" StateContentList
	| ":"
	;
	
syntax StateContentList
	= StateContent StateContentList
	| StateContent
	;

syntax StateContent
	= TransitionLabel
	| VariableAssignment
	| IFELSE
	;
	
syntax TransitionLabel
	= "TRANS" Label
	| Transition
	;
	
//EXAMPLE: TRANS trans
	
//IF ELSE, both require FI
syntax IFELSE
	= "IF" BoolExpr ":" StateContentList "ELSE" ":" StateContentList "FI"
	| "IF" BoolExpr ":" StateContentList "FI"
	;
	
//STATE x
//IF TRUE:
//	TAKE a TO y
//  TAKE b TO z
//  FI

//Variable assignments
syntax VariableAssignment
	= Label ":=" BoolExpr
	| Label ":=" IntExpr
	;

//Integer expressions, with priorities
syntax IntExpr
	= IntegerLiteral
	| "(" IntExpr ")"
	| Label
	> left IntExpr "*" IntExpr
	> left IntExpr "/" IntExpr
	> left IntExpr "+" IntExpr
	> left IntExpr "-" IntExpr
	;
	
//Boolean expressions with priorities
syntax BoolExpr
	= Boolean
	| Label
	| "(" BoolExpr ")"
	> "NOT" BoolExpr
	> left BoolExpr "AND" BoolExpr
	> left BoolExpr "OR" BoolExpr
	> left BoolExpr "=" BoolExpr
	> IntExpr "=" IntExpr
	> IntExpr '\>' IntExpr
	> IntExpr '\<' IntExpr
	> IntExpr '\<'"=" IntExpr
	| IntExpr '\>'"=" IntExpr
	| "PROCESSING_CHAR" "=" Char
	;