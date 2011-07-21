INCLUDE (${CMAKE_MODULE_PATH}/Module.cmake)

MACRO (ADD_RELWITHDEBINFO_CONFIGURATION CONF)
	List (FIND ${CONF} "Release" ridx)
	List (FIND ${CONF} "Debug" didx)

	If (ridx GREATER -1 AND didx GREATER -1)
		List (APPEND ${CONF} "RelWithDebInfo")
	EndIf (ridx GREATER -1 AND didx GREATER -1)
ENDMACRO (ADD_RELWITHDEBINFO_CONFIGURATION)

Macro (ADD_INSTALL_TARGETS)

	ForEach (tgt ${ARGN})
		Set (install_component install-${tgt})

		If (WIN32)
			Add_Custom_Target (
				${install_component}
				COMMAND ${CMAKE_COMMAND}
				-D COMPONENT=${install_component}
				-D BUILD_TYPE=${CMAKE_CFG_INTDIR}
				-P ${CMAKE_CURRENT_BINARY_DIR}/cmake_install.cmake
				)
			Set_Property (TARGET ${install_component} PROPERTY FOLDER "Install Files")
		Else (WIN32)
			Add_Custom_Target (
				${install_component}
				COMMAND ${CMAKE_COMMAND}
				-D COMPONENT=${install_component}
				-P ${CMAKE_CURRENT_BINARY_DIR}/cmake_install.cmake
				)
		EndIf (WIN32)
	EndForEach (tgt)

EndMacro (ADD_INSTALL_TARGETS)

MACRO (INSTALL_LIBRARY_TARGET)
	Parse_Arguments(InstallTarget
		"NAME;ALIAS_NAME;CONFIGURATIONS" "" ${ARGN}
		)

	If ("${InstallTarget_CONFIGURATIONS}" STREQUAL "All")
		Install (
			TARGETS ${InstallTarget_NAME}
			RUNTIME DESTINATION bin
			LIBRARY DESTINATION lib
			)
	Else("${InstallTarget_CONFIGURATIONS}" STREQUAL "All")

		Add_RelWithDebInfo_Configuration(InstallTarget_CONFIGURATIONS)

		ForEach (Conf ${InstallTarget_CONFIGURATIONS})
			String (REGEX MATCH "[Dd]eb" DebugBuild ${Conf})
			If (DebugBuild)
				Install (
					TARGETS ${InstallTarget_NAME}
					CONFIGURATIONS ${Conf}
					RUNTIME DESTINATION bin_debug
					LIBRARY DESTINATION lib_debug
					)
			Else (DebugBuild)
				Install (
					TARGETS ${InstallTarget_NAME}
					CONFIGURATIONS ${Conf}
					RUNTIME DESTINATION bin
					LIBRARY DESTINATION lib
					)
			EndIf (DebugBuild)
		EndForEach (Conf)
	EndIf("${InstallTarget_CONFIGURATIONS}" STREQUAL "All")

ENDMACRO(INSTALL_LIBRARY_TARGET)

MACRO (INSTALL_EXE_TARGET)
	Parse_Arguments (InstallTarget
		"NAME;ALIAS_NAME;DEST_DIR;CONFIGURATIONS" "" ${ARGN}
		)

	If ("${InstallTarget_CONFIGURATIONS}" STREQUAL "All")
		Install (
			TARGETS ${InstallTarget_NAME}
			RUNTIME DESTINATION ${InstallTarget_DEST_DIR}
			)
	Else("${InstallTarget_CONFIGURATIONS}" STREQUAL "All")

		Add_RelWithDebInfo_Configuration(InstallTarget_CONFIGURATIONS)

		ForEach (Conf ${InstallTarget_CONFIGURATIONS})
			String (REGEX MATCH "[Dd]eb" DebugBuild ${Conf})
			If (DebugBuild)
				Install (
					TARGETS ${InstallTarget_NAME}
					CONFIGURATIONS ${Conf}
					RUNTIME DESTINATION ${InstallTarget_DEST_DIR}_debug
					)
			Else (DebugBuild)
				Install (
					TARGETS ${InstallTarget_NAME}
					CONFIGURATIONS ${Conf}
					RUNTIME DESTINATION ${InstallTarget_DEST_DIR}
					)
			EndIf (DebugBuild)
		EndForEach (Conf)
	EndIf("${InstallTarget_CONFIGURATIONS}" STREQUAL "All")

