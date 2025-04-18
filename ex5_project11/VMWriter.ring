class VMWriter

	func init filename
		outputfile = fopen(filename, "w")
	
	func writePush segment, index
		fwrite(outputfile, "push " + segment + " " + index + nl)
		
	func writePop segment, index
		fwrite(outputfile, "pop " + segment + " " + index + nl)

	func writeArithmetic command
		fwrite(outputfile, command + nl)

	func writeLabel label
		fwrite(outputfile, "label " + label + nl)

	func writeGoto label
		fwrite(outputfile, "goto " + label + nl)	
		
	func writeIf label
		fwrite(outputfile, "if-goto " + label + nl)

	func writecall name, nArgs
		fwrite(outputfile, "call " + name + " " + nArgs + nl)
	
	func writeFunction name, nLocals
		fwrite(outputfile, "function " + name + " " + nLocals + nl)

	func writeReturn 
		fwrite(outputfile, "return" + nl)

	func close
		fclose(outputfile)

	private
	outputfile
