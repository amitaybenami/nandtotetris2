class CodeWriter
	
	func init filename //constuctor - opens the output file	for writing
		outputfile = fopen(filename, "w")

	func setFileName filename
		//inform the codeWriter about new file reading
		filename = left(filename,len(filename)-3)//without .vm extension

	func writeArithmetic command
	//writes assembly for given arithmetic command in output file
		fwrite(outputfile, "//" + command + nl)	
		fwrite(outputfile, "@SP" + nl)
		if command = "add" or command = "sub" or command = "eq" or command = "gt"
			or command = "lt" or command = "and" or command = "or"//two operands
			fwrite(outputfile, "AM=M-1" + nl)		
			fwrite(outputfile, "D=M" + nl)
			fwrite(outputfile, "A=A-1" + nl)
			if command = "add" fwrite(outputfile, "M=D+M" + nl)
			elseif command = "sub" fwrite(outputfile, "M=M-D" + nl)
			elseif command = "and" fwrite(outputfile, "M=D&M" + nl)
			elseif command = "or" fwrite(outputfile, "M=D|M" + nl)
			elseif command = "eq" or command = "gt" or command = "lt"
				jumpOperation(command)
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

	func close //closes the output file
		fclose(outputfile)

	private
	
	outputfile
	jumps = 0
	filename			

	func popToD
	fwrite(outputfile, "@SP" + nl)
	fwrite(outputfile, "AM=M-1" + nl)
	fwrite(outputfile, "D=M" + nl)

	func pushD
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "A=M" + nl)
		fwrite(outputfile, "M=D" + nl)
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "M=M+1" + nl)

	func jumpOperation command
		fwrite(outputfile, "D=M-D" + nl)
		fwrite(outputfile, "@TRUE" + jumps + nl)
		fwrite(outputfile, "D;J" + upper(command) + nl)
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "A=M-1" + nl)
		fwrite(outputfile, "M=0" + nl)
		fwrite(outputfile, "@CONTINUE" + jumps + nl)
		fwrite(outputfile, "0;JMP" + nl)
		fwrite(outputfile, "(TRUE" + jumps + ")" + nl)
		fwrite(outputfile, "@SP" + nl)
		fwrite(outputfile, "A=M-1" + nl)
		fwrite(outputfile, "M=-1" + nl)
		fwrite(outputfile, "(CONTINUE" + jumps + ")" + nl)

		jumps++
		
