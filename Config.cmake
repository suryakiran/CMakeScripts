If (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  Message (FATAL_ERROR "In source builds are not supported. Bailing out now")
EndIf (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})

Set (DLL_UTILITIES_DIR ${CMAKE_BINARY_DIR}/DllUtilities)

Get_Filename_Component (CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_PYTHON_DIR ${CMAKE_MODULE_PATH}/Python ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_CONFIG_DIR ${CMAKE_MODULE_PATH}/Configure ABSOLUTE CACHE)
Get_Filename_Component (PROJECT_CONFIG_DIR ${CMAKE_SOURCE_DIR}/Config ABSOLUTE CACHE)

Macro (INCLUDE_CMAKE_MODULE p_moduleName)
  Include (${CMAKE_MODULE_PATH}/${p_moduleName}.cmake)
EndMacro (INCLUDE_CMAKE_MODULE)

Set (CMAKE_GVIM_INIT_FILE_OUT ${CMAKE_BINARY_DIR}/gviminit.vim)
Set (CMAKE_VARIABLES_YML_OUT_FILE ${CMAKE_BINARY_DIR}/CMakeVariables.yml)
Set (CMAKE_EMACS_INIT_OUT_FILE ${CMAKE_BINARY_DIR}/EmacsInit.el)

Find_Package(Perl)

Macro (FIND_FILE_IN_DIR p_varName p_fileName p_dirName)
  Find_File (
    ${p_varName}
    ${p_fileName}
    PATHS
    ${p_dirName}
    )

  If (${p_varName})
    Mark_As_Advanced (${p_varName})
  EndIf (${p_varName})
EndMacro (FIND_FILE_IN_DIR)

Macro (FIND_CMAKE_CONFIGURE_FILE)
  Find_File_In_Dir (${ARGN} ${CMAKE_CONFIG_DIR})
EndMacro (FIND_CMAKE_CONFIGURE_FILE)

Find_File_In_Dir (CMAKE_CONFIG_FILE Config.cmake ${CMAKE_MODULE_PATH})
Find_Cmake_Configure_File (CMAKE_DLL_H_IN_FILE Dll.h.in)
Find_Cmake_Configure_File (CMAKE_VCPROJ_USER_IN_FILE Vcproj.user.in)
Find_Cmake_Configure_File (CMAKE_VARIABLES_YML_IN_FILE CmakeVariables.yml.in)
Find_Cmake_Configure_File (CMAKE_GVIM_INIT_TMPL_FILE gviminit.vim.tmpl)
Find_Cmake_Configure_File (CMAKE_EMACS_INIT_IN_FILE EmacsInit.el.in)
Find_Cmake_Configure_File (CMAKE_PACKAGE_LIBRARY_DETAILS_IN_FILE PackageLibraryDetails.in)

Include_Cmake_Module(Macros)

# Include_Cmake_Module(CustomPCH)
Include_Cmake_Module(Python)

Find_Program (GTAGS_EXECUTABLE gtags)
Find_Program (GLOBAL_EXECUTABLE global)

OPTION (CXX_11 "Use Cxx11 Features" FALSE)
Include_Cmake_Module(Compiler)

OPTION (USE_BOOST "Use Boost Libraries" TRUE)
OPTION (USE_POCO "Use Poco Libraries" FALSE)
OPTION (USE_QT "Use Qt Libraries" FALSE)
OPTION (USE_TBB "Use Intel Thread Building Blocks Libraries" TRUE)

Set(Boost_ADDITIONAL_VERSIONS 
  1.60.1 1.60 1.60.0
  1.59.1 1.59 1.59.0
  1.58.1 1.58 1.58.0
  1.57.1 1.57 
  1.56.1 1.56
  1.55.1 1.55
  1.54.1 1.54 1.54.0
  1.53.1 1.53
  1.52.1 1.52
  1.51.1 1.51
  1.50.1 1.50
  1.46.1
  )

Set (BOOST_ROOT $ENV{BOOST_ROOT})

Find_Package(Boost $ENV{BOOST_VERSION}
  COMPONENTS date_time program_options filesystem system thread signals
  regex locale iostreams# python
  )

If (USE_TBB)
  Find_Package(IntelTBB)
EndIf (USE_TBB)

Include_Cmake_Module(C++-11)

Include_Cmake_Module(Git)
Include_Cmake_Module(Definitions)
Include_Cmake_Module(BuildDirectories)

Find_Package (Qt5Widgets)
Include_Directories (${Qt5Widgets_INCLUDE_DIRS})
Set (CMAKE_INCLUDE_CURRENT_DIR ON)

If(USE_POCO)
  Include_Cmake_Module(PocoConfig)
  Include_Directories (${Poco_INCLUDE_DIR})
EndIf(USE_POCO)

Write_Variables_Yml_File()
