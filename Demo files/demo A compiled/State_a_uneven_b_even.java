import java.util.Arrays;
import java.util.ArrayList;

public class State_a_uneven_b_even implements IState
{
	@Override
	public ArrayList<IState> processChar(Automaton automaton, String character) 
	{
		ArrayList<IState> newStates = new ArrayList<IState>();
		
			if(Arrays.asList("a").contains(character))
			{	
				newStates.add(new State_both_even());
			}
		
			if(Arrays.asList("b").contains(character))
			{	
				newStates.add(new State_both_uneven());
			}
		
		if(newStates.size() == 0)
		{
			newStates.add(new Fail_State());
		}	
		return newStates;
	}

	@Override
	public boolean isEndState()
	{
		return false;
	}
}