package EFAL_Compiled_Example;

public class Automaton
{
	public int AutomatonType = 0;
	private State _currentState;
	
	// Generated variables
	public int amount_of_c = 0;
	public boolean only_once = false;
	
	public Automaton()
	{
	}
	
	public void run(String input)
	{
		for(int i = 0; i < input.length(); i++)
		{
			String character = Character.toString(input.charAt(i));
			this._currentState = this._currentState.processChar(this, character);
		}
	}
}
