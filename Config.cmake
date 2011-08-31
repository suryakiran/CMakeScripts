Get_Filename_Component (CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_PERL_DIR ${CMAKE_MODULE_PATH}/Perl ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_PYTHON_DIR ${CMAKE_MODULE_PATH}/Python ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_CONFIG_DIR ${CMAKE_MODULE_PATH}/Configure ABSOLUTE CACHE)
Get_Filename_Component (PROJECT_CONFIG_DIR ${CMAKE_SOURCE_DIR}/Config ABSOLUTE CACHE)

Set (CMAKE_GVIM_INIT_FILE_OUT ${CMAKE_BINARY_DIR}/gviminit.vim)

If (WIN32)
  Add_Definitions ("-DWINDOWS")
EndIf (WIN32)

Include (${CMAKE_MODULE_PATH}/Macros.cmake)
Macro (FIND_CMAKE_CONFIGURE_FILE)
  Find_File_In_Dir (${ARGN} ${CMAKE_CONFIG_DIR})
EndMacro (FIND_CMAKE_CONFIGURE_FILE)

Find_Cmake_Configure_File (CMAKE_DLL_H_IN_FILE Dll.h.in)
Find_Cmake_Configure_File (CMAKE_PERL_EXTENSION_MODULE_FILE PerlExtensionModule.pm.in)
Find_Cmake_Configure_File (CMAKE_VCPROJ_USER_IN_FILE Vcproj.user.in)
Find_Cmake_Configure_File (CMAKE_GVIM_INIT_FILE gviminit.vim.in)
