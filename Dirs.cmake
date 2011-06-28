Get_Filename_Component (CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_PERL_DIR ${CMAKE_MODULE_PATH}/Perl ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_PYTHON_DIR ${CMAKE_MODULE_PATH}/Python ABSOLUTE CACHE)
Get_Filename_Component (CMAKE_CONFIG_DIR ${CMAKE_SOURCE_DIR}/Config ABSOLUTE CACHE)

Get_Filename_Component (CMAKE_DLL_H_IN_FILE ${CMAKE_MODULE_PATH}/Configure/Dll.h.in ABSOLUTE CACHE)

If (WIN32)
  Add_Definitions ("-DWINDOWS")
EndIf (WIN32)