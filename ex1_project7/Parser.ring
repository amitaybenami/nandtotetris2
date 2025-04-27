class Parser

	func init filename //constructor - open the file for reading
		file = fopen(filename,"r")
		if not file
			raise("ParsingError: can't open file")
		end
		isClosed = false	
		
	func hasMoreCommands //boolean function returns if there are more commands to read
		if isClosed
			return false	
		elseif not nextLine
			if not readNextLine()
				return false
			end
		end 
		return true
	
	func advance //reads the next command and make it the current command
		listedLine = [nextLine] //to pass by reference	
		command = getWord(listedLine)
		if command = "add" or command = "sub" or command = "neg" or command = "eq"
			or command = "gt" or command = "lt" or command = "and"
			 or command = "or" or command = "not" or command = "sub#1"
			arithmetic(command, listedLine)
		elseif command = "push" or command = "pop"
			pushPop(command, listedLine)
		else 
			raise("ParsingError: unrecognized command: " + command)
		end
		readNextLine()	

	func commandType //returns the current command's type
		return _commandType

	func arg1 //returns the first argument of the current command
		if _arg1
			return _arg1
		else 
			raise("ParsingError: current command doesn't have arguments")
		end

	func arg2 //returns the first argument of the current command
		if _arg2
			return _arg2
		else 
			raise("ParsingError: current command doesn't have second argument")
		end

	private

	file
	isClosed
	nextLine = ""
	_commandType
	_arg1
	_arg2

	func readNextLine 
	//reads the next not-comment line to nextLine	
	//returns true/false if there is such line
		
		if isClosed
			return false
		elseif feof(file)
			fclose(file)
			isClosed = true
			nextLine = null
			return false
		end	
		line = strip(fgets(file,200))
		line = left(line,len(line)-1)//delete \n from the line
		if not line or left(line,2) = "//"
			return readNextLine()
		else
			nextLine = line
			return true
		end
	
	func getWord(listedLine)
	//gets a line by reference and cuts a word from it and returns the word	
		line = listedLine[1]
		i = substr(line," ")
		if i = 0 //last word
			listedLine[1] = ""	
			return line
		end
		word = left(line,i-1)
		listedLine[1] = strip(substr(line,i+1))
		return word
	
	func strip(line)
		if not line	
			return null
		end
		for i = 1 to len(line)
			if line[i] != print2str("\n") and line[i] != print2str("\t") and line[i] != " "
				return substr(line,i)
			end
		end

	func arithmetic(command, listedLine) //handle arithmetic commands
		if listedLine[1] and left(getWord(listedLine),2) != "//"
			raise("ParsingError: arithmetic command shouldn't have arguments")
		else	_commandType = "C_ARITHMETIC"
			_arg1 = command
			_arg2 = null
		end
	
	func pushPop(command, listedLine) //handle push and pop commands	
		segment = getWord(listedLine)
		offset = getWord(listedLine)
		if not segment or left(segment,2) = "//" or not offset or left(offset,2) = "//"
			raise("ParsingError: push/pop commands should have 2 arguments")
		elseif listedLine[1] and left(getWord(listedLine),2) != "//"	
			raise("ParsingError: push/pop commands should have 2 arguments")
		else	_commandType = "C_" + upper(command)
			_arg1 = segment
			_arg2 = offset
		end
