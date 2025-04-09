class CompilationEngine

	func init outputfilePath
		outputfile = fopen(outputfilePath, "w")
		inputfile = fopen(inputfileParh, "r")	
		if fread(inputfile, 9) != "<tokens>" + nl
			"CompilationError: wrong template file"
		end

	func compileClass
		start("class")
		eat("keyword", "class")
		eat("identifier", -1)
		eat("symbol", "{")
		while check("keyword", "static") or check("keyword", "field")
			compileClassVarDec()
		end
		while not check("symbol", "}") 
			compileSubroutineDec()
		end
		eat("symbol", "}")
		ends("class")
		
		
	func compileClassVarDec
		start("classVarDec")
		if check("keyword", "field")
			eat("keyword", "field")
		else eat("keyword", "static")
		end
		if check("keyword", "int")
			eat("keyword", "int")
		elseif check("keyword", "char")
			eat("keyword", "char")
		elseif check("keyword", "boolean")
			eat("keyword", "boolean")
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
		if check("keyword", "constructor")
			eat("keyword", "constructor")
		elseif check("keyword", "method")
			eat("keyword", "method")
		else eat("keyword", "function")
		end
		if check("keyword", "void")
			eat("keyword", "void")	
		elseif check("keyword", "int")
			eat("keyword", "int")
		elseif check("keyword", "char")
			eat("keyword", "char")
		elseif check("keyword", "boolean")
			eat("keyword", "boolean")
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
			compileType()
			eat("identifier", -1)
			while check("symbol", ",")
				eat("symbol", ",")
				if check("keyword", "int")
					eat("keyword", "int")
				elseif check("keyword", "char")
					eat("keyword", "char")
				elseif check("keyword", "boolean")
					eat("keyword", "boolean")
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
			compileStatements()
			eat("symbol", "}")
		end
		ends("subroutineBody")
	
	func compileStatements
		start("statements")
		while check("keyword", "let") or check("keyword", "if") or 
		check("keyword", "while") or check("keyword", "do") or check("keyword", "return")
			if token = "let"
				compileLetSatement()
			elseif token = "if"
				compileIfSatement()
			elseif token = "while"
				compileWhileSatement()
			elseif token = "do"
				compileDoSatement()
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
		return _type = type and (_token = token or token = -1) 
	
	func read
		if type
			return
		end
		fgetc(inputfile)
		c = fgtc(inputfile)
		while c != ">"
			type += c
			c = fgtc(inputfile)
		end
		c = fgtc(inputfile)
		while c != "<"
			token += c
			c = fgtc(inputfile)
		end		
		fread(inputfile,len(type) + 3)	
	
	func start funcName
		fwrite(outputfile, "<" + funcName+ ">" + nl)
		indent += "  "

	func ends funcName
		indent = left(indent,len(indent) - 2)
		fwrite(outputfile, indent + "</" + funcName+ ">" + nl)
