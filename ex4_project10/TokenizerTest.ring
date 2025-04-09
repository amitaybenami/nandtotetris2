load "Tokenizer.ring"

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
		dirList = [[filename, 0]]
		dirPath = left(filePath,len(filePath) - len(filename))
	else 	dirList = dir(filePath)
		dirPath = filePath + "\"
	end
	for file in dirList
		if not file[2] and right(file[1],5) = ".jack" //its a file with .jack extension
			if pathType = 2
				curPath = filePath + "\" + file[1]
			else curPath = filePath
			end
			?"start tokenizing " + file[1]
			outputfile = fopen(dirPath + "Token" + left(file[1],len(file[1]) - 4) + "xml", "w")
	
			tokenizer = new Tokenizer(curPath)
			fwrite(outputfile, "<tokens>" + nl)
		
			while tokenizer.hasMoreTokens()
				tokenizer.advance()
				type = tokenizer.tokenType()
				token = tokenizer.token()
				if type = "symbol"
					if token = "<"
						token = "&lt;"
					elseif token = ">"
						token = "&gt;"
					elseif token = "&"
						token = "&amp;"
					end
				end
				fwrite(outputfile, "<" + type + "> " + token)
				fwrite(outputfile, " </" + type + ">" + nl)
			end
			fwrite(outputfile, "</tokens>" + nl)
			fclose(outputfile)
		end
	end
	?"succuessfully tokenized!"
	

func fileName(fullPath)
	y = reverse(fullPath)
	return reverse(left(y,substr(y,'\') - 1))
