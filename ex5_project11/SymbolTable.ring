class SymbolTable
	
	func init 

	func startSubroutine
		subroutineTable = []
		varAmount = 0
		argAmount = 0

	func define name, type, kind		
		if kind = "static" 
			classTable + [name, type, kind, staticAmount]
			staticAmount += 1
		elseif kind = "field" 
			classTable + [name, type, kind, fieldAmount]
			fieldAmount += 1	
		elseif kind = "var" 
			subroutineTable + [name, type, kind, varAmount]
			varAmount += 1
		elseif kind = "argument"
			subroutineTable + [name, type, kind, argAmount]
			argAmount += 1
		end

	func varCount kind
		if kind = "static" 
			return staticAmount
		elseif kind = "field" 
			return fieldAmount	
		elseif kind = "var" 
			return varAmount
		elseif kind = "argument"
			return argAmount
		end

	func kindOf name
		var = search(name)
		if var
			return var[3]
		else return "none"
		end

	func typeOf name 		
		var = search(name)
		if var
			return var[2]
		else return "none"
		end

	func indexOf name 		
		var = search(name)
		if var
			return var[4]
		else return "none"
		end

	private 
	
	classTable = []
	subroutineTable = []
	staticAmount = 0
	fieldAmount = 0
	varAmount = 0
	argAmount = 0

	func search name
		i = find(subroutineTable,name,1)
		if i return subroutineTable[i]
		end

		i = find(classTable, name, 1)
		if i return classTable[i]
		end

		return null
