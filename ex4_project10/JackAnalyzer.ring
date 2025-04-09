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
	










func fileName(fullPath)
	y = reverse(fullPath)
	return reverse(left(y,substr(y,'\') - 1))
