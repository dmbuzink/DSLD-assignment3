module EFAL::CST2AST

import EFAL::AST;
import EFAL::Syntax;
import ParseTree;
import String;

public Automaton cst2ast(Tree tree){
	return load(tree);
}

public Automaton load((Automata) `<AutomataType t> <Alphabet a> <DeclarationList d> <StateList s>`)
	= {
		//type, alphabet, integer, booleans, states
		return Automaton(loadAutomataType(t), loadAlphabet(a), loadIntDeclarations(d), loadBoolDeclarations(d), []);
	};
	
public int loadAutomataType((AutomataType) `DFA`) = 0;
public int loadAutomataType((AutomataType) `NFA`) = 1;
public int loadAutomataType((AutomataType) `ENFA`) = 2;

public list[str] loadAlphabet((Alphabet) `ALPHABET := <LabelList l>`) = loadLabellist(l);
public list[str] loadLabellist((LabelList) `<Label l> , <LabelList ls>`) = ["<l>"] + loadLabellist(ls);
public list[str] loadLabellist((LabelList) `<Label l>`) = ["<l>"];

public list[Integer] loadIntDeclarations((DeclarationList) `<Declaration d> <DeclarationList dl>`) = loadIntDeclaration(d) + loadIntDeclarations(dl);
public list[Integer] loadIntDeclarations((DeclarationList) `<Declaration d>`) = loadIntDeclaration(d);
public list[Integer] loadIntDeclaration((Declaration) `INT <Label l> := <IntegerLiteral i>`) = [Integer("<l>", toInt("<i>"))];
public list[Integer] loadIntDeclaration((Declaration) `TRANS <Label l> := <Transition t>`) = [];
public list[Integer] loadIntDeclaration((Declaration) `BOOL <Label l> := <Boolean b>`) = [];

public list[Boolean] loadBoolDeclarations((DeclarationList) `<Declaration d> <DeclarationList dl>`) = loadBoolDeclaration(d) + loadBoolDeclarations(dl);
public list[Boolean] loadBoolDeclarations((DeclarationList) `<Declaration d>`) = loadBoolDeclaration(d);
public list[Boolean] loadBoolDeclaration((Declaration) `INT <Label l> := <IntegerLiteral i>`) = [];
public list[Boolean] loadBoolDeclaration((Declaration) `TRANS <Label l> := <Transition t>`) = [];
public list[Boolean] loadBoolDeclaration((Declaration) `BOOL <Label l> := <Boolean b>`) = [Boolean("<l>", loadBool(b))];
public bool loadBool ((Boolean) `TRUE`) = true;
public bool loadBool ((Boolean) `FALSE`) = false;