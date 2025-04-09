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
	outputfile = fopen(left(filename,len(filename) - 4) + "xml", "w")

	tokenizer = new Tokenizer(filePath)
	fwrite(outputfile, "<tokens>" + nl)

	while tokenizer.hasMoreTokens()
		tokenizer.advance()
		type = tokenizer.type()
		token = tokenizer.token()
		fwrite(outputfile, "<" + type + ">" + token)
		fwrite(outputfile, "</" + type + ">" + nl)
	end





	fwrite(outputfile, "</tokens>" + nl)
	fclose(outputfile)


func fileName(fullPath)
	y = reverse(fullPath)
	return reverse(left(y,substr(y,'\') - 1))
