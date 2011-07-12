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
  Configure_File (${p_from} ${p_to} ${ARGN})
  Execute_Process (
    COMMAND
      ${PERL_EXECUTABLE} -e "chmod 0755, '${p_to}' if -e '${p_to}'"
      )
EndFunction (CONFIGURE_EXECUTABLE_FILE)

Function (PERL_EXTENSION)
  Set (target ${ARGV0})
  Add_Library (${ARGN})
  String (REPLACE PerlSv "" Dependency ${target})
  Set_Target_Properties (
    ${target} PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG}/perl/SV
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE}/perl/SV
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}/perl/SV
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}/perl/SV
    LIBRARY_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG}/perl/SV
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE}/perl/SV
    PREFIX ""
    OUTPUT_NAME ${Dependency}
    )
  Target_Link_Libraries (${target} ${PERL_LIBRARY} ${Dependency})
EndFunction (PERL_EXTENSION)

Find_File (
  PL_FILE_PARSE_XS
    ParseXS.pl
  PATHS 
    ${CMAKE_PERL_DIR}
  )

Find_File (
  PL_FILE_XS_DEPENDENCIES
    GetXSDependencies.pl
  PATHS
    ${CMAKE_PERL_DIR}
    )

Find_File (
  PL_FILE_INSTALL_MODULES
    InstallPerlModules.pl
  PATHS
    ${CMAKE_PERL_DIR}
    )

Mark_As_Advanced (
  PL_FILE_PARSE_XS
  PL_FILE_XS_DEPENDENCIES
  PL_FILE_INSTALL_MODULES
  )
