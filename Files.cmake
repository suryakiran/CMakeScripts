Include (${CMAKE_MODULE_PATH}/Macros.cmake)

Macro (FIND_CMAKE_CONFIGURE_FILE)
  Find_File_In_Dir (${ARGN} ${CMAKE_MODULE_PATH}/Configure)
EndMacro (FIND_CMAKE_CONFIGURE_FILE)

Find_Cmake_Configure_File (CMAKE_DLL_H_IN_FILE Dll.h.in)
Find_Cmake_Configure_File (CMAKE_PERL_EXTENSION_MODULE_FILE PerlExtensionModule.pm.in)
Find_Cmake_Configure_File (CMAKE_VCPROJ_USER_IN_FILE Vcproj.user.in)
