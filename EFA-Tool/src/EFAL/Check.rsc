module EFAL::Check

import EFAL::AST;
import List;

List[int] validAutomationTypes = [1, 2, 3];
List[int] validIntegerComparisons = [1, 2, 3, 4, 5];

bool checkAutomaton(Automaton automaton)
{
	if(Automaton(int automationType, list[str] alphabet, list[Statement] statements, list[Integer] integers, list[Boolean] booleans, list[State] states) := automaton)
	{
		if (!(automationType in validAutomationTypes))
		{
			return false;
		}
		
		int numberOfBeginStates = 0;
		int numberOfEndStates = 0;
		
		getAllLabels(integers, booleans, states);
		//list[list[str]] labelLists = 
		//list[str] integerLabels = labelLists[0];
		//list[str] booleanLabels = labelLists[1];
		//list[str] stateLabels = labelLists[2];
		
		for(State state <- states)
		{
			bool isValid = false;
			
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
							return false;
						}
					}
				}				
			}							
		}
		
		// Number of begin and end states checks
		if(numberOfBeginStates != 1)
		{
			return false;
		}
		if(numberOfEndStates > 0)
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
			case Transition(list[str] chars, State state):
			{
				if(symbol in chars)
				{
					return true;
				}
			}
			
			case ConditionalWithElse(Expression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse):
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

// TODO: Remove
// Ensure that mentioned boolean/integer variables is pre-defined and not double defined
bool validateBooleanVariables(list[Statement] statements, list[Integer] integers, list[Boolean] booleans)
{
	// Create list with all pre-defined integers, also checking for double definitions.
	list[str] integerVarLabels = [];
	for(Integer integer <- integers)
	{
		if(Integer(str label, int val) := integer)
		{
			if(label in integerVarLabels)
			{
				return false;
			}
			
			integerVarLabels.push(label);
		}
	}
	
	// Create list with all pre-defined booleans, also checking for double definitions.
	list[str] booleanVarLabels = [];
	for(Boolean boolean <- booleans)
	{
		if(Boolean(str label, bool val) := boolean)
		{
			if(label in booleanVarLabels)
			{
				return false;
			}
			
			booleanVarLabels.push(label);
		}
	}
	
	list[str] labelIntersection = integerVarLabels & booleanVarLabels;
	//if(labelIntersection)
}

// Get labels of states, integers and booleans
// Returns an empty list if invalid
//list[list[str]] 
bool getAllLabels(list[Integer] integers, list[Boolean] booleans, list[State] states)
{
	// Create list with all pre-defined integers, also checking for double definitions.
	list[str] integerVarLabels = [];
	for(Integer integer <- integers)
	{
		if(Integer(str label, int val) := integer)
		{
			if(label in integerVarLabels || label == "PROCESSING_CHAR")
			{
				//return [];
				return false;
			}
			
			integerVarLabels.push(label);
		}
	}
	
	// Create list with all pre-defined booleans, also checking for double definitions.
	list[str] booleanVarLabels = [];
	for(Boolean boolean <- booleans)
	{
		if(Boolean(str label, bool val) := boolean)
		{
			if(label in booleanVarLabels || label == "PROCESSING_CHAR")
			{
				//return [];
				return false;
			}
			
			booleanVarLabels.push(label);
		}
	}
	
	list[str] stateLabels = [];
	for(State state <- states)
	{
		if(State(str label, list[Statement] statements, bool isBeginState, bool isEndingState) := state)
		{
			if(label in stateLabels || label == "PROCESSING_CHAR")
			{
				//return [];
				return false;
			}
			
			stateLabels.push(label);
		}
	}
	
	
	if(size(integerVarLabels & booleanVarLabels) > 0)
	{
		//return [];
		return false;
	}
	
	//return [integerVarLabels, booleanVarLabels, stateLabels];
	return true;
}

// Validates the labels of booleans, integer and states
//bool validateLabels(list[Statement] statements, list[str] integerLabels, list[str] booleanLabels, list[str] stateLabels)
//{
//	for(Statement statement <- statements)
//	{
//		switch(statement)
//		{
//			case Transition(list[str] chars, State state):
//			{
//				if()
//			}
//						
//			case Conditional(Expression expr, list[Statement] statementsIfTrue):
//			{
//				if(!validateLabels(statementsIfTrue, integerLabels, booleanLabels, stateLabels))
//				{
//					return false;
//				}
//			}
//			
//			case ConditionalWithElse(Expression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse):
//			{
//				if(!validateLabels(statementsIfTrue, integerLabels, booleanLabels, stateLabels) || 
//					!validateLabels(statementsIfFalse, integerLabels, booleanLabels, stateLabels))
//				{
//					return false;
//				}
//			}
//			
//			case IntegerAssignment(Integer integer, IntegerExpression intExpr):
//			{
//				if(Integer(str label, int val) := boolean)
//				{
//					if(!(label in integerLabels))
//					{
//						return false;
//					}
//				}
//			}
//					
//			case BooleanAssignment(Boolean boolean, BooleanExpression boolExpr):
//			{
//				if(Boolean(str label, bool val) := boolean)
//				{
//					if(!(label in booleanLabels))
//					{
//						return false;
//					}
//				}
//			}
//					
//			default: ;
//		}
//	}
//	
//	return true;
//}




