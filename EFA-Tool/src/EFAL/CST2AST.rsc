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
		loadTransitionDeclarations(d);
		return Automaton(loadAutomataType(t), loadAlphabet(a), loadIntDeclarations(d), loadBoolDeclarations(d), loadStates(s));
	};
	
public Automaton load((Automata) `<AutomataType t> <Alphabet a> <StateList s>`)
	= {
		//type, alphabet, integer, booleans, states
		return Automaton(loadAutomataType(t), loadAlphabet(a), [], [], loadStates(s));
	};

//Maps for the different type of variables
map[str label, IntegerExpression integer] declaredIntegers = ();
map[str label, BooleanExpression boolean] declaredBooleans = ();
map[str label, Statement transition] declaredTransitions = ();
public IntegerExpression loadInteger(Label l) = declaredIntegers["<l>"];
public BooleanExpression loadBoolean(Label l) = declaredBooleans["<l>"];
public Statement loadTransition(Label l) = declaredTransitions["<l>"];

//Automata types
public int loadAutomataType((AutomataType) `DFA`) = 1;
public int loadAutomataType((AutomataType) `NFA`) = 2;
public int loadAutomataType((AutomataType) `ENFA`) = 3;

//Loading alphabet
public list[str] loadAlphabet((Alphabet) `ALPHABET := <CharList l>`) = loadLabellist(l);
public list[str] loadLabellist((CharList) `<Char l> , <CharList ls>`) = ["<l>"] + loadLabellist(ls);
public list[str] loadLabellist((CharList) `<Char l>`) = ["<l>"];

//Load States
public list[State] loadStates((StateList) `<State s> <StateList sl>`) = [loadState(s)] + loadStates(sl);
public list[State] loadStates((StateList) `<State s>`) = [loadState(s)];

//Different type of states
public State loadState((State) `INITIAL STATE <Label l> <StateContentListOrEmpty sc>`) = State("<l>", loadStateContentListOrEmpty(sc), true, false);
public State loadState((State) `INITIAL FINAL STATE <Label l> <StateContentListOrEmpty sc>`) = State("<l>", loadStateContentListOrEmpty(sc), true, true);
public State loadState((State) `FINAL INITIAL STATE <Label l> <StateContentListOrEmpty sc>`) = State("<l>", loadStateContentListOrEmpty(sc), true, true);
public State loadState((State) `FINAL STATE <Label l> <StateContentListOrEmpty sc>`) = State("<l>", loadStateContentListOrEmpty(sc), false, true);
public State loadState((State) `STATE <Label l> <StateContentListOrEmpty sc>`) = State("<l>", loadStateContentListOrEmpty(sc), false, false);
	
//Statecontent, can be empty expreseed by StateContentListOrEmpty
public list[Statement] loadStateContentListOrEmpty((StateContentListOrEmpty) `: <StateContentList s>`) = loadStateContentList(s);
public list[Statement] loadStateContentListOrEmpty((StateContentListOrEmpty) `:`) = [];	
public list[Statement] loadStateContentList((StateContentList) `<StateContent s> <StateContentList l>`) = loadStateContent(s) + loadStateContentList(l);
public list[Statement] loadStateContentList((StateContentList) `<StateContent s>`) = loadStateContent(s);	
public list[Statement] loadStateContent((StateContent) `<TransitionLabel t>`) = [loadTransition(t)];
public list[Statement] loadStateContent((StateContent) `<VariableAssignment va>`) = [loadVariableAss(va)];
public list[Statement] loadStateContent((StateContent) `<IFELSE ie>`) = [loadIFELSE(ie)];

//IFELSE or only IF, both require FI
public Statement loadIFELSE((IFELSE) `IF <BoolExpr b> : <StateContentList sc1> ELSE : <StateContentList sc2> FI`) = ConditionalWithElse(loadBoolExpr(b), loadStateContentList(sc1), loadStateContentList(sc2));
public Statement loadIFELSE((IFELSE) `IF <BoolExpr b> : <StateContentList sc1> FI`) = Conditional(loadBoolExpr(b), loadStateContentList(sc1));

//Loading a transition, can also be a label
public Statement loadTransition((TransitionLabel) `<Transition t>`) = loadTransition(t);
public Statement loadTransition((TransitionLabel) `TRANS <Label l>`) = loadTransition(l);
public Statement loadTransition((Transition) `TAKES <CharList ll> TO <Label l>`) = Transition(loadLabellist(ll), "<l>");

//Load varaible assignments, booleans or integers
public Statement loadVariableAss((VariableAssignment) `<Label l> := <BoolExpr e>`) = BooleanAssignment(loadBoolean(l), loadBoolExpr(e));
public Statement loadVariableAss((VariableAssignment) `<Label l> := <IntExpr i>`) = IntegerAssignment(loadInteger(l), loadIntExpr(i));

