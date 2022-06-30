module EFAL::Compile

import EFAL::AST;
import Boolean;

// Multiple approaches?
// Compiler for SMT: https://github.com/usethesource/rascal/blob/main/src/org/rascalmpl/library/lang/smtlib2/Compiler.rsc
// Factory for JSON reader and writer: https://github.com/usethesource/rascal/blob/main/src/org/rascalmpl/library/lang/json/Factory.java

// Trying this approach: https://usethesource.io/dsl-in-36-lines-of-code
// String templates:
// https://tutor.rascal-mpl.org/Recipes/Common/StringTemplate/StringTemplate.html
// https://tutor.rascal-mpl.org/Rascal/Expressions/Values/String/String.html
  
// Maybe return a list of strs? One for each file.
str compile(Automaton a){
	if(Automaton(int automatonType, list[str] alphabet, list[Integer] integers, list[Boolean] booleans, list[State] states) := a)
	{
		return "public class Automaton {
  			'	public int AutomatonType = <automatonType>;
  			'	private State currentState = new State_<getBeginStateLabel(states)>();
  			'
  			'	<for (integer <- integers) {>
  			'		<compile(integer)>
  			'	<}>
  			'	<for (boolean <- booleans) {>
  			'	<compile(boolean)>
  			'	<}>
  			'
  			'	public Automaton()
			'	{
			'	}
			'	
			'	public void run(String input)
			'   {
			'		for(int i = 0; i \< input.length(); i++)
			'		{
			'			String character = Character.toString(input.charAt(i));
			'			this._currentState = this._currentState.processChar(this, character);
			'		}
			'	}
  			'}
  			'
  			'<getStateInterface()>
  			'
  			'<getFailState()>
  			'
  			'<for (state <- states) {>
  			'	<compile(state)>
  			'<}>";
	}
	else return "";
  
  }
  
str getStateInterface() = 
	"public interface State 
	'{
	'	public State processChar(Automaton automaton, String character);
	'
	'	public boolean isEndState();
	'}";

str getFailState() = 
	"public class Fail_State implements State
	'{
	'	@Override
	'	public State processChar(Automaton automaton, String character) {
	'		return this;
	'	}
	'
	'	@Override
	'	public boolean isEndState()
	'	{
	'		return false;
	'	}
	'}
	";
  
str compile(Integer integer)
{
	if(Integer(str label, int val) := integer)
	{
		return "public int <label> = <val>;";
	}
	else return "";
}

str compile(Boolean boolean)
{
	if(Boolean(str label, bool val) := boolean)
	{
		return "public boolean <label> = <toString(val)>;";
	}
	else return "";
}
  
str getBeginStateLabel(list[State] states)
{
	for(State state <- states)
	{
		if(State(str label, list[Statement] statements, bool isBeginState, bool isEndingState) := state && isBeginState)
		{
			return label;
		}
	}
	
	return "";
}

str compile(State state)
{
	if(State(str label, list[Statement] statements, bool isBeginState, bool isEndingState) := state)
	{
		return 
		"import java.util.Arrays;
		'
		'public class State_<label> implements State
		'{
		'	@Override
		'	public State processChar(Automaton automaton, String character) 
		'	{
		'		<for (statement <- statements) {>
		'			<compile(statement)>
		'		<}>
		'		return new Fail_State();		
		'	}
		'
		'	@Override
		'	public boolean isEndState()
		'	{
		'		return <toString(isEndingState)>;
		'	}
		'}";
	}
	return "";
}

str compile(Statement statement)
{
	switch(statement)
	{
		case Transition(list[str] chars, State state): 
			return compileTransition(chars, state);
		
		case Conditional(BooleanExpression expr, list[Statement] statements): 
			return compileConditional(expr, statements);
		
		case ConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse): 
			return compileConditionalWithElse(expr, statementsIfTrue, statementsIfFalse);
		
		case IntegerAssignment(Integer integer, IntegerExpression intExpr): 
			return compileIntegerAssignment(integer, intExpr);
		
		case BooleanAssignment(Boolean boolean, BooleanExpression boolExpr): 
			return compileBooleanAssignment(boolean, boolExpr);
	}
	
	return "";
}

str compileTransition(list[str] chars, State state)
{
	str charList = "";
	for(str char <- chars)
	{
		charList += "<char>, ";
	}
	charList = charList[..-2];

	return 
	"if(Arrays.asList(<charList>).contains(character))
	'{	
	'	return new State_<getLabelFromState(state)>;
	'}";
}

str compileConditional(BooleanExpression expr, list[Statement] statements)
{
	return 
	"if(<compileBooleanExpression(expr)>)
	'{
	'	<for (statement <- statements) {>
	'		<compile(statement)>
	'	<}>
	'}";
}

str compileConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse)
{
	return 
	"if(<compileBooleanExpression(expr)>)
	'{
	'	<for (statement <- statementsIfTrue) {>
	'		<compile(statement)>
	'	<}>
	'}
	'else
	'{
	'	<for (statement <- statementsIfFalse) {>
	'		<compile(statement)>
	'	<}>
	'}";
}

str compileIntegerAssignment(Integer integer, IntegerExpression intExpr)
{
	if(Integer(str label, int val) := integer)
	{
		return "automaton.<label> = <compileIntegerExpression(intExpr)>;";
	}
	return "";
}

str compileIntegerExpression(IntegerExpression intExpr)
{
	switch(intExpr)
	{
		case IntegerValue(int val): 
			return "<val>";
		
		case Addition(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> + <compileIntegerExpression(val2)>);";
		
		case Subtraction(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> - <compileIntegerExpression(val2)>);";
		
		case Multiplication(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> * <compileIntegerExpression(val2)>);";
		
		case Division(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> / <compileIntegerExpression(val2)>);";
		
		default: return "";
	}
}

str compileBooleanAssignment(Boolean boolean, BooleanExpression boolExpr)
{
	if(Boolean(str label, bool val) := boolean)
	{
		return "automaton.<label> = <compileBooleanExpression(boolExpr)>;";
	}
	return "";
	
}

str compileBooleanExpression(BooleanExpression boolExpr)
{
	switch(boolExpr)
	{
		case BooleanValue(bool val): 
			return "<toString(val)>";
		
		case ProcessingCharComparison(str char): 
			return "character.equals(\"<char>\")";
		
		case AndCondition(BooleanExpression cond1, BooleanExpression cond2): 
			return "(compileBooleanExpression(cond1) && <compileBooleanExpression(cond2)>)";
		
		case IntegerComparison(IntegerExpression int1, IntegerExpression int2, int integerComparer): 
			return "(<compileIntegerExpression(int1)> <getIntegerComparerSymbol(integerComparer)> <compileIntegerExpression(int2)>)";
			
		case BooleanComparison(BooleanExpression bool1, BooleanExpression bool2):
			return "(<compileBooleanExpression(bool1)> == <compileBooleanExpression(bool2)>)";
		
		default: return "";
	}
}

str getIntegerComparerSymbol(int integerComparer)
{	
	switch(integerComparer)
	{
		case 1: return "\<";
		case 2: return "\<=";
		case 3: return "==";
		case 4: return "\>=";
		case 5: return "\>";
		
		default: return "";
	}
}


str getLabelFromState(State state)
{
	if(State(str label, list[Statement] statements, bool isBeginState, bool isEndingState) := state)
	{
		return label;
	}
	else return "";
}

