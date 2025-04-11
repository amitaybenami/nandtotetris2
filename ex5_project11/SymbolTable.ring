class SymbolTable
	
	func init 

	func startSubroutine
		subroutineTable = []
		varAmount = 0
		argAmount = 0

	func define name, type, kind		
		if kind = "static" 
			classTable[name] = [type, kind, staticAmount]	
			staticAmount += 1
		elseif kind = "field" 
			classTable[name] = [type, kind, fieldAmount]	
			fieldAmount += 1	
		elseif kind = "var" 
			classTable[name] = [type, kind, varAmount]	
			varAmount += 1
		else
			classTable[name] = [type, kind, argAmount]	
			argAmount += 1
		end

	func varCount kind
		if kind = "static" 
			return staticAmount
		elseif kind = "field" 
			return fieldAmount	
		elseif kind = "var" 
			return varAmount
		else
			return kindAmount
		end

	func kindOf name
		if subroutineTable[name]
			return subroutineTable[name][2]
		elseif classTable[name]
			return classTable[name][2]
		else return "none"
		end

	func typeOf name 		
		if subroutineTable[name]
			return subroutineTable[name][1]
		elseif classTable[name]
			return classTable[name][1]
		else return "none"
		end

	func indexOf name 		
		if subroutineTable[name]
			return subroutineTable[name][3]
		elseif classTable[name]
			return classTable[name][3]
		else return "none"
		end


	private 
	
	table = []
	subroutineTable = []
	staticAmount = 0
	fieldAmount = 0
	varAmount = 0
	argAmount = 0
