import java.util.Arrays;
import java.util.ArrayList;

public class State_s6 implements IState
{
	@Override
	public ArrayList<IState> processChar(Automaton automaton, String character) 
	{
		ArrayList<IState> newStates = new ArrayList<IState>();
		
			if(Arrays.asList("0").contains(character))
			{	
				newStates.add(new State_s7());
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