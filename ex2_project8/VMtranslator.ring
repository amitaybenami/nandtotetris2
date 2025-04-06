load "Parser.ring"
load "CodeWriter.ring"

func main
    	if len(sysargv) > 2
		filePath = sysargv[3]
	else ?"Enter file name:" give filePath
	end
	
	parser = new Parser(filePath)

	filename = fileName(filePath)
	codeWriter = new CodeWriter(left(filePath,len(filePath)-3) + ".asm")
	codeWriter.setFileName(filename)
	
	?"start translating"
	while(parser.hasMoreCommands())
		parser.advance()
		commandType = parser.commandType()
		if commandType = "C_ARITHMETIC"
			arg1 = parser.arg1()
			codeWriter.writeArithmetic(arg1)	
		elseif commandType = "C_PUSH" or commandType = "C_POP"
			arg1 = parser.arg1()
			arg2 = parser.arg2()
			codeWriter.writePushPop(commandType, arg1, arg2)
		end
	end
	?"translation successed!"
	codeWriter.close()



func fileName(fullPath)
	y = reverse(fullPath)
	return reverse(left(y,substr(y,'\') - 1))	
		
