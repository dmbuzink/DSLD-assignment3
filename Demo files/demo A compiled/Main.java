import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class Main {

	public static void main(String args[]) throws IOException
	{
    	BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
    	while(true)
    	{
        	System.out.println("What string do you want to test? (type '!quit' to stop the program)");
        	String arg = reader.readLine();
        	if(arg.equals("!quit")) return;
        	if(new Automaton().isAccepted(arg))
        	{
            	System.out.println("Accepted!");
        	}
        	else
        	{
            	System.out.println("Rejected!");
        	}
    	}
	}
}