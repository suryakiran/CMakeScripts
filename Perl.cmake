Include (FindPerl)

If (PERL_EXECUTABLE) 
  Execute_Process (
    COMMAND ${PERL_EXECUTABLE} ${CMAKE_MODULE_PATH}/perl/PerlConfig.pl -o ${CMAKE_BINARY_DIR}/PerlConfig.cmake
    RESULT_VARIABLE PERL_CONFIG_RESULT_VARIABLE
    )

  If (NOT ${PERL_CONFIG_RESULT_VARIABLE}) 
    Include (${CMAKE_BINARY_DIR}/PerlConfig.cmake)
  EndIf (NOT ${PERL_CONFIG_RESULT_VARIABLE}) 

EndIf (PERL_EXECUTABLE)

Function (CREATE_PPPORT_FILE)
  Execute_Process (
    COMMAND 
    ${PERL_EXECUTABLE} ${CMAKE_MODULE_PATH}/CreatePPPort.pl 
    -o ${CMAKE_CURRENT_BINARY_DIR}/ppport.h
    RESULT_VARIABLE PERL_PPPORT_FILE_WRITE_ERROR
    )

  If (PERL_PPPORT_FILE_WRITE_ERROR)
    Message ("Perl ppport file write error")
  EndIf (NOT PERL_PPPORT_FILE_WRITE_ERROR)
EndFunction (CREATE_PPPORT_FILE)

Function (CREATE_STL_MAP_FILE)
  Execute_Process (
    COMMAND 
    ${PERL_EXECUTABLE} ${CMAKE_MODULE_PATH}/CreateStlMap.pl 
    -o ${CMAKE_CURRENT_BINARY_DIR}/stl.typemap
    RESULT_VARIABLE PERL_STL_MAP_WRITE_ERROR
    )

  If (PERL_STL_MAP_FILE_WRITE_ERROR)
    Message ("Perl stl map file write error")
  EndIf (NOT PERL_STL_MAP_WRITE_ERROR)
EndFunction (CREATE_STL_MAP_FILE)
