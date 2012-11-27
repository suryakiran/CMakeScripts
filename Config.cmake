If (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  Message (FATAL_ERROR "In source builds are not supported. Bailing out now")
EndIf (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})

Set (DLL_UTILITIES_DIR ${CMAKE_BINARY_DIR}/DllUtilities)

Get_Filename_Component (CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_PERL_DIR ${CMAKE_MODULE_PATH}/Perl ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_PYTHON_DIR ${CMAKE_MODULE_PATH}/Python ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_CONFIG_DIR ${CMAKE_MODULE_PATH}/Configure ABSOLUTE CACHE)
Get_Filename_Component (PROJECT_CONFIG_DIR ${CMAKE_SOURCE_DIR}/Config ABSOLUTE CACHE)

Macro (INCLUDE_CMAKE_MODULE p_moduleName)
  Include (${CMAKE_MODULE_PATH}/${p_moduleName}.cmake)
EndMacro (INCLUDE_CMAKE_MODULE)

Set (CMAKE_GVIM_INIT_FILE_OUT ${CMAKE_BINARY_DIR}/gviminit.vim)
Set (CMAKE_VARIABLES_XML_OUT_FILE ${CMAKE_BINARY_DIR}/CMakeVariables.xml)

Include_Cmake_Module(Macros)
Include_Cmake_Module(CustomPCH)

OPTION (CXX_11 "Use Cxx11 Features" FALSE)
Include_Cmake_Module(Compiler)

OPTION (USE_BOOST "Use Boost Libraries" TRUE)
OPTION (USE_POCO "Use Poco Libraries" FALSE)
OPTION (USE_QT "Use Qt Libraries" FALSE)

Set(Boost_ADDITIONAL_VERSIONS 
  1.60.1 1.60
  1.59.1 1.59
  1.58.1 1.58
  1.57.1 1.57
  1.56.1 1.56
  1.55.1 1.55
  1.54.1 1.54
  1.53.1 1.53
  1.52.1 1.52
  1.51.1 1.51
  1.50.1 1.50
  )

If (USE_BOOST)
  Find_Package(Boost
    COMPONENTS date_time program_options filesystem system thread signals wave
    chrono regex
    )
EndIf (USE_BOOST)

If (CXX_11)
  Include_Cmake_Module(C++-11)
EndIf (CXX_11)

Macro (FIND_CMAKE_CONFIGURE_FILE)
  Find_File_In_Dir (${ARGN} ${CMAKE_CONFIG_DIR})
EndMacro (FIND_CMAKE_CONFIGURE_FILE)

Find_Cmake_Configure_File (CMAKE_DLL_H_IN_FILE Dll.h.in)
Find_Cmake_Configure_File (CMAKE_PERL_EXTENSION_MODULE_FILE PerlExtensionModule.pm.tmpl)
Find_Cmake_Configure_File (CMAKE_VCPROJ_USER_IN_FILE Vcproj.user.in)
Find_Cmake_Configure_File (CMAKE_VARIABLES_XML_IN_FILE CmakeVariables.xml.in)
Find_Cmake_Configure_File (CMAKE_GVIM_INIT_TMPL_FILE gviminit.vim.tmpl)

Find_File_In_Dir (CMAKE_CONFIG_FILE Config.cmake ${CMAKE_MODULE_PATH})

Include_Cmake_Module(Git)
Include_Cmake_Module(Definitions)
Include_Cmake_Module(BuildDirectories)

Set(Boost_ADDITIONAL_VERSIONS "1.51" "1.50")

If (USE_BOOST)
  Find_Package(Boost
    COMPONENTS date_time program_options filesystem system thread signals wave
    chrono regex
    )
EndIf (USE_BOOST)

If (USE_QT)
  Find_Package (Qt4 COMPONENTS QtCore QtGui)
  Get_Filename_Component (QT_BIN_DIR ${QT_QMAKE_EXECUTABLE} PATH CACHE)
  Include (${QT_USE_FILE})
  Include (${CMAKE_MODULE_PATH}/Qt.cmake)
EndIf (USE_QT)

Configure_File (${CMAKE_VARIABLES_XML_IN_FILE} ${CMAKE_VARIABLES_XML_OUT_FILE})
