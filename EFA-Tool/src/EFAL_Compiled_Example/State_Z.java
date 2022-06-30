package EFAL_Compiled_Example;

import java.util.Arrays;

public class State_Z implements State {

	@Override
	public State processChar(Automaton automaton, String character) {
		if(Arrays.asList("a", "b").contains(character))
		{
			return this;
		}
		
		if(automaton.only_once) 
		{
			if(Arrays.asList("c").contains(character))
			{
				return this;
			}
		}
		else
		{
			automaton.only_once = true;
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
		return false;
	}
}
