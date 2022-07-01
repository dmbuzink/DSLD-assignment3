module EFAL::Syntax

layout Whitespace = [\t-\n\r\ ]*; 

//To be filled in
keyword Keywords = "TRANS" | "TRUE" | "FALSE" | "TAKES" | "TO" | "IF" | "ELSE";
	 
lexical IntegerLiteral = [0-9]+;
lexical Boolean = "TRUE" | "FALSE";
lexical Label = [a-z]+ \Keywords;

start syntax Automata
//	= StateList
	= AutomataType Alphabet DeclarationList StateList
	| AutomataType Alphabet StateList
	;
	
syntax AutomataType
	= "DFA"
	| "NFA"
	| "ENFA"
	;

syntax Alphabet
	= "ALPHABET" ":=" LabelList;
	
syntax LabelList
	= Label
	| Label "," LabelList
	;

syntax StateList
	= State
	| State StateList
	;

syntax State
	= "INITIAL" "STATE" Label ":" StateContent
	| "FINAL" "STATE" Label ":" StateContent
	| "INITIAL" "FINAL" "STATE" Label ":" StateContent
	| "FINAL" "INITIAL" "STATE" Label ":" StateContent
	| "STATE" Label ":" StateContent
	;	
	
syntax StateContent
	= TransitionLabel
	| TransitionLabel StateContent
	| VariableAssignment
	| VariableAssignment StateContent
	| IFELSE
	| IFELSE StateContent
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
	= "IF" BoolExpr ":" StateContent "ELSE" ":" StateContent
	| "IF" BoolExpr ":" StateContent
	;

syntax VariableAssignment
	= Label ":=" BoolExpr
	| Label ":=" IntExpr
	;
	
//Does not properly support calculation rules
syntax IntExpr
	= IntegerLiteral
	| Label
	| IntExpr "+" IntExpr
	| IntExpr "-" IntExpr
	| IntExpr "*" IntExpr
	| IntExpr "/" IntExpr
	;
	
syntax BoolExpr
	= Boolean
	| Label
	| "NOT" BoolExpr
	| BoolExpr "AND" BoolExpr
	| BoolExpr "OR" BoolExpr
	| IntExpr "=" IntExpr
	//For some reason > etc. are not accepted by rascal
	| IntExpr '\>' IntExpr
	| IntExpr '\<' IntExpr
	| IntExpr '\<'"=" IntExpr
	| IntExpr '\>'"=" IntExpr
	;
	
syntax TransitionLabel
	= "TRANS" Label
	| Transition
	;
	
syntax Transition
	= "TAKES" LabelList "TO" Label;