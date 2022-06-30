package EFAL_Compiled_Example;

import java.util.Arrays;

public class State_Y implements State {

	@Override
	public State processChar(Automaton automaton, String character) {
		if(Arrays.asList("a", "b").contains(character))
		{
			return new State_Z();
		}
		
		if(automaton.amount_of_c > 2)
		{
			if(character.equals("c"))
			{
				return new State_Y();
			}
		}
		else
		{
			automaton.amount_of_c = automaton.amount_of_c + 1;
			if(character.equals("c"))
			{
				return new State_Y();
			}
		}
		
		return new Fail_State();
	}
	
	@Override
	public boolean isEndState()
	{
		return false;
	}
}
