package EFAL_Compiled_Example;

public interface State 
{
	public State processChar(Automaton automaton, String character);
	
	public boolean isEndState();
}
