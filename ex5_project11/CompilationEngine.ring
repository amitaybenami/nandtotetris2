load "SymbolTable.ring"
load "VMWriter.ring"

class CompilationEngine

	func init inputfilePath, outputfilePath
		vmWriter = new VMWriter(outputfilePath)
		inputfile = fopen(inputfilePath, "r")	
		if fread(inputfile, 9) != "<tokens>" + nl
			"CompilationError: wrong template file"
		end

	func compileClass
		eat("keyword", "class")
		symbolTable = new SymbolTable()
		className = eat("identifier", -1)	
		eat("symbol", "{")
		while checkClassVarDec()
			compileClassVarDec()
		end
		while not check("symbol", "}") 
			compileSubroutineDec()
		end
		eat("symbol", "}")
		fclose(inputfile)
		vmWriter.close()
		
		
	func compileClassVarDec
		kind = eat("keyword", -1)
		if check("keyword", -1)
			varType = eat("keyword", -1)
		else varType = eat("identifier", -1)
		end
		name = eat("identifier", -1)
		symbolTable.define(name, varType, kind)		
		while check("symbol", ",")
			eat("symbol", ",")
			name = eat("identifier", -1)
			symbolTable.define(name, varType, kind)		
		end
		eat("symbol", ";")

	func compileSubroutineDec
		symbolTable.startSubroutine()
		labels = 0
		subroutineType = eat("keyword", -1)
		if check("keyword", -1)
			returnType = eat("keyword", -1)	
		else returnType = eat("identifier", -1)
		end
		subroutineName = eat("identifier", -1)
		
		eat("symbol", "(")
		compileParameterList()
		eat("symbol", ")")
		compileSubroutineBody()

	func compileParameterList
		if not check("symbol", ")")
			if check("keyword", -1)
				varType = eat("keyword", -1)	
			else varType = eat("identifier", -1)
			end
			name = eat("identifier", -1)
			symbolTable.define(name, varType, "argument")
			while check("symbol", ",")
				eat("symbol", ",")
				if check("keyword", -1)
					varType = eat("keyword", -1)	
				else varType = eat("identifier", -1)
				end
				name = eat("identifier", -1)
				symbolTable.define(name, varType, "argument")
			end
		end			

	func compileSubroutineBody
		eat("symbol", "{")
		while check("keyword", "var")
			compileVarDec()
		end
		nLocals = symbolTable.varCount("var")
		vmWriter.writeFunction(className + "." + subroutineName, nLocals) 
		if subroutineType = "method"
			symbolTable.define("this", className, "argument")
			vmWriter.writePush("argument", 0)
			vmWriter.writePop("pointer", 0)
		elseif subroutineType = "constructor"
			vmWriter.writePush("constant", symbolTable.varCount("field"))
			vmWriter.writeCall("Memory.alloc", 1)
			vmWriter.writePop("pointer", 0)
		end
		compileStatements()
		eat("symbol", "}")

	func compileVarDec 
		eat("keyword", "var")
		if check("keyword", -1)
			varType = eat("keyword", -1)	
		else varType = eat("identifier", -1)
		end
		name = eat("identifier", -1)
		symbolTable.define(name, varType, "var")
		while check("symbol", ",")
			eat("symbol", ",")
			name = eat("identifier", -1)
			symbolTable.define(name, varType, "var")
		end
		eat("symbol", ";")
	
	func compileStatements
		while checkStatement()
			if token = "let"
				compileLetStatement()
			elseif token = "if"
				compileIfStatement()
			elseif token = "while"
				compileWhileStatement()
			elseif token = "do"
				compileDoStatement()
			else
				compileReturnStatement()
			end
		end

	func compileLetStatement
		arr = false
		eat("keyword", "let")
		name = eat("identifier", -1)
		if check("symbol", "[")
			arr = true
			vmWriter.writePush(kindOf(name), symbolTable.indexOf(name))

			eat("symbol", "[")
			compileExpression()
			eat("symbol","]")
			vmWriter.writeArithmetic("add")
		end

		eat("symbol", "=")
		compileExpression()
		if arr
			vmWriter.writePop("temp", 1)
			vmWriter.writePop("pointer", 1)
			vmWriter.writePush("temp", 1)
			vmWriter.writePop("that", 0)
		else  	
			vmWriter.writePop(kindOf(name), symbolTable.indexOf(name))
		end
		eat("symbol", ";")

	func compileIfStatement
		eat("keyword", "if")
		eat("symbol", "(")
		compileExpression()
		eat("symbol",")")
		vmWriter.writeArithmetic("not")
		firstL = labels
		labels += 1
		vmWriter.writeIf(className + "." + subroutineName + "$L" + firstL)
		eat("symbol", "{")
		compileStatements()
		eat("symbol","}")
		if check("keyword", "else")
			eat("keyword", "else")
			secondL = labels
			labels += 1
			vmWriter.writeGoto(className + "." + subroutineName + "$L" + secondL)
			vmWriter.writeLabel(className + "." + subroutineName + "$L" + firstL)
			labels += 1
			eat("symbol", "{")
			compileStatements()
			eat("symbol","}")
			vmWriter.writeLabel(className + "." + subroutineName + "$L" + secondL)
		else 
			vmWriter.writeLabel(className + "." + subroutineName + "$L" + firstL)
		end
			
	func compileWhileStatement
		firstL = labels
		vmWriter.writeLabel(className + "." + subroutineName + "$L" + firstL)
		secondL = labels +1
		labels += 2
		eat("keyword", "while")
		eat("symbol", "(")
		compileExpression()
		vmWriter.writeArithmetic("not")
		vmWriter.writeIf(className + "." + subroutineName + "$L" + secondL)
		eat("symbol",")")
		eat("symbol", "{")
		compileStatements()
		eat("symbol","}")
		vmWriter.writeGoto(className + "." + subroutineName + "$L" + firstL)
		vmWriter.writeLabel(className + "." + subroutineName + "$L" + secondL)

	func compileDoStatement
		eat("keyword", "do")
		var = eat("identifier", -1)
		compileSubroutineCall(var)
		eat("symbol", ";")
		vmWriter.writePop("temp", 0) //ignore the result	

	func compileReturnStatement
		eat("keyword", "return")
		if check("symbol", ";")
			vmWriter.writePush("constant", 0)
		else
			compileExpression()
		end
		vmWriter.writeReturn()
		eat("symbol", ";")

	func compileExpression
		compileTerm()
		while checkOp()
			op = eat("symbol", -1)
			compileTerm()
			if op = "+"
				vmWriter.writeArithmetic("add")
			elseif op = "-"
				vmWriter.writeArithmetic("sub")	
			elseif op = "*"
				vmWriter.writeCall("Math.multiply", 2)
			elseif op = "/"
				vmWriter.writeCall("Math.divide", 2)
			elseif op = "&amp;"
				vmWriter.writeArithmetic("and")
			elseif op = "|"
				vmWriter.writeArithmetic("or")
			elseif op = "&lt;"
				vmWriter.writeArithmetic("lt")
			elseif op = "&gt;"
				vmWriter.writeArithmetic("gt")
			elseif op = "="
				vmWriter.writeArithmetic("eq")
			end			
		end

	func compileTerm
		if check("integerConstant", -1)
			term = eat("integerConstant", -1)
			vmWriter.writePush("constant", term)
		elseif check("stringConstant", -1)
			term = eat("stringConstant", -1)
			vmWriter.writePush("constant", len(term))
			vmWriter.writeCall("String.new", 1)
			for c in term
				vmWriter.writePush("constant", ascii(c))
				vmWriter.writeCall("String.appendChar", 2)
			end
		elseif check("keyword", -1)
			term = eat("keyword", -1)
			if term = "true"
				vmWriter.writePush("constant", 1)
				vmWriter.writeArithmetic("neg")
			elseif term = "false" or term = "null"
				vmWriter.writePush("constant", 0)
			elseif term = "this"
				vmWriter.writePush("pointer", 0)
			end
		elseif check("identifier", -1)
			var = eat("identifier", -1)
			if check("symbol", "[")
				eat("symbol", "[")
				vmWriter.writePush(kindOf(var), symbolTable.indexOf(var))
				compileExpression()
				vmWriter.writeArithmetic("add")
				vmWriter.writePop("pointer", 1)
				vmWriter.writePush("that", 0)
				eat("symbol", "]")
			elseif check("symbol", "(") or check("symbol", ".")
				compileSubroutineCall(var)
			else
				vmWriter.writePush(kindOf(var), symbolTable.indexOf(var))			
			end
		elseif check("symbol", "(")
				eat("symbol", "(")
				compileExpression()
				eat("symbol", ")")
		else
			op = eat("symbol", -1)
			compileTerm()
			if op = "-"
				vmWriter.writeArithmetic("neg")
			elseif op = "~"
				vmWriter.writeArithmetic("not")
			end
		end
	func compileSubroutineCall var
		nArgs = 0
		if check("symbol", ".")
			eat("symbol", ".")
			method = eat("identifier", -1)
			kind = kindOf(var)
			if kind = "none"
				method = var + "." + method
			else
				vmWriter.writePush(kind, symbolTable.indexOf(var))
				nArgs += 1
				method = symbolTable.typeOf(var) + "." + method
			end
		else 	
			method = className + "." + var
			vmWriter.writePush("pointer", 0)
			nArgs += 1
		end
		eat("symbol", "(")
		nArgs += compileExpressionList()
		vMwriter.writeCall(method, nArgs)
		eat("symbol",")")

	func compileExpressionList
		nArgs = 0
		if not check("symbol", ")")
			nArgs += 1
			compileExpression()
			while check("symbol", ",")
				nArgs += 1
				eat("symbol", ",")
				compileExpression()
			end
		end
		return nArgs

	private 

	vmWriter
	inputfile
	symbolTable
	className
	subroutineName
	subroutineType
	labels
	returnType
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
		prevToken = token
		token = ""
		type = ""
		return prevToken
		
				
	func check _type, _token
		read()		
		return _type = type and (_token = token or _token = -1) 
	
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
		fgetc(inputfile)
		while c != "<"
			c = fgetc(inputfile)
			token += c
		end
		token = left(token, len(token) - 2)
		fread(inputfile,len(type) + 3)	
	
	func start funcName
		fwrite(outputfile, indent + "<" + funcName+ ">" + nl)
		indent += "  "

	func ends funcName
		indent = left(indent,len(indent) - 2)
		fwrite(outputfile, indent + "</" + funcName+ ">" + nl)

	func checkClassVarDec
		read()
		if token = "static" or token = "field"
			return true
		end
		return false

	func checkStatement
		read()
		if token = "let" or token = "do" or token = "if" or
		token = "while" or token = "return"
			return true
		end
		return false
	
	func checkOp
		read()
		if type = "symbol" and (token = "+" or token = "-" or
		token = "*" or token = "/" or token = "&amp;" or token = "|" or
		token = "&lt;" or token = "&gt;" or token = "=")
			return true
		end
		return false

	func kindOf name
		kind = symbolTable.kindOf(name)
		if kind = "var"
			return "local"
		elseif kind = "field"
 			return "this"
		else return kind
		end
