import java.util.ArrayList;

public class Fail_State implements IState
{
	@Override
	public ArrayList<IState> processChar(Automaton automaton, String character) {
		ArrayList<IState> states = new ArrayList<IState>();
		states.add(this);
			return states;
	}

	@Override
	public boolean isEndState()
	{
		return false;
	}
}
