import java.util.ArrayList;

public class Automaton {
	private int automatonType = 1;
	private IState currentState = new State_both_even();
	
	
	public Automaton()
	{
	}

	public Automaton(IState state)
	{
		this.currentState = state;
		
		
	}

	public boolean isAccepted(String input)
   {
		for(int i = 0; i < input.length(); i++)
		{
			String character = Character.toString(input.charAt(i));
			ArrayList<IState> newStates = this.currentState.processChar(this, character);
			if(this.automatonType == 1 || newStates.size() == 1)
			{
				this.currentState = newStates.get(0);
			}
			else
			{
				for(IState state : newStates)
				{
					if(copyWithNewState(state).isAccepted(input.substring(i + 1)))
					{
						return true;
					}
				}
				return false;
			}
		}
	
		return this.currentState.isEndState();
	}
	
	private Automaton copyWithNewState(IState state)
	{
		return new Automaton(state);
	}
}
