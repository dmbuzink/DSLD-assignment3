import java.util.Arrays;
import java.util.ArrayList;

public class State_s10 implements IState
{
	@Override
	public ArrayList<IState> processChar(Automaton automaton, String character) 
	{
		ArrayList<IState> newStates = new ArrayList<IState>();
		
			if(character.equals("s"))
			{
				
					if((automaton.encountered_s_previously == false))
					{
						
							automaton.encountered_s_previously = true;
						
							if(Arrays.asList("s").contains(character))
							{	
								newStates.add(new State_s10());
							}
						
					}
					else
					{
						
							if(Arrays.asList("s").contains(character))
							{	
								newStates.add(new State_s11());
							}
						
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