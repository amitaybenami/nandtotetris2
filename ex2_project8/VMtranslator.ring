load "Parser.ring"
load "CodeWriter.ring"

func main
    	if len(sysargv) > 2
		filePath = sysargv[3]
	else ?"Enter file name:" give filePath
	end

	pathType = getPathtype(filePath)
	if pathType != 1 and pathType != 2
		raise("Error: wrong path")
	end

	filename = fileName(filePath)

	if pathType = 1
		codeWriter = new CodeWriter(left(filePath,len(filePath)-3) + ".asm", pathType)
	else 
		codeWriter = new CodeWriter(filePath + "\" + filename +  ".asm", pathType)
	end

	if pathType = 1
		dirList = [[filename, 0]]
	else dirList = dir(filePath)
	end

	for file in dirList
		if not file[2] and right(file[1],3) = ".vm" //its a file with .vm extension
			if pathType = 2
				curPath = filePath + "\" + file[1]
			else curPath = filePath
			end
			parser = new Parser(curPath)
			codeWriter.setFileName(file[1])

			?"start translating " + file[1]
			while(parser.hasMoreCommands())
				parser.advance()
				commandType = parser.commandType()
				if commandType != "C_RETURN"
					arg1 = parser.arg1()
				end
				if commandType = "C_PUSH" or commandType = "C_POP" or 
				commandType = "C_CALL" or commandType = "C_FUNCTION"
					arg2 = parser.arg2()
				end
				if commandType = "C_ARITHMETIC"
					codeWriter.writeArithmetic(arg1)	
				elseif commandType = "C_PUSH" or commandType = "C_POP"
					codeWriter.writePushPop(commandType, arg1, arg2)
				elseif commandType = "C_LABEL"
					codeWriter.writeLabel(arg1)
				elseif commandType = "C_GOTO"
					codeWriter.writeGoto(arg1)
				elseif commandType = "C_IF"
					codeWriter.writeIf(arg1)
				elseif commandType = "C_FUNCTION"
					codeWriter.writeFunction(arg1,arg2)
				elseif commandType = "C_CALL"
					codeWriter.writeCall(arg1, arg2)
				elseif commandType = "C_RETURN"
					codeWriter.writeReturn()
				end
			end
		end
	end

	?"translation successed!"
	codeWriter.close()



func fileName(fullPath)
	y = reverse(fullPath)
	return reverse(left(y,substr(y,'\') - 1))	
		
