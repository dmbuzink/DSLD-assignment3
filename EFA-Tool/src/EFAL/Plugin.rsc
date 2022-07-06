module EFAL::Plugin

import ParseTree;
import util::IDE;
import EFAL::Check;
import EFAL::CST2AST;
import EFAL::Syntax;
import EFAL::Compile;
import IO;

&T parseEFAL(loc file)
{
	return parse(#Automata, file);
}

&T getAutomaton(loc file)
{
	return cst2ast(parseEFAL(file));
}

bool checkWellformedness(loc file)
{
	return checkAutomaton(getAutomaton(file));
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
	list[tuple[str fileName, str content]] javaFiles = compileAutomaton(getAutomaton(file));
	for(tuple[str fileName, str content] generatedFile <- javaFiles)
	{
		createFileWithContent(dir + "/<generatedFile.fileName>.java", generatedFile.content);
	}
}

void createFileWithContent(loc file, str content)
{
	writeFile(file, content);
}

