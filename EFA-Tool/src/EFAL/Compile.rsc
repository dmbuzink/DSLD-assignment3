module EFAL::Compile

import EFAL::AST;
import Boolean;
import ListRelation;
import List;

// Compile automaton
list[tuple[str fileName, str content]] compileAutomaton(Automaton a)
{
	list[tuple[str fileName, str content]] javaFiles = [getMainClass(), compileAutomatonSelf(a), getStateInterface(), getFailState()];
	if(Automaton(int automatonType, list[str] alphabet, list[IntegerExpression] integers, list[BooleanExpression] booleans, list[State] states) := a)
	{
  			//javaFiles = javaFiles + getMainClass() + compileAutomatonSelf(a) + getStateInterface() + getFailState();
  			for(State state <- states)
  			{
  				javaFiles = javaFiles + <"State_<getLabelFromState(state)>", compile(state)>;
  			}
	}
	
	return javaFiles;
}

tuple[str, str] compileAutomatonSelf(Automaton a)
{ 
	if(Automaton(int automatonType, list[str] alphabet, list[IntegerExpression] integers, list[BooleanExpression] booleans, list[State] states) := a)
	{
		str automatonFileContent = "import java.util.ArrayList;
			'
			'public class Automaton {
  			'	private int automatonType = <automatonType>;
  			'	private IState currentState = new State_<getBeginStateLabel(states)>();
  			'	<for (integer <- integers) {>
  			'	<compileIntegerVariable(integer)>
  			'	<}>
  			'	<for (boolean <- booleans) {>
  			'	<compileBooleanVariable(boolean)>
  			'	<}>
  			'	public Automaton()
			'	{
			'	}
			'
			'	public Automaton(<getAutomatonConstructorParameters(integers, booleans)>)
			'	{
			'		this.currentState = state;
			'		<for (integer <- integers) {>
  			'		<compileCopyInteger(integer)>
  			'		<}>
  			'		<for (boolean <- booleans) {>
  			'		<compileCopyBoolean(boolean)>
  			'		<}>
			'	}
			'
			'	public boolean isAccepted(String input)
			'   {
			'		for(int i = 0; i \< input.length(); i++)
			'		{
			'			String character = Character.toString(input.charAt(i));
			'			ArrayList\<IState\> newStates = this.currentState.processChar(this, character);
			'			if(this.automatonType == 1 || newStates.size() == 1)
			'			{
			'				this.currentState = newStates.get(0);
			'			}
			'			else
			'			{
			'				for(IState state : newStates)
			'				{
			'					if(copyWithNewState(state).isAccepted(input.substring(i + 1)))
			'					{
			'						return true;
			'					}
			'				}
			'				return false;
			'			}
			'		}
			'	
			'		return this.currentState.isEndState();
			'	}
			'	
			'	private Automaton copyWithNewState(IState state)
			'	{
			'		return new Automaton(<getAutomatonConstructorArguments(integers, booleans)>);
			'	}
  			'}
  			'";
  			return <"Automaton", automatonFileContent>;
	}
	else return <"", "">;
}

str getAutomatonConstructorParameters(list[IntegerExpression] integers, list[BooleanExpression] booleans)
{
	str result = "IState state, ";
	for(IntegerExpression integerExpr <- integers)
	{
		if(Integer(str label, int initialValue) := integerExpr)
		{
			result += "int <label>, ";
		}
	}
	for(BooleanExpression boolExpr <- booleans)
	{
		if(Boolean(str label, bool initialValue) := boolExpr )
		{
			result += "boolean <label>, ";
		}
	}
	return result[..-2];
}

str getAutomatonConstructorArguments(list[IntegerExpression] integers, list[BooleanExpression] booleans)
{
	str result = "state, ";
	for(IntegerExpression integerExpr <- integers)
	{
		if(Integer(str label, int initialValue) := integerExpr)
		{
			result += "<label>, ";
		}
	}
	for(BooleanExpression boolExpr <- booleans)
	{
		if(Boolean(str label, bool initialValue) := boolExpr )
		{
			result += "<label>, ";
		}
	}
	return result[..-2];
}

str compileCopyInteger(IntegerExpression integerExpr)
{
	if(Integer(str label, int initialValue) := integerExpr)
	{
		return "this.<label> = <label>;";
	}
	else
	{
		return "";
	}
}

str compileCopyBoolean(BooleanExpression boolExpression)
{
	if(Boolean(str label, bool initialValue) := boolExpression)
	{
		return "this.<label> = <label>;";
	}
	else
	{
		return "";
	}
}

