module EFAL::Check

import EFAL::AST;
import List;
import Boolean;
import IO;

list[int] validAutomationTypes = [1, 2, 3];
list[int] validIntegerComparisons = [1, 2, 3, 4, 5];

bool isValidAutomaton(Automaton automaton)
{
	if(Automaton(int automationType, list[str] alphabet, list[IntegerExpression] integerExpressions, 
		list[BooleanExpression] booleanExpressions, list[State] states) := automaton)
	{
		if (!(automationType in validAutomationTypes))
		{
			return false;
		}
		
		int numberOfBeginStates = 0;
		int numberOfEndStates = 0;
		list[str] stateLabels = getAllStateLabels(states);
		
		if(!labelsAreValid(integerExpressions, booleanExpressions, states))
		{
			return false;
		}
		
		for(State state <- states)
		{			
			if(State(str label, list[Statement] statements, bool isBeginState, bool isEndingState) := state)
			{
				// Keep track of number of begin and end states
				numberOfBeginStates += toInt(isBeginState);
				numberOfEndStates += toInt(isEndingState);
				
				// Ensure that, when defining a DFA, each state contains a transition for each symbol in the alphabet
				if(automationType == 1) // DFA
				{
					for(str char <- alphabet)
					{
						if(!transitionForEachSymbol(statements, char))
						{
							println("Not each symbol has a transition for the state: <label>, which is required for a DFA");
							return false;
						}
					}
				}
				
				if(!validateStatements(statements, stateLabels))
				{
					println("Invalid statement");
					return false;
				}
			}							
		}
		
		// Number of begin and end states checks
		if(numberOfBeginStates != 1)
		{
			return false;
		}
		if(numberOfEndStates == 0)
		{
			return false;
		}
	}
	
	return true;
}

// Ensure that a transition exists for a list of statements (intially from the state, but might be a branch in a conditionalWithElse)
bool transitionForEachSymbol(list[Statement] statements, str symbol)
{
	for(Statement statement <- statements)
	{
		switch(statement)
		{
			case Transition(list[str] chars, str stateLabel):
			{
				if(symbol in chars)
				{
					return true;
				}
			}
			
			case ConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse):
			{
				// Check if there exists a transition for symbol in both branches, if so a symbol will always have a transition
				if(transitionForEachSymbol(statementsIfTrue, symbol) && transitionForEachSymbol(statementsIfFalse, symbol))
				{
					return true;
				}
			}
		
			default:; 
			// If IntegerAssignment orBooleanAssignment won't contain a transition for the symbol. 
			// Conditional gets ignored since there is only a transition if that statement is true.
		}
	}

	return false;
}

// Validate labels
bool labelsAreValid(list[IntegerExpression] integers, list[BooleanExpression] booleans, list[State] states)
{
	// Create list with all pre-defined integers, also checking for double definitions.
	list[str] integerVarLabels = [];
	for(IntegerExpression integer <- integers)
	{
		if(Integer(str label, int val) := integer)
		{
			if(label in integerVarLabels || label == "PROCESSING_CHAR")
			{
				println("Integer labe: <label> defined more than once");
				//return [];
				return false;
			}
			
			integerVarLabels += label;
		}
	}
	
	// Create list with all pre-defined booleans, also checking for double definitions.
	list[str] booleanVarLabels = [];
	for(BooleanExpression boolean <- booleans)
	{
		if(Boolean(str label, bool val) := boolean)
		{
			if(label in booleanVarLabels || label == "PROCESSING_CHAR")
			{
				println("Boolean label: <label> defined more than once");
				return false;
			}
			
			booleanVarLabels += label;
		}
	}
	
	list[str] stateLabels = [];
	for(State state <- states)
	{
		if(State(str label, list[Statement] statements, bool isBeginState, bool isEndingState) := state)
		{
			if(label in stateLabels || label == "PROCESSING_CHAR")
			{
				println("State <label> defined more than once");
				return false;
			}
			
			stateLabels += label;
		}
	}
	
	
	if(size(integerVarLabels & booleanVarLabels) > 0)
	{
		println("A label gets used for both a boolean and an integer");
		return false;
	}
	
	return true;
}

bool validateStatements(list[Statement] statements, list[str] labelsOfStates)
{
	for(Statement statement <- statements)
	{
		if(!validateStatement(statement, labelsOfStates))
		{
			return false;
		}
	}
	return true;
}

bool validateStatement(Statement statement, list[str] labelsOfStates)
{
	switch(statement)
		{
			case Transition(list[str] chars, str state):
			{
				bool result = state in labelsOfStates;
				if(!result)
				{
					println("State <state> not defined");
				}
				return result;
			}
			case Conditional(BooleanExpression expr, list[Statement] condtionalStatements): 
			{
				bool result = validateStatements(condtionalStatements, labelsOfStates);
				if(!result)
				{
					println("Invalid conditional");
				}
				return result;
			}
			case ConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse): 
			{
				bool result = validateStatements(statementsIfTrue, labelsOfStates) || validateStatements(statementsIfFalse, labelsOfStates);
				if(!result)
				{
					println("Invalid conditional with else");
				}
				return result;
			}
			default: return true;
		}
}

list[str] getAllStateLabels(list[State] states)
{
	list[str] labels = [];	
	for(State state <- states)
	{
		if(State(str label, list[Statement] statements, bool isBeginState, bool isEndingState) := state)
		{
			labels += label;
		}
	}
	return labels;
}
