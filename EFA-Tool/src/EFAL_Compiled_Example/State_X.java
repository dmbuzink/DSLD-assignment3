package EFAL_Compiled_Example;

import java.util.Arrays;

public class State_X implements State
{

	@Override
	public State processChar(Automaton automaton, String character) {
		if(Arrays.asList("a", "b").contains(character))
		{
			return new State_Y();
		}
		if(character.equals("c") && automaton.amount_of_c <= 2)
		{
			automaton.amount_of_c = automaton.amount_of_c + 1;
			return new State_Y();
		}
		else
		{
			if(Arrays.asList("c").contains(character))
			{
				return this;
			}
		}
		
		return new Fail_State();
	}
	
	@Override
	public boolean isEndState()
	{
		return true;
	}
	
}
