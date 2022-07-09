import java.util.ArrayList;

public class Automaton {
	private int automatonType = 2;
	private IState currentState = new State_x();
	
	public int amount_of_ab = 0;
	
	public int some_variable = 0;
	
	
	public Automaton()
	{
	}

	public Automaton(IState state, int amount_of_ab, int some_variable)
	{
		this.currentState = state;
		
		this.amount_of_ab = amount_of_ab;
		
		this.some_variable = some_variable;
		
		
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
		return new Automaton(state, amount_of_ab, some_variable);
	}
}
