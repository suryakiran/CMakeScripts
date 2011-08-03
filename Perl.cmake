Include (FindPerl)

If (NOT PERL_EXECUTABLE)
  Message (FATAL_ERROR "Unable to find Perl. Please install perl and retry")
EndIf (NOT PERL_EXECUTABLE)

Set (OutFile ${CMAKE_BINARY_DIR}/PerlConfig.cmake)
Execute_Process (
  COMMAND ${PERL_EXECUTABLE} ${CMAKE_PERL_DIR}/PerlConfig.pl -o ${OutFile}
  RESULT_VARIABLE PERL_CONFIG_RESULT_VARIABLE
  OUTPUT_VARIABLE PERL_CONFIG_OUTPUT_VARIABLE
  ERROR_VARIABLE PERL_CONFIG_ERROR_VARIABLE
  )

If (NOT ${PERL_CONFIG_RESULT_VARIABLE}) 
  If (EXISTS ${OutFile})
    Include (${OutFile})
  EndIf (EXISTS ${OutFile})
EndIf (NOT ${PERL_CONFIG_RESULT_VARIABLE}) 

Function (FIND_PERL_C_MODULES)
  Set (Modules)
  If (ARGN)
    ForEach (arg ${ARGN})
      List (APPEND Modules "-m")
      List (APPEND Modules ${arg})
    EndForEach (arg)
  EndIf (ARGN)

  Set (OutFile ${CMAKE_BINARY_DIR}/PerlCModules.cmake)

  If (Modules)

    Execute_Process (
      COMMAND ${PERL_EXECUTABLE} ${CMAKE_PERL_DIR}/FindPerlCModules.pl -o ${OutFile} ${Modules}
      RESULT_VARIABLE FIND_PERL_C_MODULES_RESULT_VARIABLE
      OUTPUT_VARIABLE FIND_PERL_C_MODULES_OUTPUT_VARIABLE
      ERROR_VARIABLE FIND_PERL_C_MODULES_ERROR_VARIABLE
      )

    If (FIND_PERL_C_MODULES_OUTPUT_VARIABLE)
      Message (${FIND_PERL_C_MODULES_OUTPUT_VARIABLE})
    EndIf (FIND_PERL_C_MODULES_OUTPUT_VARIABLE)

    If (NOT ${FIND_PERL_C_MODULES_RESULT_VARIABLE})
      If (EXISTS ${OutFile})
        Include (${OutFile})
      EndIf (EXISTS ${OutFile})
    Else (NOT ${FIND_PERL_C_MODULES_RESULT_VARIABLE})
      Message (${FIND_PERL_C_MODULES_ERROR_VARIABLE})
    EndIf (NOT ${FIND_PERL_C_MODULES_RESULT_VARIABLE})

  EndIf (Modules)

EndFunction (FIND_PERL_C_MODULES)

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
    ERROR_VARIABLE PERL_STL_MAP_WRITE_ERROR
    RESULT_VARIABLE PERL_STL_MAP_WRITE_RESULT
    OUTPUT_VARIABLE PERL_STL_MAP_WRITE_OUTPUT
    )

  If (PERL_STL_MAP_WRITE_RESULT)
    Message (${PERL_STL_MAP_WRITE_ERROR})
  EndIf (PERL_STL_MAP_WRITE_RESULT)

EndFunction (CREATE_STL_MAP_FILE)

Function (CONFIGURE_EXECUTABLE_FILE p_from p_to)
  Configure_File (${p_from} ${p_to} ${ARGN})
  Execute_Process (
    COMMAND
      ${PERL_EXECUTABLE} -e "chmod 0755, '${p_to}' if -e '${p_to}'"
      )
EndFunction (CONFIGURE_EXECUTABLE_FILE)

Function (PERL_XSI_DEPENDS PerlXsiLib)
  If (ARGN)
    Set (PerlCModules)
    ForEach (arg ${ARGN})
      String (REPLACE "::" "" arg ${arg})
      Get_Property (loc TARGET PerlCModule${arg} PROPERTY IMPORTED_LOCATION)

      If (WIN32)
        List (APPEND PerlCModules ${loc})
      Else (WIN32)
        List (APPEND PerlCModules "PerlCModule${arg}")
      EndIf (WIN32)

    EndForEach (arg)
    Target_Link_Libraries (${PerlXsiLib} ${PerlCModules})
  EndIf (ARGN)
EndFunction (PERL_XSI_DEPENDS)

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

Function (CHECK_PERL_MODULES)
  Set (OutFile ${CMAKE_BINARY_DIR}/PerlCheckModules.pl)
  If (ARGN)
    FILE (WRITE ${OutFile} "use strict;\nuse warnings;\n\n")
    ForEach (arg ${ARGN})
      FILE (APPEND ${OutFile} "use ${arg};\n")
    EndForEach (arg ${ARGN})

    Execute_Process (
      COMMAND ${PERL_EXECUTABLE} ${OutFile}
      RESULT_VARIABLE CHECK_PERL_MODULES_RESULT
      OUTPUT_VARIABLE CHECK_PERL_MODULES_OUTPUT
      ERROR_VARIABLE CHECK_PERL_MODULES_ERROR
      )

    If (CHECK_PERL_MODULES_RESULT)
      Message (FATAL_ERROR ${CHECK_PERL_MODULES_ERROR})
    EndIf (CHECK_PERL_MODULES_RESULT)
  EndIf (ARGN)
EndFunction (CHECK_PERL_MODULES)

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
