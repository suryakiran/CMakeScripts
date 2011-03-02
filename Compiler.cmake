MACRO (ADD_CONFIG_FLAGS)
	Parse_Arguments (
		ConfigFlags
		"CONFIGURATION;DEFINES" ""
		${ARGN}
		)
	
	ForEach (Conf ${ConfigFlags_CONFIGURATION})
		String (TOUPPER ${Conf} Conf) 
		Set (COMPILER_FLAG CMAKE_CXX_FLAGS_${Conf})		
		ForEach (Def ${ConfigFlags_DEFINES})
			If (WIN32)
				Set (${COMPILER_FLAG} "${${COMPILER_FLAG}} /D ${Def}")
			Else (WIN32)
				Set (${COMPILER_FLAG} "${${COMPILER_FLAG}} -D${Def}")
			EndIf (WIN32)
		EndForEach (Def)
	EndForEach (Conf)

ENDMACRO (ADD_CONFIG_FLAGS)
