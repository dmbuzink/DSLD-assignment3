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

syntax Alphabet
	= "ALPHABET" ":=" CharList;
	
syntax CharList
	= Char
	| Char "," CharList
	;

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
	
syntax StateContentList
	= StateContent StateContentList
	| StateContent
	;

syntax StateContent
	= TransitionLabel
	| VariableAssignment
	| IFELSE
	;
	
syntax StateContentListOrEmpty
	= ":" StateContentList
	| ":"
	;

syntax DeclarationList
	= Declaration
	| Declaration DeclarationList
	;

syntax Declaration
	= "TRANS" Label ":=" Transition
	| "INT" Label ":=" IntegerLiteral
	| "BOOL" Label ":=" Boolean
	;

syntax IFELSE
	= "IF" BoolExpr ":" StateContentList "ELSE" ":" StateContentList "FI"
	| "IF" BoolExpr ":" StateContentList "FI"
	;

syntax VariableAssignment
	= Label ":=" BoolExpr
	| Label ":=" IntExpr
	;
	
//Does not properly support calculation rules
syntax IntExpr
	= IntegerLiteral
	| Label
	| IntExpr "*" IntExpr
	> IntExpr "/" IntExpr
	> IntExpr "+" IntExpr
	> IntExpr "-" IntExpr
	;
	
syntax BoolExpr
	= Boolean
	| Label
	| "NOT" BoolExpr
	> BoolExpr "AND" BoolExpr
	> BoolExpr "OR" BoolExpr
	> BoolExpr "=" BoolExpr
	> IntExpr "=" IntExpr
	> IntExpr '\>' IntExpr
	> IntExpr '\<' IntExpr
	> IntExpr '\<'"=" IntExpr
	| IntExpr '\>'"=" IntExpr
	| "PROCESSING_CHAR" "=" Char
	;
	
syntax TransitionLabel
	= "TRANS" Label
	| Transition
	;
	
syntax Transition
	= "TAKES" CharList "TO" Label;