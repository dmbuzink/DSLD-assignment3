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
		return Automaton(loadAutomataType(t), loadAlphabet(a), loadIntDeclarations(d), loadBoolDeclarations(d), loadStates(s));
	};
	
public list[State] loadStates((StateList) `<State s> <StateList sl>`) = [loadState(s)] + loadStates(sl);
public list[State] loadStates((StateList) `<State s>`) = [loadState(s)];
public State loadState((State) `INITIAL STATE <Label l> : <StateContentList sc>`) = State("<l>", loadStateContentList(sc), true, false);
public State loadState((State) `INITIAL FINAL STATE <Label l> : <StateContentList sc>`) = State("<l>", loadStateContentList(sc), true, true);
public State loadState((State) `FINAL INITIAL STATE <Label l> : <StateContentList sc>`) = State("<l>", loadStateContentList(sc), true, true);
public State loadState((State) `FINAL STATE <Label l> : <StateContentList sc>`) = State("<l>", loadStateContentList(sc), false, true);
public State loadState((State) `STATE <Label l> : <StateContentList sc>`) = State("<l>", loadStateContentList(sc), false, false);
	
public list[Statement] loadStateContentList((StateContentList) `<StateContent s> <StateContentList l>`) = loadStateContent(s) + loadStateContentList(l);
public list[Statement] loadStateContentList((StateContentList) `<StateContent s>`) = loadStateContent(s);	
public list[Statement] loadStateContent((StateContent) `<Transition t>`) = [loadTransition(t)];
public list[Statement] loadStateContent((StateContent) `<VariableAssignment va>`) = [loadVariableAss(va)];
public list[Statement] loadStateContent((StateContent) `<IFELSE ie>`) = [loadIFELSE(ie)];

public Statement loadIFELSE((IFELSE) `IF <BoolExpr b> : <StateContentList sc1> ELSE : <StateContentList sc2>`) = ConditionalWithElse(loadBoolExpr(b), loadStateContentList(sc1), loadStateContentList(sc2));
public Statement loadIFELSE((IFELSE) `IF <BoolExpr b> : <StateContentList sc1>`) = Conditional(loadBoolExpr(b), loadStateContentList(sc1));

public Statement loadTransition((Transition) `TAKES <LabelList ll> TO <Label l>`) = Transition(loadLabellist(ll), "<l>");

//TODO Reuse the declared variables instead of creating new ones
public Statement loadVariableAss((VariableAssignment) `<Label l> := <BoolExpr e>`) = BooleanAssignment(Boolean("<l>", false), loadBoolExpr(e));
public Statement loadVariableAss((VariableAssignment) `<Label l> := <IntExpr i>`) = IntegerAssignment(Integer("<l>", 0), loadIntExpr(i));

public BooleanExpression loadBoolExpr((BoolExpr) `<Boolean b>`) = BooleanValue(loadBool(b));
//TODO use actual declared value
public BooleanExpression loadBoolExpr((BoolExpr) `<Label l>`) = Boolean("<l>", false);
public BooleanExpression loadBoolExpr((BoolExpr) `NOT <BoolExpr b>`) = BooleanComparison(loadBoolExpr(b) ,BooleanValue(false));
public BooleanExpression loadBoolExpr((BoolExpr) `<BoolExpr b1> AND <BoolExpr b2>`) = AndCondition(loadBoolExpr(b1), loadBoolExpr(b2));
public BooleanExpression loadBoolExpr((BoolExpr) `<BoolExpr b1> OR <BoolExpr b2>`) = OrCondition(loadBoolExpr(b1), loadBoolExpr(b2));
public BooleanExpression loadBoolExpr((BoolExpr) `<BoolExpr b1> = <BoolExpr b2>`) = BooleanComparison(loadBoolExpr(b1), loadBoolExpr(b2));
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \< <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 1);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \<= <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 2);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> = <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 3);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \>= <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 4);
public BooleanExpression loadBoolExpr((BoolExpr) `<IntExpr i1> \> <IntExpr i2>`) = IntegerComparison(loadIntExpr(i1), loadIntExpr(i2), 5);

public IntegerExpression loadIntExpr((IntExpr) `<IntegerLiteral i>`) = IntegerValue(toInt("<i>"));
//TODO also use the actual declared variable
public IntegerExpression loadIntExpr((IntExpr) `<Label l>`) = Integer("<l>", 0);
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> + <IntExpr i2>`) = Addition(loadIntExpr(i1), loadIntExpr(i2));
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> - <IntExpr i2>`) = Subtraction(loadIntExpr(i1), loadIntExpr(i2));
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> * <IntExpr i2>`) = Multiplication(loadIntExpr(i1), loadIntExpr(i2));
public IntegerExpression loadIntExpr((IntExpr) `<IntExpr i1> / <IntExpr i2>`) = Division(loadIntExpr(i1), loadIntExpr(i2));

public int loadAutomataType((AutomataType) `DFA`) = 0;
public int loadAutomataType((AutomataType) `NFA`) = 1;
public int loadAutomataType((AutomataType) `ENFA`) = 2;

public list[str] loadAlphabet((Alphabet) `ALPHABET := <LabelList l>`) = loadLabellist(l);
public list[str] loadLabellist((LabelList) `<Label l> , <LabelList ls>`) = ["<l>"] + loadLabellist(ls);
public list[str] loadLabellist((LabelList) `<Label l>`) = ["<l>"];

public list[IntegerExpression] loadIntDeclarations((DeclarationList) `<Declaration d> <DeclarationList dl>`) = loadIntDeclaration(d) + loadIntDeclarations(dl);
public list[IntegerExpression] loadIntDeclarations((DeclarationList) `<Declaration d>`) = loadIntDeclaration(d);
public list[IntegerExpression] loadIntDeclaration((Declaration) `INT <Label l> := <IntegerLiteral i>`) = [Integer("<l>", toInt("<i>"))];
public list[IntegerExpression] loadIntDeclaration((Declaration) `TRANS <Label l> := <Transition t>`) = [];
public list[IntegerExpression] loadIntDeclaration((Declaration) `BOOL <Label l> := <Boolean b>`) = [];

public list[BooleanExpression] loadBoolDeclarations((DeclarationList) `<Declaration d> <DeclarationList dl>`) = loadBoolDeclaration(d) + loadBoolDeclarations(dl);
public list[BooleanExpression] loadBoolDeclarations((DeclarationList) `<Declaration d>`) = loadBoolDeclaration(d);
public list[BooleanExpression] loadBoolDeclaration((Declaration) `INT <Label l> := <IntegerLiteral i>`) = [];
public list[BooleanExpression] loadBoolDeclaration((Declaration) `TRANS <Label l> := <Transition t>`) = [];
public list[BooleanExpression] loadBoolDeclaration((Declaration) `BOOL <Label l> := <Boolean b>`) = [Boolean("<l>", loadBool(b))];
public bool loadBool ((Boolean) `TRUE`) = true;
public bool loadBool ((Boolean) `FALSE`) = false;