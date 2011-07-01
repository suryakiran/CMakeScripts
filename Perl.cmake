Include (FindPerl)

If (PERL_EXECUTABLE) 
  Execute_Process (
    COMMAND ${PERL_EXECUTABLE} ${CMAKE_PERL_DIR}/PerlConfig.pl -o ${CMAKE_BINARY_DIR}/PerlConfig.cmake
    RESULT_VARIABLE PERL_CONFIG_RESULT_VARIABLE
    )

  If (NOT ${PERL_CONFIG_RESULT_VARIABLE}) 
    Include (${CMAKE_BINARY_DIR}/PerlConfig.cmake)
  EndIf (NOT ${PERL_CONFIG_RESULT_VARIABLE}) 

EndIf (PERL_EXECUTABLE)

Function (CREATE_PPPORT_FILE)
  Execute_Process (
    COMMAND 
    ${PERL_EXECUTABLE} ${CMAKE_PERL_DIR}/CreatePPPort.pl 
    -o ${CMAKE_CURRENT_BINARY_DIR}/ppport.h
    RESULT_VARIABLE PERL_PPPORT_FILE_WRITE_ERROR
    )

  If (PERL_PPPORT_FILE_WRITE_ERROR)
    Message ("Perl ppport file write error")
  EndIf (PERL_PPPORT_FILE_WRITE_ERROR)
EndFunction (CREATE_PPPORT_FILE)

Function (CREATE_STL_MAP_FILE)
  Execute_Process (
    COMMAND 
    ${PERL_EXECUTABLE} ${CMAKE_PERL_DIR}/CreateStlMap.pl 
    -o ${CMAKE_CURRENT_BINARY_DIR}/stl.typemap
    RESULT_VARIABLE PERL_STL_MAP_WRITE_ERROR
    )

  If (PERL_STL_MAP_WRITE_ERROR)
    Message ("Perl stl map file write error")
  EndIf (PERL_STL_MAP_WRITE_ERROR)
EndFunction (CREATE_STL_MAP_FILE)

Function (CONFIGURE_EXECUTABLE_FILE p_from p_to)
  Configure_File (${p_from} ${p_to} $ARGN)
  Execute_Process (
    COMMAND
      ${PERL_EXECUTABLE} -e "chmod 0755, '${p_to}' if -e '${p_to}'"
      )
EndFunction (CONFIGURE_EXECUTABLE_FILE)
