package EFAL_Compiled_Example;

public class Fail_State implements State {

	
	public State processChar(Automaton automaton, String character) {
		return this;
	}
	
	@Override
	public boolean isEndState()
	{
		return false;
	}
}
