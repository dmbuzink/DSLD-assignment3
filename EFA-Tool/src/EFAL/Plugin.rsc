module EFAL::Plugin

import ParseTree;
import util::IDE;
import EFAL::Check;
import EFAL::CST2AST;
import EFAL::Syntax;
import EFAL::Compile;
import IO;
import String;

str trimEnd(str text)
{
	return text[0..findFirst(text, "A")] + trim(text[findFirst(text, "A")..]);
}

&T parseEFAL(loc file)
{
	return parse(#Automata, trimEnd(readFile(file)));
}

&T getAutomaton(loc file)
{
	return cst2ast(parseEFAL(file));
}

bool automatonIsValid(&T automaton)
{
	return isValidAutomaton(automaton);
}

void registerEFAL() {
	registerLanguage("EFAL", "EFAL", Tree(str _, loc path) {
		return parseEFAL(path);
  	});
}

// Compile the input to a set of java files that can be 
// run to test different string on the given automaton
void compile(loc file, loc dir)
{
	// Argument checks
	if(!exists(file))
	{
		println("No file was found at the given location");
		return;
	}
	if(!isDirectory(dir))
	{
		println("Given directory does not exist");
		return;
	}

	&T automaton = getAutomaton(file);
	if(!automatonIsValid(automaton))
	{
		println("Not a valid file");
		return;
	}
	list[tuple[str fileName, str content]] javaFiles = compileAutomaton(automaton);
	for(tuple[str fileName, str content] generatedFile <- javaFiles)
	{
		createFileWithContent(dir + "/<generatedFile.fileName>.java", generatedFile.content);
	}
	println("Successfully compiled");
}

void createFileWithContent(loc file, str content)
{
	writeFile(file, content);
}

