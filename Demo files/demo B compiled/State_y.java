import java.util.Arrays;
import java.util.ArrayList;

public class State_y implements IState
{
	@Override
	public ArrayList<IState> processChar(Automaton automaton, String character) 
	{
		ArrayList<IState> newStates = new ArrayList<IState>();
		
			if(Arrays.asList("a", "b").contains(character))
			{	
				newStates.add(new State_z());
			}
		
			if((automaton.some_variable < 3))
			{
				
					if(Arrays.asList("a").contains(character))
					{	
						newStates.add(new State_y());
					}
				
			}
		
			if((automaton.some_variable >= 3))
			{
				
					if(Arrays.asList("a").contains(character))
					{	
						newStates.add(new State_z());
					}
				
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