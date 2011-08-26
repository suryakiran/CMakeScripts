Include (FindPerl)

If (NOT PERL_EXECUTABLE)
  Message (FATAL_ERROR "Unable to find Perl. Please install perl and retry")
EndIf (NOT PERL_EXECUTABLE)

Function (EXECUTE_PERL)
  PARSE_ARGUMENTS (EXECUTE_PERL
    "FILE;ARGS;CMAKE_OUTPUT" "" ${ARGN})
  If (EXECUTE_PERL_FILE)

    If (EXECUTE_PERL_CMAKE_OUTPUT)
      List (APPEND EXECUTE_PERL_ARGS "-o")
      List (APPEND EXECUTE_PERL_ARGS ${EXECUTE_PERL_CMAKE_OUTPUT})
    EndIf (EXECUTE_PERL_CMAKE_OUTPUT)

    Execute_Process (
      COMMAND ${PERL_EXECUTABLE} ${EXECUTE_PERL_FILE} ${EXECUTE_PERL_ARGS}
      RESULT_VARIABLE EXECUTE_PERL_RESULT_VARIABLE
      OUTPUT_VARIABLE EXECUTE_PERL_OUTPUT_VARIABLE
      ERROR_VARIABLE  EXECUTE_PERL_ERROR_VARIABLE
      )

    If (EXECUTE_PERL_OUTPUT_VARIABLE)
      Message (${EXECUTE_PERL_OUTPUT_VARIABLE})
    EndIf (EXECUTE_PERL_OUTPUT_VARIABLE)

    If (EXECUTE_PERL_RESULT_VARIABLE)
      Message (${EXECUTE_PERL_ERROR_VARIABLE})
    ElseIf (EXECUTE_PERL_CMAKE_OUTPUT)
      Include (${EXECUTE_PERL_CMAKE_OUTPUT})
    EndIf (EXECUTE_PERL_RESULT_VARIABLE)

  EndIf (EXECUTE_PERL_FILE)
EndFunction (EXECUTE_PERL)

Execute_Perl (
  FILE ${CMAKE_PERL_DIR}/PerlConfig.pl
  CMAKE_OUTPUT ${CMAKE_BINARY_DIR}/PerlConfig.cmake
  )

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
    Execute_Perl (
      FILE ${CMAKE_PERL_DIR}/FindPerlCModules.pl
      CMAKE_OUTPUT ${OutFile}
      ARGS ${Modules}
      )
  EndIf (Modules)
EndFunction (FIND_PERL_C_MODULES)

Function (CREATE_PPPORT_FILE)
  Execute_Perl (
    FILE ${CMAKE_PERL_DIR}/CreatePPPort.pl
    ARGS -o ${CMAKE_CURRENT_BINARY_DIR}/ppport.h
    )
EndFunction (CREATE_PPPORT_FILE)

Function (CREATE_STL_MAP_FILE)
  Execute_Perl (
    FILE ${CMAKE_PERL_DIR}/CreateStlMap.pl
    ARGS -o ${CMAKE_CURRENT_BINARY_DIR}/stl.typemap
    )
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

    Execute_Perl (FILE ${OutFile})
  EndIf (ARGN)
EndFunction (CHECK_PERL_MODULES)

Function (CREATE_PERL_XSI_LIBRARY)
  Parse_Arguments (
    PERL_XSI
    "MODULES;DEPENDENCIES;PERL_C_MODULES" "" ${ARGN}
    )

  Set (XsiName PerlXsi)
  Set (Args)
  ForEach (arg ${PERL_XSI_MODULES} ${PERL_XSI_PERL_C_MODULES})
    List (APPEND Args "-m")
    List (APPEND Args "${arg}")
  EndForEach (arg ${ARGN})

  Set (PerlXsiFile ${CMAKE_CURRENT_BINARY_DIR}/${XsiName}.c)
  List (APPEND Args "-o")
  List (APPEND Args ${PerlXsiFile})

  Add_Custom_Command (
    OUTPUT ${PerlXsiFile}
    COMMAND ${PERL_EXECUTABLE} ${CMAKE_PERL_DIR}/CreateXsiFile.pl ${Args}
    )

  Set (LibName ${XsiName})
  Set (DllOutFile ${DLL_UTILITIES_DIR}/DllPerlXsi.hxx)
  Configure_File (${CMAKE_DLL_H_IN_FILE} ${DllOutFile} @ONLY)
  Include_Directories (${DLL_UTILITIES_DIR})
  Message (${DLL_UTILITIES_DIR})
  Add_Library (${XsiName} SHARED ${PerlXsiFile} ${DllOutFile})
  Target_Link_Libraries (${XsiName} ${PERL_XSI_DEPENDENCIES} ${PERL_LIBRARY})
  Perl_Xsi_Depends (${XsiName} ${PERL_XSI_PERL_C_MODULES})
EndFunction (CREATE_PERL_XSI_LIBRARY)

Function (FIND_PERL_FILE)
  Find_File_In_Dir (${ARGN} ${CMAKE_PERL_DIR})
EndFunction (FIND_PERL_FILE)

Function (CREATE_VCPROJ_USER_FILE)
EndFunction (CREATE_VCPROJ_USER_FILE)

Find_Perl_File(PL_FILE_PARSE_XS ParseXS.pl)
Find_Perl_File(PL_FILE_XS_DEPENDENCIES GetXSDependencies.pl)
Find_Perl_File(PL_FILE_INSTALL_MODULES InstallPerlModules.pl)
Find_Perl_File(PL_FILE_VCPROJ_USER Vcproj.user.pl)