tuple[str, str] getMainClass() = 
	<"Main", 
	"import java.io.BufferedReader;
	'import java.io.IOException;
	'import java.io.InputStreamReader;
	'
	'public class Main {
	'
    '	public static void main(String args[]) throws IOException
    '	{
    '    	BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
    '    	while(true)
    '    	{
    '        	System.out.println(\"What string do you want to test? (type \'!quit\' to stop the program)\");
    '        	String arg = reader.readLine();
    '        	if(arg.equals(\"!quit\")) return;
    '        	if(new Automaton().isAccepted(arg))
    '        	{
    '            	System.out.println(\"Accepted!\");
    '        	}
    '        	else
    '        	{
    '            	System.out.println(\"Rejected!\");
    '        	}
    '    	}
    '	}
	'}">;
  
tuple[str,str] getStateInterface() = 
	<"IState",
	"import java.util.ArrayList;
	'
	'public interface IState 
	'{
	'	public ArrayList\<IState\> processChar(Automaton automaton, String character);
	'
	'	public boolean isEndState();
	'}">;

tuple[str,str] getFailState() = 
	<"Fail_State",
	"import java.util.ArrayList;
	'
	'public class Fail_State implements IState
	'{
	'	@Override
	'	public ArrayList\<IState\> processChar(Automaton automaton, String character) {
	'		ArrayList\<IState\> states = new ArrayList\<IState\>();
	'		states.add(this);
			return states;
	'	}
	'
	'	@Override
	'	public boolean isEndState()
	'	{
	'		return false;
	'	}
	'}
	'">;
  
str compileIntegerVariable(IntegerExpression integer)
{
	if(Integer(str label, int initialValue) := integer)
	{
		return "public int <label> = <initialValue>;";
	}
	else return "";
}

str compileBooleanVariable(BooleanExpression boolean)
{
	if(Boolean(str label, bool initialValue) := boolean)
	{
		return "public boolean <label> = <toString(initialValue)>;";
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
		'import java.util.ArrayList;
		'
		'public class State_<label> implements IState
		'{
		'	@Override
		'	public ArrayList\<IState\> processChar(Automaton automaton, String character) 
		'	{
		'		ArrayList\<IState\> newStates = new ArrayList\<IState\>();
		'		<for (statement <- statements) {>
		'			<compile(statement)>
		'		<}>
		'		if(newStates.size() == 0)
		'		{
		'			newStates.add(new Fail_State());
		'		}	
		'		return newStates;
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
		case Transition(list[str] chars, str stateName): 
			return compileTransition(chars, stateName);
		
		case Conditional(BooleanExpression expr, list[Statement] statements): 
			return compileConditional(expr, statements);
		
		case ConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse): 
			return compileConditionalWithElse(expr, statementsIfTrue, statementsIfFalse);
		
		case IntegerAssignment(IntegerExpression integer, IntegerExpression intExpr): 
			return compileIntegerAssignment(integer, intExpr);
		
		case BooleanAssignment(BooleanExpression boolean, BooleanExpression boolExpr): 
			return compileBooleanAssignment(boolean, boolExpr);
	}
	
	return "";
}

str compileTransition(list[str] chars, str stateName)
{
	str charList = "";
	for(str char <- chars)
	{
		charList += "\"<char>\", ";
	}
	charList = charList[..-2];

	return 
	"if(Arrays.asList(<charList>).contains(character))
	'{	
	'	newStates.add(new State_<stateName>());
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

str compileIntegerAssignment(IntegerExpression integer, IntegerExpression intExpr)
{
	return "automaton.<getLabelFromInteger(integer)> = <compileIntegerExpression(intExpr)>;";
}

str compileIntegerExpression(IntegerExpression intExpr)
{
	switch(intExpr)
	{
		case IntegerValue(int val): 
			return "<val>";
			
		case Integer(str label, int initialValue):
			return "automaton.<label>";
		
		case Addition(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> + <compileIntegerExpression(val2)>)";
		
		case Subtraction(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> - <compileIntegerExpression(val2)>)";
		
		case Multiplication(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> * <compileIntegerExpression(val2)>)";
		
		case Division(IntegerExpression val1, IntegerExpression val2): 
			return "(<compileIntegerExpression(val1)> / <compileIntegerExpression(val2)>)";
		
		default: return "";
	}
}

str compileBooleanAssignment(BooleanExpression boolean, BooleanExpression boolExpr)
{
	if(Boolean(str label, bool val) := boolean)
	{
		return "automaton.<getLabelFromBoolean(boolean)> = <compileBooleanExpression(boolExpr)>;";
	}
	return "";
	
}

str compileBooleanExpression(BooleanExpression boolExpr)
{
	switch(boolExpr)
	{
		case BooleanValue(bool val): 
			return "<toString(val)>";
			
		case Boolean(str label, bool initialValue):
			return "automaton.<label>";
		
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

str getLabelFromBoolean(BooleanExpression boolExpr)
{
	if(Boolean(str label, bool initialValue) := boolExpr)
	{
		return label;
	}
	return "";
}

str getLabelFromInteger(IntegerExpression intExpr)
{
	if(Integer(str label, int initialValue) := intExpr)
	{
		return label;
	}
	return "";
}



