module EFAL::Check

import EFAL::AST;
import List;
import Boolean;

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
			return true;
		}
		
		for(State state <- states)
		{
			//bool isValid = false;
			
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
				
				if(!validateStatements(statements, stateLabels))
				{
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

// TODO: Remove
// Ensure that mentioned boolean/integer variables is pre-defined and not double defined
//bool validateBooleanVariables(list[Statement] statements, list[Integer] integers, list[Boolean] booleans)
//{
//	// Create list with all pre-defined integers, also checking for double definitions.
//	list[str] integerVarLabels = [];
//	for(Integer integer <- integers)
//	{
//		if(Integer(str label, int val) := integer)
//		{
//			if(label in integerVarLabels)
//			{
//				return false;
//			}
//			
//			integerVarLabels.push(label);
//		}
//	}
//	
//	// Create list with all pre-defined booleans, also checking for double definitions.
//	list[str] booleanVarLabels = [];
//	for(Boolean boolean <- booleans)
//	{
//		if(Boolean(str label, bool val) := boolean)
//		{
//			if(label in booleanVarLabels)
//			{
//				return false;
//			}
//			
//			booleanVarLabels.push(label);
//		}
//	}
//	
//	list[str] labelIntersection = integerVarLabels & booleanVarLabels;
//	//if(labelIntersection)
//}

// Get labels of states, integers and booleans
// Returns an empty list if invalid
//list[list[str]] 
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
				//return [];
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
				//return [];
				return false;
			}
			
			stateLabels += label;
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
				return state in labelsOfStates;
			case Conditional(BooleanExpression expr, list[Statement] condtionalStatements): 
				return validateStatements(condtionalStatements, labelsOfStates);
			case ConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse): 
				return validateStatements(statementsIfTrue, labelsOfStates) || validateStatements(statementsIfFalse, labelsOfStates);
			default: return false;
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




