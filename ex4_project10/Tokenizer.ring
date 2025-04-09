class Tokenizer
	
	func init filename //constructor - open the file for reading
		file = fopen(filename,"r")
		if not file
			raise("TokenizingError: can't open file")
		end
		isClosed = false

	//boolean function returns if there are more tokens to read
	//cleans the spaces and comments
	func hasMoreTokens 
		if isClosed
			return false	
		end

		while true
			readChar()
			if current = -1
				fclose(file)
				isClosed = true
				return false
			elseif current = "/"
				nxt = fgetc(file)
				if nxt = "/"
					oneLineComment()
				elseif nxt = "*"
					multipleLinesComment()
				else
					fseek(file, -1, 1)
					return true
				end
			elseif current != " " and current != print2str("\t") and
			 current != print2str("\n")
				return true
			end
			
		end 

	//gets next token to current
	//ASSUMES that hasMoreTokens was called first to clean spaces and comments
	func advance
		if not current
			raise("TokenizingError: hasMoreTokens() must be called before advance()")
		end
		a = ascii(current)
		if (a < 123 and a > 96) or (a < 91 and a > 64) or a = 95
			word = current
			current = fgetc(file)
			a = ascii(current)
			while (a < 123 and a > 96) or (a < 91 and a > 64) or
			 a = 95 or (a < 58 and a > 47)
				word += current
				current = fgetc(file)
				a = ascii(current)
			end

			token = word
			if word = "class" or word = "constructor" or word = "function" or 
			word = "method" or word = "field" or word = "static" or 
			word = "var" or word = "int" or word = "char" or word = "boolean" or 
			word = "void" or word = "true" or word = "false" or word = "null" or 
			word = "this" or word = "let" or word = "do" or word = "if" or 
			word = "else" or word = "while" or word = "return"
				type = "keyword"
			else		
				type = "identifier"
			end

		elseif current = "{" or current = "}" or current = "[" or current = "]" or 
		current = "(" or current = ")" or current = "." or current = "," or 
		current = ";" or current = "+" or current = "-" or current = "*" or 
		current = "/" or current = "&" or current = "|" or current = "<" or 
		current = ">" or current = "=" or current = "~"
			token = current
			type = "symbol"

		elseif a < 58 and a > 47
			word = current
			current = fgetc(file)
			a = ascii(current)
			while a < 58 and a > 47
				word += current
				current = fgetc(file)
				a = ascii(current)
			end
			token = word
			type = "integerConstant"
		
		elseif current = '"'
			word = ""
			current = fgetc(file)
			a = ascii(current)
			while current != '"'
				if current = print2str("\n") or current = -1
					raise("TokenizingError: unclosed string constant: " + word)
				end
				word += current
				current = fgetc(file)
				a = ascii(current)
			end
			token = word
			type = "stringConstant"
		else
			raise("TokenizingError: unrecognized token")
		end
		
		if type = "keyword" or type = "identifier" or type = "integerConstant"
			saveChar()
		end
		current = ""
	
	func tokenType
		return type

	func token
		return token


	private

	file
	isClosed
	current = ""
	type = ""
	token = ""
	nxtCurrent = ""

	func saveChar
		nxtCurrent = current
		current = ""

	func readChar 
		if nxtCurrent
			current = nxtCurrent
			nxtCurrent = ""
		else current = fgetc(file)
		end
	
	func oneLineComment
		while true	
			current = fgetc(file)
			if current = -1
				saveChar()
				return
			elseif current = print2str("\n")
				return 
			end
		end
	
	func multipleLinesComment
		while true
			readChar()
			if current = -1
				raise("TokenizingError: unclosed comment")
			elseif current = "*"
				nxt = fgetc(file)
				if nxt = "/"
					return
				else 
					current = nxt
					saveChar()
				end
			end
		end

