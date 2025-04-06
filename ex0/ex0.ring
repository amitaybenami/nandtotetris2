? "Enter directory path:" give dirPath

outputfile = fopen(DirName(dirPath) + ".asm","w")

dirList = dir(dirPath)

totalBuy = 0
totalCell = 0

for obj in dirList
	if not obj[2] and right(obj[1],3) = ".vm" //its a file with .vm extension 
		fwrite(outputfile,left(obj[1],len(obj[1]) - 3)+nl) //print file name
		lines = str2list(read(dirPath + "/" + obj[1]))
		for line in lines
			listed = [line] //used to call by reference
			command = GetWord(listed)
			if command = "buy"
				HandleBuy(GetWord(listed),GetWord(listed),GetWord(listed))
			elseif command = "cell"
				HandleCell(GetWord(listed),GetWord(listed),GetWord(listed))
			end
		end
	end		
end

fwrite(outputfile, print2str("TOTAL BUY: #{totalBuy}\n"))	
fwrite(outputfile, print2str("TOTAL CELL: #{totalCell}"))	
fclose(outputfile)

func DirName(dirPath)
	y = reverse(dirPath)
	return reverse(left(y,substr(y,'\') - 1))

func GetWord(listedLine)
	line = listedLine[1]
	i = substr(line," ")
	if i = 0 //last word
		listedLine = [""]
		return line
	end
	word = left(line,i-1)
	listedLine[1] = substr(line,i+1)
	return word

func HandleBuy(ProductName, Amount, Price)
	fwrite(outputFile, print2str("### BUY #{ProductName} ###\n"))
	totalPrice = number(Amount) * number(Price)
	totalBuy += totalPrice
	fwrite(outputFile,"" + totalPrice + nl)

func HandleCell(ProductName, Amount, Price)
	fwrite(outputFile, print2str("$$$ CELL #{ProductName} $$$\n"))
	totalPrice = number(Amount) * number(Price)
	totalCell += totalPrice
	fwrite(outputFile, "" + totalPrice + nl)
