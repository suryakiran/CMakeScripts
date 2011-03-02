MACRO (LIST_ADD ListName ListItem)
	If (${ListItem})
		List (APPEND ${ListName} ${${ListItem}})
	EndIf (${ListItem})
EndMacro (LIST_ADD)

MACRO(QtSetup)
	Parse_Arguments (
		QT
		"NAME;UI_DIR;RC_DIR;SRC_DIR;INC_DIR;OTHER_SOURCES;HEADER_TAG"
		"TYPE_EXE;TYPE_LIB" ${ARGN}
		)

	File (GLOB UI_FILES  ${QT_UI_DIR}/*.ui)
	File (GLOB QRC_FILES ${QT_RC_DIR}/*.qrc)
	File (GLOB CXX_FILES ${QT_SRC_DIR}/*.cxx)
	File (GLOB HXX_FILES ${QT_INC_DIR}/*.hxx)

	Include_Directories (${CMAKE_CURRENT_BINARY_DIR})

	QT4_WRAP_UI (UI_SRCS ${UI_FILES})
	QT4_ADD_RESOURCES (RC_SRCS ${QRC_FILES})
	QT4_WRAP_CPP (MOC_SRCS ${HXX_FILES})

	Set (SOURCE_FILES)

	LIST_ADD(SOURCE_FILES UI_SRCS)
	LIST_ADD(SOURCE_FILES RC_SRCS)
	LIST_ADD(SOURCE_FILES MOC_SRCS)
	LIST_ADD(SOURCE_FILES CXX_FILES)
	LIST_ADD(SOURCE_FILES HXX_FILES)
	LIST_ADD(SOURCE_FILES QT_OTHER_SOURCES)

	Source_Group (${QT_HEADER_TAG} FILES ${HXX_FILES})
	Source_Group ("Ui Files" FILES ${UI_FILES})
	Source_Group ("Resource Files" FILES ${QRC_FILES})
	Source_Group ("Resource Files" REGULAR_EXPRESSION "\\.rc$")
	Source_Group ("Generated Files\\Moc Files" FILES ${MOC_SRCS})
	Source_Group ("Generated Files\\Qrc Files" FILES ${RC_SRCS})
	Source_Group ("Generated Files\\Ui Headers" FILES ${UI_SRCS})

	If (QT_TYPE_LIB)
		Add_Library (${QT_NAME} SHARED ${SOURCE_FILES})
	ElseIf (QT_TYPE_EXE)
		Add_Executable (${QT_NAME} ${SOURCE_FILES})
	EndIf(QT_TYPE_LIB)

	Target_Link_Libraries (${QT_NAME}
		${QT_QMAIN_LIBRARY} ${QT_LIBRARIES}
		)

ENDMACRO(QtSetup)

MACRO(QtLibrary)
	Parse_Arguments (
		QtLibraryArgs 
		"NAME;UI_DIR;RC_DIR;SRC_DIR;INC_DIR;OTHER_SOURCES;HEADER_TAG"
		"" ${ARGN}
		)

	Add_Definitions ("-DDLL_SOURCE")

	If (QtLibraryArgs_HEADER_TAG)
		Set (HeaderTag ${QtExeArgs_HEADER_TAG})
	Else (QtLibraryArgs_HEADER_TAG)
		Set (HeaderTag "Header Files")
	EndIf (QtLibraryArgs_HEADER_TAG)

	If (QtLibraryArgs_OTHER_SOURCES)
		QtSetup (
			NAME ${QtLibraryArgs_NAME}
			UI_DIR ${QtLibraryArgs_UI_DIR}
			RC_DIR ${QtLibraryArgs_RC_DIR}
			SRC_DIR ${QtLibraryArgs_SRC_DIR}
			INC_DIR ${QtLibraryArgs_INC_DIR}
			OTHER_SOURCES ${QtLibraryArgs_OTHER_SOURCES}
			HEADER_TAG ${HeaderTag}
			TYPE_LIB
			)
	Else (QtLibraryArgs_OTHER_SOURCES)
		QtSetup (
			NAME ${QtLibraryArgs_NAME}
			UI_DIR ${QtLibraryArgs_UI_DIR}
			RC_DIR ${QtLibraryArgs_RC_DIR}
			SRC_DIR ${QtLibraryArgs_SRC_DIR}
			INC_DIR ${QtLibraryArgs_INC_DIR}
			HEADER_TAG ${HeaderTag}
			TYPE_LIB
			)
	EndIf (QtLibraryArgs_OTHER_SOURCES)

	Set_Target_Properties (${QT_NAME} PROPERTIES DEBUG_POSTFIX d)

ENDMACRO (QtLibrary)

MACRO(QtExe)
	Parse_Arguments (
		QtExeArgs
		"NAME;UI_DIR;RC_DIR;SRC_DIR;INC_DIR;OTHER_SOURCES;HEADER_TAG"
		"" ${ARGN}
		)

	If (QtExeArgs_HEADER_TAG)
		Set (HeaderTag ${QtExeArgs_HEADER_TAG})
	Else (QtExeArgs_HEADER_TAG)
		Set (HeaderTag "Header Files")
	EndIf (QtExeArgs_HEADER_TAG)

	If (QtExeArgs_OTHER_SOURCES)
		QtSetup (
			NAME ${QtExeArgs_NAME}
			UI_DIR ${QtExeArgs_UI_DIR}
			RC_DIR ${QtExeArgs_RC_DIR}
			SRC_DIR ${QtExeArgs_SRC_DIR}
			INC_DIR ${QtExeArgs_INC_DIR}
			OTHER_SOURCES ${QtExeArgs_OTHER_SOURCES}
			HEADER_TAG ${HeaderTag}
			TYPE_EXE
			)
	Else (QtExeArgs_OTHER_SOURCES)
		QtSetup (
			NAME ${QtExeArgs_NAME}
			UI_DIR ${QtExeArgs_UI_DIR}
			RC_DIR ${QtExeArgs_RC_DIR}
			SRC_DIR ${QtExeArgs_SRC_DIR}
			INC_DIR ${QtExeArgs_INC_DIR}
			HEADER_TAG ${HeaderTag}
			TYPE_EXE
			)
	EndIf (QtExeArgs_OTHER_SOURCES)

	Set_Windows_Exe_Properties (${QtExeArgs_NAME})
ENDMACRO(QtExe)
