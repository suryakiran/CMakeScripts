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

If (CMAKE_COMPILER_IS_GNUCXX)
  Include (CheckCXXCompilerFlag)
  Check_Cxx_Compiler_Flag ("-std=gnu++0x" CXX11_SUPPORT_FLAG)

  If (NOT CXX11_SUPPORT_FLAG)
    Message (FATAL_ERROR "C++ Compiler unable to support C++11 features")
  Else (NOT CXX11_SUPPORT_FLAG)
    Set (COMPILER_FLAG_CXX11 "-std=gnu++0x" CACHE STRING "Compiler flag for C++-11 Support")
    Set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMPILER_FLAG_CXX11}")
  EndIf (NOT CXX11_SUPPORT_FLAG)
EndIf (CMAKE_COMPILER_IS_GNUCXX)
