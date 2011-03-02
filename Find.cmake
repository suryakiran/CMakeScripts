Include (${CMAKE_ROOT}/Modules/CheckIncludeFileCXX.cmake)

Macro (FIND_CXX_HEADER header)
	String (TOUPPER ${header} header_u)
	Check_Include_File_Cxx (${header} HAVE_${header_u})
	If (NOT HAVE_${header_u})
		Check_Include_File_Cxx(${header}.h HAVE_${header_u}_H)
	EndIf ()
EndMacro(FIND_CXX_HEADER)

Macro (FIND_BOOL var)
	Message (STATUS "Checking for bool")
	Try_Compile (
		${var}
		${CMAKE_CURRENT_BINARY_DIR}/CMakeTmp/Bool ${CMAKE_MODULES_DIR}/src/TestBool.cxx
		OUTPUT_VARIABLE OUTPUT
		)
	If (${var})
		Set (${var} 1 CACHE INTERNAL "Support for C++ type bool")
		Message (STATUS "Checking for bool -- found")
	Else ()
		Set (${var} 0 CACHE INTERNAL "Support for C++ type bool")
		Message (STATUS "Checking for bool -- not found")
	EndIf()
EndMacro (FIND_BOOL)
