Macro (GET_BOOST)
	Set (BOOST_ROOT $ENV{BOOST_ROOT} CACHE STRING "Boost Root")
	String (REPLACE "." "_" bver $ENV{BOOST_VERSION})
	String (REGEX MATCH "_0$" ends_with_zero ${bver})
	If (ends_with_zero)
		String (REGEX REPLACE "_0$" "" bver ${bver})
	EndIf (ends_with_zero)
	Set (boost_inc_dir ${BOOST_ROOT}/include/boost-${bver})
	If (EXISTS ${boost_inc_dir})
		Set (Boost_INCLUDE_DIR ${BOOST_ROOT}/include/boost-${bver})
	Else (EXISTS ${boost_inc_dir})
		Set (Boost_INCLUDE_DIR ${BOOST_ROOT}/include)
	EndIf (EXISTS ${boost_inc_dir})
	Message (${Boost_INCLUDE_DIR})
EndMacro (GET_BOOST)

Macro (ADD_BOOST_LIBRARIES)
	If (UNIX)
		PARSE_ARGUMENTS (
			LIB_BOOST
			"NAME;MODULES;TYPE" "" ${ARGN}
			)

		Set (TARGET ${LIB_BOOST_NAME})
		Set (LIBRARIES ${LIB_BOOST_MODULES})

		ForEach (LIB ${LIBRARIES})
			String (TOUPPER ${LIB} LIB)
			Target_Link_Libraries (
				${TARGET} 
				debug ${Boost_${LIB}_LIBRARY_DEBUG}
				optimized ${Boost_${LIB}_LIBRARY_RELEASE}
				)
		EndForeach (LIB)
	EndIf (UNIX)
EndMacro (ADD_BOOST_LIBRARIES)
