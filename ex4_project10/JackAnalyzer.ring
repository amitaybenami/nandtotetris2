load "Tokenizer.ring"
load "CompilationEngine.ring"

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
			tokenFile = dirPath + "Token" + left(file[1],len(file[1]) - 4) + "xml"
			tokenizer = new Tokenizer(curPath, tokenFile)
			tokenizer.tokenize()
			
			?"start compiling " + file[1]
			compilationEngine = new CompilationEngine(tokenFile, 
			dirPath + "Compile" + left(file[1],len(file[1]) - 4) + "xml")
			compilationEngine.compileClass()
			remove(tokenFile)
		end
	end
	?"succuessfully compiled!"
	

func fileName(fullPath)
	y = reverse(fullPath)
	return reverse(left(y,substr(y,'\') - 1))
