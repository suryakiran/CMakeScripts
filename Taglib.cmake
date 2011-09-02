Set (
  TAGLIB_SEARCH_PATHS
  $ENV{TAGLIB_ROOT}
  $ENV{PACKAGES_DIR}
  )

If (UNIX)
  List (
    APPEND TAGLIB_SEARCH_PATHS
    /usr/local
    /usr
    )
EndIf (UNIX)

Find_File (
  TAGLIB_HEADER_FILE taglib.h
  PATHS ${TAGLIB_SEARCH_PATHS}
  PATH_SUFFIXES include/taglib 
  NO_DEFAULT_PATH
  )

If (TAGLIB_HEADER_FILE)
  Get_Filename_Component (TAGLIB_HEADER_DIR ${TAGLIB_HEADER_FILE} PATH)
  Get_Filename_Component (TAGLIB_INCLUDE_DIR ${TAGLIB_HEADER_DIR} PATH CACHE)

  If (NOT TAGLIB_ROOT_DIR)
    Get_Filename_Component (TAGLIB_ROOT_DIR ${TAGLIB_INCLUDE_DIR} PATH CACHE)
  EndIf (NOT TAGLIB_ROOT_DIR)

  Find_Library (
    TAGLIB_OPTIMIZED_LIBRARY
    tag
    PATHS ${TAGLIB_ROOT_DIR}
    PATH_SUFFIXES lib
    )

  Find_Library (
    TAGLIB_DEBUG_LIBRARY
    NAMES tagd tag
    PATHS ${TAGLIB_ROOT_DIR}
    PATH_SUFFIXES lib-debug lib
    NO_DEFAULT_PATH
    )

  Execute_Perl (
    FILE ${PL_FILE_LIBRARY_NAMES}
    CMAKE_OUTPUT ${CMAKE_BINARY_DIR}/Taglib.cmake
    ARGS -p TAGLIB
    )

EndIf (TAGLIB_HEADER_FILE)
