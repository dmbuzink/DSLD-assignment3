module EFAL::AST

// Defining the Abstract Syntax for EFAL (Extended Finite Automation Language)


// Automation type: 1: DFA, 2: NFA, 3: NFA-epsilon
data Automaton = Automaton(int automatonType, list[str] alphabet, 
	list[IntegerExpression] integers, list[BooleanExpression] booleans, list[State] states);

data State = State(str label, list[Statement] statements, bool isBeginState, bool isEndingState);

data Statement = 
	  Transition(list[str] chars, str state)
	| Conditional(BooleanExpression expr, list[Statement] statements)
	| ConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse)
	| IntegerAssignment(IntegerExpression integer, IntegerExpression intExpr)
	| BooleanAssignment(BooleanExpression boolean, BooleanExpression boolExpr);

data BooleanExpression = 
	  BooleanValue(bool val)
	| Boolean(str label, bool intialValue)
	| ProcessingCharComparison(str char)
	| AndCondition(BooleanExpression cond1, BooleanExpression cond2)
	| OrCondition(BooleanExpression cond1, BooleanExpression cond2)
	| IntegerComparison(IntegerExpression int1, IntegerExpression int2, int integerComparer) // Integer comparer: 1: <, 2: <=, 3: =, 4: >=, 5: >
	| BooleanComparison(BooleanExpression bool1, BooleanExpression bool2); 

data IntegerExpression = 
	  IntegerValue(int val)
	| Integer(str label, int initialValue)
	| Addition(IntegerExpression val1, IntegerExpression val2)
	| Subtraction(IntegerExpression val1, IntegerExpression val2)
	| Multiplication(IntegerExpression val1, IntegerExpression val2)
	| Division(IntegerExpression val1, IntegerExpression val2);
	
