class CodeWriter
	
	func init filepath, _pathType //constuctor - opens the output filefor writing
		outputfile = fopen(filepath, "w")
		pathType = _pathType
		if pathType = 2
			fwrite(outputfile, "@256" + nl)
			fwrite(outputfile, "D=A" + nl)
			fwrite(outputfile, "@SP" + nl)
			fwrite(outputfile, "M=D" + nl)
			writeCall("Sys.init", 0)
		end

	func setFileName _filename
		//inform the codeWriter about new file reading
		filename = left(_filename,len(_filename)-3)//without .vm extension
		main_compares = 0
		main_returns = 0
		funcEnd()

	func writeArithmetic command
	//writes assembly for given arithmetic command in output file
		fwrite(outputfile, "//" + command + nl)	
		fwrite(outputfile, "@SP" + nl)
		if command = "add" or command = "sub" or command = "eq" or command = "gt" or 
		command = "lt" or command = "and" or command = "or"//two operands
			fwrite(outputfile, "AM=M-1" + nl)		
			fwrite(outputfile, "D=M" + nl)//pop
			fwrite(outputfile, "A=A-1" + nl)
			if command = "add" fwrite(outputfile, "M=D+M" + nl)
			elseif command = "sub" fwrite(outputfile, "M=M-D" + nl)
			elseif command = "and" fwrite(outputfile, "M=D&M" + nl)
			elseif command = "or" fwrite(outputfile, "M=D|M" + nl)
			elseif command = "eq" or command = "gt" or command = "lt"
				cmpOperation(command)
			end
		elseif command = "not" 
			fwrite(outputfile, "A=M-1" + nl)
			fwrite(outputfile, "M=!M" + nl)
		elseif command = "neg" 
			fwrite(outputfile, "A=M-1" + nl)
			fwrite(outputfile, "M=-M" + nl)
		else raise("CodeWritingError: unrecognized arithmetic command")
		end

		
	
	func writePushPop command, segment, index 	
	//writes assembly for given push/pop command in output file
	fwrite(outputfile,"//" + command + " " + segment + " " + index + nl)
	if segment = "local" or segment = "argument" or segment = "this" or segment = "that"
		if segment = "local" fwrite(outputfile, "@LCL" + nl)
		elseif segment = "argument" fwrite(outputfile, "@ARG" + nl)
		else	fwrite(outputfile, "@" + upper(segment) + nl)
		end
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@" + index + nl)
		if command = "C_POP"
			fwrite(outputfile, "D=D+A" + nl)
			fwrite(outputfile, "@R13" + nl)
			fwrite(outputfile, "M=D" + nl)	
			popToD()
			fwrite(outputfile, "@R13" + nl)
			fwrite(outputfile, "A=M" + nl)
		elseif command = "C_PUSH"
			fwrite(outputfile, "A=D+A" + nl)
			fwrite(outputfile, "D=M" + nl)
		end
	elseif segment = "constant"
		if command = "C_POP"
			raise("CodeWritingError: cannot pop to constant")
		end
		fwrite(outputfile, "@" + index + nl)
		fwrite(outputfile, "D=A" + nl)
	elseif segment = "static"
		if command = "C_POP"
			popToD()
			fwrite(outputfile, "@" + filename + "." + index + nl)
		elseif command = "C_PUSH"
			fwrite(outputfile, "@" + filename + "." + index + nl)
			fwrite(outputfile, "D=M" + nl)	
		end
	elseif segment = "temp"
		if command = "C_POP"
			popToD()
			fwrite(outputfile, "@" + (5 + index) + nl)
		elseif command = "C_PUSH"
			fwrite(outputfile, "@" + (5 + index) + nl)
			fwrite(outputfile, "D=M" + nl)
		end	
	elseif segment = "pointer"
		if index = 0
			pointer = "THIS"
		elseif index = 1 
			pointer = "THAT"
		else raise("CodeWritingError: pointer segment's index must be 0/1")
		end
		if command = "C_POP"
			popToD()
			fwrite(outputfile, "@" + pointer + nl)
		elseif command = "C_PUSH"
			fwrite(outputfile, "@" + pointer + nl)
			fwrite(outputfile, "D=M" + nl)
		end
	else raise("CodeWritingError: unrecognized segment")
	end
	if command = "C_POP" 
		fwrite(outputfile, "M=D" + nl)
	elseif command = "C_PUSH"
		pushD() 
	end

	func writeLabel label //writes assembly for a label command
		fwrite(outputfile, "//label " + label + nl)	
		fwrite(outputfile, "(" + currentFunc + "$" + label + ")" + nl)

	func writeGoto label //writes assembly for a goto command
		fwrite(outputfile, "//goto" + label + nl)	
		fwrite(outputfile, "@" + currentFunc + "$" + label + nl)
		fwrite(outputfile, "0;JMP" + nl)
	
	func writeIf label //writes assembly for a if-goto command
		fwrite(outputfile, "//if-goto " + label + nl)	
		popToD()
		fwrite(outputfile, "@" + currentFunc + "$" + label + nl)
		fwrite(outputfile, "D;JNE" + nl)

	func writeFunction functionName, nVars //writes assembly for a function command
		fwrite(outputfile, "//function " + functionName + " " + nVars + nl)	
		newFunc(functionName)
		fwrite(outputfile, "(" + currentFunc + ")" + nl)

		//push nVars 0's to stack:
		if nVars > 0
			fwrite(outputfile, "@SP" + nl)
			for i = 1 to nVars
				fwrite(outputfile, "M=M+1" + nl)
			end
			fwrite(outputfile, "A=M" + nl)
			for i = 1 to nVars
				fwrite(outputfile, "A=A-1" + nl)
				fwrite(outputfile, "M=0" + nl)
			end
		end

	func writeCall functionName, nVars //writes assembly for a call command
		fwrite(outputfile, "//call " + functionName + " " + nVars + nl)	
		fwrite(outputFile, "@" + currentFunc + "$ret." + returns + nl)
		fwrite(outputfile, "D=A" + nl)
		pushD()
		pushFromMemory("LCL")
		pushFromMemory("ARG")
		pushFromMemory("THIS")
		pushFromMemory("THAT")
		
		//update LCL and ARG:
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@LCL" + nl)
		fwrite(outputfile, "M=D" + nl)
		fwrite(outputfile, "@" + (5 + nVars) + nl)
		fwrite(outputfile, "D=D-A" + nl)
		fwrite(outputfile, "@ARG" + nl)
		fwrite(outputfile, "M=D" + nl)
	
		fwrite(outputfile, "@" + functionName + nl)
		fwrite(outputfile, "0;JMP" + nl)
		fwrite(outputfile, "(" + currentFunc + "$ret." + returns + ")" + nl)
		returns ++
		
	func writeReturn //writes assembly for a return command
		fwrite(outputfile, "//return" + nl)	
		//save LCL as temp
		fwrite(outputfile, "@LCL" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@R13" + nl)
		fwrite(outputfile, "M=D" + nl)
		//save ret as temp
		fwrite(outputfile, "@5" + nl)
		fwrite(outputfile, "A=D-A" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@R14" + nl)
		fwrite(outputfile, "M=D" + nl)
		//put return value in head of stack
		popToD() 
		fwrite(outputfile, "@ARG" + nl)
		fwrite(outputfile, "A=M" + nl)
		fwrite(outputfile, "M=D" + nl)
		//reset SP for caller
		fwrite(outputfile, "@ARG" + nl)
		fwrite(outputfile, "D=M+1" + nl)
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "M=D" + nl)
		//reset THAT for caller
		fwrite(outputfile, "@R13" + nl)
		fwrite(outputfile, "A=M-1" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@THAT" + nl)
		fwrite(outputfile, "M=D" + nl)
		//reset THIS for caller
		fwrite(outputfile, "@R13" + nl)
		fwrite(outputfile, "A=M-1" + nl)
		fwrite(outputfile, "A=A-1" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@THIS" + nl)
		fwrite(outputfile, "M=D" + nl)
		//reset ARG for caller
		fwrite(outputfile, "@R13" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@3" + nl)
		fwrite(outputfile, "A=D-A" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@ARG" + nl)
		fwrite(outputfile, "M=D" + nl)
		//reset LCL for caller
		fwrite(outputfile, "@R13" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@4" + nl)
		fwrite(outputfile, "A=D-A" + nl)
		fwrite(outputfile, "D=M" + nl)
		fwrite(outputfile, "@LCL" + nl)
		fwrite(outputfile, "M=D" + nl)
		//jump to ret
		fwrite(outputfile, "@R14" + nl)	
		fwrite(outputfile, "A=M" + nl)
		fwrite(outputfile, "0;JMP" +nl)		
	
	func close //closes the output file
		fclose(outputfile)

	private
	
	outputfile
	compares = 0
	returns = 0
	main_compares = 0
	main_returns = 0
	filename = ""
	currentFunc
	pathType		

	func popToD //pops the topmost stack element to D
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "AM=M-1" + nl)
		fwrite(outputfile, "D=M" + nl)
	
	func newFunc functionName //reset counters on function start
		currentFunc = functionName
		main_compares = compares
		main_returns = returns	
		compares = 0
		returns = 0

	func funcEnd //reset counters on function end
		currentFunc = filename
		compares = main_compares
		returns = main_returns
	
	func pushD //pushes D to the top of the stack
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "A=M" + nl)
		fwrite(outputfile, "M=D" + nl)
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "M=M+1" + nl)

	func pushFromMemory label //pushes from memory to stack
		fwrite(outputfile, "@" + label + nl)
		fwrite(outputfile, "D=M" + nl)
		pushD()

	func cmpOperation command
		fwrite(outputfile, "D=M-D" + nl)
		fwrite(outputfile, "@" + currentFunc + "$true." + compares + nl)
		fwrite(outputfile, "D;J" + upper(command) + nl)
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "A=M-1" + nl)
		fwrite(outputfile, "M=0" + nl)
		fwrite(outputfile, "@" + currentFunc + "$continue." + compares + nl)
		fwrite(outputfile, "0;JMP" + nl)
		fwrite(outputfile, "(" + currentFunc + "$true." + compares + ")" + nl)
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "A=M-1" + nl)
		fwrite(outputfile, "M=-1" + nl)
		fwrite(outputfile, "(" + currentFunc + "$continue." + compares + ")" + nl)

		compares++
		
