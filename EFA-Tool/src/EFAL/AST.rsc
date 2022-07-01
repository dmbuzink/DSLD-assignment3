module EFAL::AST

// Defining the Abstract Syntax for EFAL (Extended Finite Automation Language)


// Automation type: 1: DFA, 2: NFA, 3: NFA-epsilon
data Automaton = Automaton(int automatonType, list[str] alphabet, 
	list[Integer] integers, list[Boolean] booleans, list[State] states);

data Integer = Integer(str label, int val);

data Boolean = Boolean(str label, bool val);

data State = State(str label, list[Statement] statements, bool isBeginState, bool isEndingState);

data Statement = 
	  Transition(list[str] chars, State state)
	| Conditional(BooleanExpression expr, list[Statement] statements) // Else can be a conditional with as the condition: "NOT IF_CONDITION"
	| ConditionalWithElse(BooleanExpression expr, list[Statement] statementsIfTrue, list[Statement] statementsIfFalse)
	| IntegerAssignment(Integer integer, IntegerExpression intExpr)
	| BooleanAssignment(Boolean boolean, BooleanExpression boolExpr);

data BooleanExpression = 
	  BooleanValue(bool val)
	| ProcessingCharComparison(str char)
	| AndCondition(BooleanExpression cond1, BooleanExpression cond2)
	| OrCondition(BooleanExpression cond1, BooleanExpression cond2)
	| IntegerComparison(IntegerExpression int1, IntegerExpression int2, int integerComparer) // Integer comparer: 1: <, 2: <=, 3: =, 4: >=, 5: >
	| BooleanComparison(BooleanExpression bool1, BooleanExpression bool2); 
	// note: In the original syntax you may have: 
	// "if X" this can become a BooleanComparison with X and true. Likewise If not X with false

data IntegerExpression = 
	  IntegerValue(int val)
	| Addition(IntegerExpression val1, IntegerExpression val2)
	| Subtraction(IntegerExpression val1, IntegerExpression val2)
	| Multiplication(IntegerExpression val1, IntegerExpression val2)
	| Division(IntegerExpression val1, IntegerExpression val2);
	

