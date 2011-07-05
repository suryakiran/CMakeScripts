Set (
  XQILLA_SEARCH_PATHS
  $ENV{XQILLA_DIR}
  $ENV{PACKAGES_DIR}
  /usr/local
  /usr
  )

Set (XQILLA_INC_SEARCH_PATHS)

If (XQILLA_EXECUTABLE)
  Get_Filename_Component (inc_dir ${XQILLA_EXECUTABLE} PATH)
  Get_Filename_Component (inc_dir ${inc_dir} PATH)
  List (APPEND XQILLA_INC_SEARCH_PATHS ${inc_dir})
EndIf (XQILLA_EXECUTABLE)

Set (
  XQILLA_INC_SEARCH_PATHS
  $ENV{XQILLA_ROOT}
  $ENV{PACKAGES_DIR}
  /usr/local
  /usr/
  )

Find_Program (
  XQILLA_EXECUTABLE
  xqilla
  PATHS ${XQILLA_SEARCH_PATHS}
  PATH_SUFFIXES bin
)

Find_File (
  XQILLA_INC_HEADER
  xqc.h
  PATHS ${XQILLA_INC_SEARCH_PATHS}
  PATH_SUFFIXES include
  )

If (XQILLA_INC_HEADER)
  Get_Filename_Component (XQILLA_INCLUDE_DIR ${XQILLA_INC_HEADER} PATH CACHE)
  Get_Filename_Component (XQILLA_ROOT_DIR ${XQILLA_INCLUDE_DIR} PATH CACHE)

  Find_Library (
    XQILLA_LIBRARIES
    xqilla
    PATHS ${XQILLA_ROOT_DIR}
    PATH_SUFFIXES lib
    )
EndIf (XQILLA_INC_HEADER)

Mark_As_Advanced (
  XQILLA_EXECUTABLE
  XQILLA_INCLUDE_DIR
  XQILLA_LIBRARIES
  XQILLA_INC_HEADER
  XQILLA_ROOT_DIR
  XQILLA_LIBRARIES
  )
