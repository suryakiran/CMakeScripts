Find_Program (
  ZORBA_EXECUTABLE zorba
  )

If (ZORBA_EXECUTABLE)
  Execute_Process (
    COMMAND ${ZORBA_EXECUTABLE} "--version"
    RESULT_VARIABLE ZORBA_VERSION_RESULT
    OUTPUT_VARIABLE ZORBA_VERSION_OUTPUT
    ERROR_VARIABLE ZORBA_VERSION_ERROR
    )

  If (NOT ZORBA_VERSION_RESULT)
    Message (${ZORBA_VERSION_ERROR})
  Else (NOT ZORBA_VERSION_RESULT)
    String (REPLACE "Zorba XQuery Engine, Version: " "" ZORBA_VERSION ${ZORBA_VERSION_OUTPUT})
  EndIf (NOT ZORBA_VERSION_RESULT)

  Get_Filename_Component (ZORBA_INC_SEARCH_PATH ${ZORBA_EXECUTABLE} PATH)
  Get_Filename_Component (ZORBA_ROOT ${ZORBA_INC_SEARCH_PATH} PATH)

  Find_File (
    ZORBA_XQC_H xqc.h 
    PATHS ${ZORBA_ROOT} 
    PATH_SUFFIXES include 
    NO_DEFAULT_PATH
    )

  Get_Filename_Component (ZORBA_INCLUDE_DIR ${ZORBA_XQC_H} PATH CACHE)

  Find_Library (
    ZORBA_OPTIMIZED_LIBRARY
    zorba_simplestore
    PATHS ${ZORBA_ROOT}
    PATH_SUFFIXES lib
    )

  Find_Library (
    ZORBA_DEBUG_LIBRARY
    NAMES zorba_simplestored zorba_simplestore
    PATHS ${ZORBA_ROOT}
    PATH_SUFFIXES lib-debug lib
    NO_DEFAULT_PATH
    )

  Execute_Perl (
    FILE ${PL_FILE_LIBRARY_NAMES}
    CMAKE_OUTPUT ${CMAKE_BINARY_DIR}/Zorba.cmake
    ARGS -p ZORBA
    )

  Mark_As_Advanced (
    ZORBA_INCLUDE_DIR
    ZORBA_EXECUTABLE
    ZORBA_XQC_H
    )

EndIf (ZORBA_EXECUTABLE)
