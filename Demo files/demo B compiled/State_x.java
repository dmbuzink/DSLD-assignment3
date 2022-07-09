import java.util.Arrays;
import java.util.ArrayList;

public class State_x implements IState
{
	@Override
	public ArrayList<IState> processChar(Automaton automaton, String character) 
	{
		ArrayList<IState> newStates = new ArrayList<IState>();
		
			if(Arrays.asList("a", "b").contains(character))
			{	
				newStates.add(new State_x());
			}
		
			if((automaton.amount_of_ab < 3))
			{
				
					if(Arrays.asList("b").contains(character))
					{	
						newStates.add(new State_y());
					}
				
			}
		
			automaton.amount_of_ab = (automaton.amount_of_ab + 1);
		
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