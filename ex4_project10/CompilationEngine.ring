class CompilationEngine

	func init inputfilePath, outputfilePath
		outputfile = fopen(outputfilePath, "w")
		inputfile = fopen(inputfilePath, "r")	
		if fread(inputfile, 9) != "<tokens>" + nl
			"CompilationError: wrong template file"
		end

	func compileClass
		start("class")
		eat("keyword", "class")
		eat("identifier", -1)
		eat("symbol", "{")
		while checkClassVarDec()
			compileClassVarDec()
		end
		while not check("symbol", "}") 
			compileSubroutineDec()
		end
		eat("symbol", "}")
		ends("class")
		fclose(inputfile)
		fclose(outputfile)
		
		
	func compileClassVarDec
		start("classVarDec")
		eat("keyword", -1)
		if check("keyword", -1)
			eat("keyword", -1)
		else eat("identifier", -1)
		end
		eat("identifier", -1)
		while check("symbol", ",")
			eat("symbol", ",")
			eat("identifier", -1)
		end
		eat("symbol", ";")
		ends("classVarDec")


	func compileSubroutineDec
		start("subroutineDec")
		eat("keyword", -1)
		if check("keyword", -1)
			eat("keyword", -1)	
		else eat("identifier", -1)
		end
		eat("identifier", -1)
		eat("symbol", "(")
		compileParameterList()
		eat("symbol", ")")
		compileSubroutineBody()
		ends("subroutineDec")

	func compileParameterList
		start("parameterList")
		if not check("symbol", ")")
			if check("keyword", -1)
				eat("keyword", -1)	
			else eat("identifier", -1)
			end
			eat("identifier", -1)
			while check("symbol", ",")
				eat("symbol", ",")
				if check("keyword", -1)
					eat("keyword", -1)	
				else eat("identifier", -1)
				end
				eat("identifier", -1)
			end
		end			
		ends("parameterList")

	func compileSubroutineBody
		start("subroutineBody")
		eat("symbol", "{")
		while check("keyword", "var")
			compileVarDec()
		end
		compileStatements()
		eat("symbol", "}")
		ends("subroutineBody")

	func compileVarDec 
		start("varDec")
		eat("keyword", "var")
		if check("keyword", -1)
			eat("keyword", -1)	
		else eat("identifier", -1)
		end
		eat("identifier", -1)
		while check("symbol", ",")
			eat("symbol", ",")
			eat("identifier", -1)
		end
		eat("symbol", ";")
		ends("varDec")
	
	func compileStatements
		start("statements")
		while checkStatement()
			if token = " let "
				compileLetStatement()
			elseif token = " if "
				compileIfStatement()
			elseif token = " while "
				compileWhileStatement()
			elseif token = " do "
				compileDoStatement()
			else
				compileReturnStatement()
			end
		end
		ends("statements")

	func compileLetStatement
		start("letStatement")
		eat("keyword", "let")
		eat("identifier", -1)
		if check("symbol", "[")
			eat("symbol", "[")
			compileExpression()
			eat("symbol","]")
		end
		eat("symbol", "=")
		compileExpression()
		eat("symbol", ";")
		ends("letStatement")

	func compileIfStatement
		start("ifStatement")
		eat("keyword", "if")
		eat("symbol", "(")
		compileExpression()
		eat("symbol",")")
		eat("symbol", "{")
		compileStatements()
		eat("symbol","}")
		if check("keyword", "else")
			eat("keyword", "else")
			eat("symbol", "{")
			compileStatements()
			eat("symbol","}")
		end
		ends("ifStatement")	
			
	func compileWhileStatement
		start("whileStatement")
		eat("keyword", "while")
		eat("symbol", "(")
		compileExpression()
		eat("symbol",")")
		eat("symbol", "{")
		compileStatements()
		eat("symbol","}")
		ends("whileStatement")		

	func compileDoStatement
		start("doStatement")
		eat("keyword", "do")
		eat("identifier", -1)
		if check("symbol", ".")
			eat("symbol", ".")
			eat("identifier", -1)
		end
		eat("symbol", "(")
		compileExpressionList()
		eat("symbol",")")
		eat("symbol", ";")
		ends("doStatement")	


	func compileReturnStatement
		start("returnStatement")
		eat("keyword", "return")
		if not check("symbol", ";")
			compileExpression()
		end
		eat("symbol", ";")
		ends("returnStatement")	

	func compileExpression
		start("expression")
		compileTerm()
		read()
		while checkOp()
			eat("symbol", -1)
			compileTerm()
		end
		ends("expression")

	func compileTerm
		start("term")
		if check("integerConstant", -1)
			eat("integerConstant", -1)
		elseif check("stringConstant", -1)
			eat("stringConstant", -1)
		elseif check("keyword", -1)
			eat("keyword", -1)
		elseif check("identifier", -1)
			eat("identifier", -1)
			if check("symbol", "[")
				eat("symbol", "[")
				compileExpression()
				eat("symbol", "]")
			elseif check("symbol", "(")
				eat("symbol", "(")
				compileExpressionList()
				eat("symbol", ")")
			elseif check("symbol", ".")
				eat("symbol", ".")
				eat("identifier", -1)
				eat("symbol", "(")
				compileExpressionList()
				eat("symbol", ")")				
			end
		elseif check("symbol", "(")
				eat("symbol", "(")
				compileExpression()
				eat("symbol", ")")
		else
			eat("symbol", -1)
			compileTerm()
		end
		ends("term")

	func compileExpressionList
		start("expressionList")
		if not check("symbol", ")")
			compileExpression()
			while check("symbol", ",")
				eat("symbol", ",")
				compileExpression()
			end
		end
		ends("expressionList")	

	private 

	outputfile
	inputfile
	indent = ""
	type = ""
	token = ""

	func eat _type, _token
		if not check(_type, _token)
			if _token = -1
				raise("CompilationError: Excepted " + _type)
			else raise("CompilationError: Excepted " + _type + " " + _token)
			end
		end

		fwrite(outputfile,indent + "<" + type + ">" + token + "</" + type + ">" + nl)
		token = ""
		type = ""
		
				
	func check _type, _token
		read()		
		return _type = type and (" " + _token + " " = token or _token = -1) 
	
	func read
		if type
			return
		end
		fgetc(inputfile)
		c = fgetc(inputfile)
		while c != ">"
			type += c
			c = fgetc(inputfile)
		end
		c = fgetc(inputfile)
		while c != "<"
			token += c
			c = fgetc(inputfile)
		end		
		fread(inputfile,len(type) + 3)	
	
	func start funcName
		fwrite(outputfile, indent + "<" + funcName+ ">" + nl)
		indent += "  "

	func ends funcName
		indent = left(indent,len(indent) - 2)
		fwrite(outputfile, indent + "</" + funcName+ ">" + nl)

	func checkClassVarDec
		read()
		if token = " static " or token = " field "
			return true
		end
		return false

	func checkStatement
		read()
		if token = " let " or token = " do " or token = " if " or
		token = " while " or token = " return "
			return true
		end
		return false
	
	func checkOp
		read()
		if type = "symbol" and (token = " + " or token = " - " or
		token = " * " or token = " / " or token = " &amp; " or token = " | " or
		token = " &lt; " or token = " &gt; " or token = " = ")
			return true
		end
		return false