ENDMACRO (INSTALL_EXE_TARGET)

MACRO (SHARED_LIBRARY TargetName)
	Module (
		NAME ${TargetName}
		TYPE "SharedLibrary"
		)
ENDMACRO (SHARED_LIBRARY)

MACRO (STATIC_LIBRARY TargetName)
	Module (
		NAME ${TargetName}
    TYPE "StaticLibrary"
		)
ENDMACRO (STATIC_LIBRARY)

MACRO (QT_MODULE)
	Parse_Arguments (ARGS
		"NAME;UI_DIR;RC_DIR;TYPE;OTHER_SOURCES" "" ${ARGN}
		)
	Set_Directory_Property (USE_QT 1)
	Set_Directory_Property (QT_UI_DIR ${ARGS_UI_DIR})
	Set_Directory_Property (QT_RC_DIR ${ARGS_RC_DIR})
	Set_Directory_Property (OTHER_SOURCES ${ARGS_OTHER_SOURCES})
	Module (
		NAME ${ARGS_NAME}
		TYPE ${ARGS_TYPE}
		)
ENDMACRO (QT_MODULE)

MACRO (QT_LIBRARY)
	Parse_Arguments (ARGS
		"NAME;UI_DIR;RC_DIR;OTHER_SOURCES" "" ${ARGN}
		)
	Qt_Module (
		NAME ${ARGS_NAME}
		UI_DIR ${ARGS_UI_DIR}
		RC_DIR ${ARGS_RC_DIR}
		OTHER_SOURCES ${ARGS_OTHER_SOURCES}
		TYPE "SharedLibrary"
		)
ENDMACRO (QT_LIBRARY)

MACRO (QT_EXE)
	Parse_Arguments (ARGS
		"NAME;UI_DIR;RC_DIR;OTHER_SOURCES" "" ${ARGN}
		)
	Qt_Module (
		NAME ${ARGS_NAME}
		UI_DIR ${ARGS_UI_DIR}
		RC_DIR ${ARGS_RC_DIR}
		OTHER_SOURCES ${ARGS_OTHER_SOURCES}
		TYPE "Executable"
		)
ENDMACRO (QT_EXE)

MACRO (ADD_MODULE)
	Parse_Arguments (LibraryTarget
		"NAME;SRC_DIR;INSTALL_ALIAS;INSTALL_CONFIGURATIONS" "" ${ARGN}
		)

	Add_Definitions ("-DDLL_SOURCE")

	String (REPLACE "Src" "Include" INC_DIR ${LibraryTarget_SRC_DIR})
	File (GLOB SRC_FILES ${LibraryTarget_SRC_DIR}/*.cxx)
	File (GLOB DEF_FILES ${LibraryTarget_SRC_DIR}/*.def)
	File (GLOB HXX_FILES ${INC_DIR}/*.hxx)

	Add_Library (
		${LibraryTarget_NAME} MODULE
		${SRC_FILES} ${HXX_FILES} ${DEF_FILES}
		)

	Set_Target_Properties (${LibraryTarget_NAME} PROPERTIES DEBUG_POSTFIX d)

	If (DEF_FILES)
		Set_Target_Properties (
			${LibraryTarget_NAME} PROPERTIES 
			ENABLE_EXPORTS ON
			LINK_FLAGS "/INCREMENTAL:NO"
			)
	EndIf (DEF_FILES)

	Install_Library_Target (
		NAME ${LibraryTarget_NAME}
		ALIAS_NAME ${LibraryTarget_INSTALL_ALIAS}
		CONFIGURATIONS ${LibraryTarget_INSTALL_CONFIGURATIONS}
		)
ENDMACRO (ADD_MODULE)
