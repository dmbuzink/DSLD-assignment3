module EFAL::AST

// Defining the Abstract Syntax for EFAL (Extended Finite Automation Language)


// Automation type: 1: DFA, 2: NFA, 3: NFA-epsilon
data Automaton = Automaton(int automationType, list[str] alphabet, 
list[Statement] statements, list[Integer] integers, list[Boolean] booleans, list[State] states);

data Integer = Integer(str label, int val);

data Boolean = Boolean(str label, bool val);

data State = State(str label, list[Statement] statements);

data Statement = 
	  Transition(str label, list[str] chars, State state)
	| Conditional(Expression expr, list[Statement] statements) // Else can be a conditional with as the condition: "NOT IF_CONDITION"
	| IntegerAssignment(Integer integer, IntegerExpression intExpr)
	| BooleanAssignment(Boolean boolean, BooleanExpression boolExpr);

data BooleanExpression = 
	  BooleanValue(bool val)
	| ProcessingCharComparison(str char)
	| AndCondition(BooleanExpression cond1, BooleanExpression cond2)
	| OrCondition(BooleanExpression cond1, BooleanExpression cond2)
	| IntegerComparison(int val1, int val2, int integerComparer) // Integer comparer: 1: <, 2: <=, 3: =, 4: >=, 5: >
	| BooleanComparison(bool val1, bool val2); 
	// note: In the original syntax you may have: 
	// "if X" this can become a BooleanComparison with X and true. Likewise If not X with false

data IntegerExpression = 
	  IntegerValue(int val)
	| Addition(int val1, int val2)
	| Subtraction(int val1, int val2)
	| Multiplication(int val1, int val2)
	| Division(int val1, int val2);
	