//Boolean expressions
public BooleanExpression loadBoolExpr((BoolExpr) `<Boolean b>`) = BooleanValue(loadBool(b));
public BooleanExpression loadBoolExpr((BoolExpr) `<Label l>`) = loadBoolean(l);
public BooleanExpression loadBoolExpr((BoolExpr) `NOT <BoolExpr b>`) = BooleanComparison(loadBoolExpr(b) ,BooleanValue(false));
public BooleanExpression loadBoolExpr((BoolExpr) `( <BoolExpr b> )`) = loadBoolExpr(b);
public BooleanExpression loadBoolExpr((BoolExpr) `<BoolExpr b1> AND <BoolExpr b2>`) = AndCondition(loadBoolExpr(b1), loadBoolExpr(b2));
public BooleanExpression loadBoolExpr((BoolExpr) `<BoolExpr b1> OR <BoolExpr b2>`) = OrCondition(loadBoolExpr(b1), loadBoolExpr(b2));
public BooleanExpression loadBoolExpr((BoolExpr) `<BoolExpr b1> = <BoolExpr b2>`) = BooleanComparison(loadBoolExpr(b1), loadBoolExpr(b2));
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \< <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 1);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \<= <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 2);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> = <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 3);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \>= <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 4);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \> <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 5);
public BooleanExpression loadBoolExpr((BoolExpr) `PROCESSING_CHAR = <Char c>`) = ProcessingCharComparison("<c>");

//Integer expressions
public IntegerExpression loadIntExpr((IntExpr) `<IntegerLiteral i>`) = IntegerValue(toInt("<i>"));
public IntegerExpression loadIntExpr((IntExpr) `<Label l>`) = loadInteger(l);
public IntegerExpression loadIntExpr((IntExpr) `( <IntExpr i> )`) = loadIntExpr(i);
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> + <IntExpr i2>`) = Addition(loadIntExpr(i1), loadIntExpr(i2));
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> - <IntExpr i2>`) = Subtraction(loadIntExpr(i1), loadIntExpr(i2));
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> * <IntExpr i2>`) = Multiplication(loadIntExpr(i1), loadIntExpr(i2));
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> / <IntExpr i2>`) = Division(loadIntExpr(i1), loadIntExpr(i2));

//Load int declarations and store them into the mappers
public list[IntegerExpression] loadIntDeclarations((DeclarationList) `<Declaration d> <DeclarationList dl>`) = loadIntDeclaration(d) + loadIntDeclarations(dl);
public list[IntegerExpression] loadIntDeclarations((DeclarationList) `<Declaration d>`) = loadIntDeclaration(d);
public list[IntegerExpression] loadIntDeclaration((Declaration) `INT <Label l> := <IntegerLiteral i>`) = {
	//Declare variable
	declaredIntegers["<l>"] = Integer("<l>", toInt("<i>"));
	return [loadInteger(l)];
};
public list[IntegerExpression] loadIntDeclaration((Declaration) `TRANS <Label l> := <Transition t>`) = [];
public list[IntegerExpression] loadIntDeclaration((Declaration) `BOOL <Label l> := <Boolean b>`) = [];

//Load boolean declrations and store them into the mapper
public list[BooleanExpression] loadBoolDeclarations((DeclarationList) `<Declaration d> <DeclarationList dl>`) = loadBoolDeclaration(d) + loadBoolDeclarations(dl);
public list[BooleanExpression] loadBoolDeclarations((DeclarationList) `<Declaration d>`) = loadBoolDeclaration(d);
public list[BooleanExpression] loadBoolDeclaration((Declaration) `INT <Label l> := <IntegerLiteral i>`) = [];
public list[BooleanExpression] loadBoolDeclaration((Declaration) `TRANS <Label l> := <Transition t>`) = [];
public list[BooleanExpression] loadBoolDeclaration((Declaration) `BOOL <Label l> := <Boolean b>`) = {
	//Declare variable
	declaredBooleans["<l>"] = Boolean("<l>", loadBool(b));
	return [loadBoolean(l)];
};
public bool loadBool ((Boolean) `TRUE`) = true;
public bool loadBool ((Boolean) `FALSE`) = false;

//Load Transitions and store them into the mapper
public list[Transition] loadTransitionDeclarations((DeclarationList) `<Declaration d> <DeclarationList dl>`) = loadTransitionDeclarations(d) + loadTransitionDeclarations(dl);
public list[Transition] loadTransitionDeclarations((DeclarationList) `<Declaration d>`) = loadTransitionDeclarations(d);
public list[Transition] loadTransitionDeclarations((Declaration) `INT <Label l> := <IntegerLiteral i>`) = [];
public list[Transition] loadTransitionDeclarations((Declaration) `BOOL <Label l> := <Boolean b>`) = [];
public list[Transition] loadTransitionDeclarations((Declaration) `TRANS <Label l> := <Transition t>`) = {
	declaredTransitions["<l>"] = loadTransition(t);
	return [];
};