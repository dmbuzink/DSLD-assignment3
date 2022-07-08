import java.util.ArrayList;

public interface IState 
{
	public ArrayList<IState> processChar(Automaton automaton, String character);

	public boolean isEndState();
}