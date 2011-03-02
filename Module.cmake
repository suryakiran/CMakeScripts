Include (${CMAKE_MODULE_PATH}/Macros.cmake)

If (UNIX)
  String (TOLOWER ${CMAKE_BUILD_TYPE} CONF_DIR)
Else ()
  Set (CONF_DIR ${CMAKE_CFG_INTDIR})
EndIf ()

Macro (QT_GET_MOC_FILES outfiles)
  Set (MocDir ${CMAKE_CURRENT_BINARY_DIR}/moc_${CONF_DIR})
  If (UNIX)
	  File (MAKE_DIRECTORY ${MocDir})
  EndIf (UNIX)
  ForEach (file ${ARGN})
    File (STRINGS ${file} fileData REGEX Q_OBJECT)
    If (fileData)
      Get_Filename_Component (filePrefix ${file} NAME_WE)
      Set (
        outfile
        ${CMAKE_CURRENT_BINARY_DIR}/moc_${CONF_DIR}/moc_${filePrefix}.cxx
        )
      Add_Custom_Command (
        OUTPUT ${outfile}
        COMMAND ${QT_MOC_EXECUTABLE} 
        ARGS -o ${outfile} ${file}
        DEPENDS ${file}
        VERBATIM
        )
      Set (${outfiles} ${${outfiles}} ${outfile})
    EndIf (fileData)
  EndForEach (file)
EndMacro (QT_GET_MOC_FILES)

MACRO (MODULE)
	Parse_Arguments (ModuleTarget
		"NAME;TYPE" "" ${ARGN}
		)

	String (REPLACE "Src" "Include" INC_DIR ${CMAKE_CURRENT_SOURCE_DIR})
	Set (SRC_FILES)

	If (${ModuleTarget_TYPE} STREQUAL "Module")
		Get_Property (ModuleFiles DIRECTORY PROPERTY MODULE_FILES)
		ForEach (ModuleFile ${ModuleFiles})
			List (APPEND SRC_FILES ${ModuleFile})
		EndForEach (ModuleFile)
	Else()
		File (GLOB CXX_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.cxx)
		List (APPEND SRC_FILES ${CXX_FILES})

		File (GLOB HXX_FILES ${INC_DIR}/*.hxx)
		List (APPEND SRC_FILES ${HXX_FILES})
	EndIf()

	Get_Property (OtherSources DIRECTORY PROPERTY OTHER_SOURCES)
	If (OtherSources)
		List (APPEND SRC_FILES ${OtherSources})
	EndIf (OtherSources)

	Get_Property (UseQt DIRECTORY PROPERTY USE_QT)
	If (UseQt)
		Get_Property (UiDir DIRECTORY PROPERTY QT_UI_DIR)
		Get_Property (RcDir DIRECTORY PROPERTY QT_RC_DIR)
		File (GLOB UI_FILES  ${UiDir}/*.ui)
		File (GLOB QRC_FILES ${RcDir}/*.qrc)
		Include_Directories (${CMAKE_CURRENT_BINARY_DIR})
		QT4_WRAP_UI (UI_SRCS ${UI_FILES})
		QT4_ADD_RESOURCES (RC_SRCS ${QRC_FILES})
		Qt_Get_Moc_Files (MOC_SRCS ${HXX_FILES})

		List (APPEND SRC_FILES ${UI_SRCS})
		List (APPEND SRC_FILES ${RC_SRCS})
		List (APPEND SRC_FILES ${MOC_SRCS})

		Source_Group ("Ui Files" FILES ${UI_FILES})
		Source_Group ("Resource Files" FILES ${QRC_FILES})
		Source_Group ("Resource Files" REGULAR_EXPRESSION "\\.rc$")
		Source_Group ("Generated Files\\Moc Files" FILES ${MOC_SRCS})
		Source_Group ("Generated Files\\Qrc Files" FILES ${RC_SRCS})
		Source_Group ("Generated Files\\Ui Headers" FILES ${UI_SRCS})
	EndIf (UseQt)

	If (${ModuleTarget_TYPE} STREQUAL "SharedLibrary" OR ${ModuleTarget_TYPE} STREQUAL "Module")
		Set (BUILD_LIB_TYPE SHARED)
		If (${ModuleTarget_TYPE} STREQUAL "Module")
			Set (BUILD_LIB_TYPE MODULE)
		EndIf ()
		Include_Directories (${DLL_UTILITIES_DIR})
		Set (LibName ${ModuleTarget_NAME})
		String (TOUPPER ${LibName} LIBNAME)
		Set (DllOutFile ${DLL_UTILITIES_DIR}/Dll${ModuleTarget_NAME}.hxx)
		Configure_File (${DllInFile} ${DllOutFile} @ONLY)
		Add_Library (
			${ModuleTarget_NAME} ${BUILD_LIB_TYPE}
			${SRC_FILES} ${DllOutFile}
			)
		Set_Target_Properties (${ModuleTarget_NAME} PROPERTIES DEBUG_POSTFIX d)
	ElseIf (${ModuleTarget_TYPE} STREQUAL "Executable")
		Add_Executable (
			${ModuleTarget_NAME} ${SRC_FILES}
			)
		Set_Windows_Exe_Properties (${ModuleTarget_NAME})
	EndIf()

	Get_Property (deps DIRECTORY PROPERTY DEPENDENCIES)
	If (deps)
		ForEach (dep ${deps})
			Target_Link_Libraries (
				${ModuleTarget_NAME} ${dep}
				)
		EndForEach (dep)
	EndIf (deps)

	If (UseQt)
		Target_Link_Libraries (${ModuleTarget_NAME}
			${QT_QMAIN_LIBRARY} ${QT_LIBRARIES}
			)
	EndIf (UseQt)

	Get_Property (NoInstall DIRECTORY PROPERTY NO_INSTALL)
	If (NOT NoInstall)
		Get_Property (InstallDir DIRECTORY PROPERTY DEST_DIR)
		If (InstallDir)
			Install (
				TARGETS ${ModuleTarget_NAME}
				CONFIGURATIONS Release
				RUNTIME DESTINATION ${InstallDir}
				LIBRARY DESTINATION ${InstallDir}
				)
		Else ()
			Install (
				TARGETS ${ModuleTarget_NAME}
				CONFIGURATIONS Release
				RUNTIME DESTINATION bin
				LIBRARY DESTINATION lib
				)
		EndIf ()
	EndIf ()
ENDMACRO (MODULE)

