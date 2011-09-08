Set (XercesSearchPaths)

Set (XercesDir $ENV{XERCESDIR})
Set (PackagesDir $ENV{PACKAGES_DIR})

If (XercesDir)
  List (APPEND XercesSearchPaths ${XercesDir})
EndIf (XercesDir)

If (PackagesDir)
  List (APPEND XercesSearchPaths ${PackagesDir})
EndIf (PackagesDir)

If (UNIX)
  List (APPEND XercesSearchPaths
    "/usr/local/include"
    "/usr/include"
    )
EndIf (UNIX)

If (NOT XERCES_LIBS)

  Find_Path (
    XERCES_INCLUDE_DIR 
    xercesc/parsers/SAXParser.hpp 
    PATHS ${XercesSearchPaths}
    PATH_SUFFIXES include
    NO_DEFAULT_PATH
    )

  If (XERCES_INCLUDE_DIR)
    Get_Filename_Component (XERCES_ROOT_DIR ${XERCES_INCLUDE_DIR} PATH CACHE)
  EndIf (XERCES_INCLUDE_DIR)

  Find_Library (
    XERCES_DEBUG_LIBRARY 
    NAMES xerces-c_3D xerces-c
    PATHS ${XERCES_ROOT_DIR}/lib
    NO_DEFAULT_PATH
    )

  Find_Library (
    XERCES_OPTIMIZED_LIBRARY 
    NAMES xerces-c_3 xerces-c
    PATHS ${XERCES_ROOT_DIR}/lib
    NO_DEFAULT_PATH
    )

  Execute_Perl (
    FILE ${PL_FILE_LIBRARY_NAMES}
    CMAKE_OUTPUT ${CMAKE_BINARY_DIR}/Xerces.cmake
    ARGS -p XERCES
    )

  Mark_As_Advanced (XERCES_INCLUDE_DIR XERCES_ROOT_DIR)

  #Get_Lib_Dirs (XERCES ${XERCES_LIBRARIES})

EndIf (NOT XERCES_LIBS)

Set (XERCES_Debug_LIBRARY ${XERCES_DEBUG_LIBRARY})
Set (XERCES_Release_LIBRARY ${XERCES_OPTIMIZED_LIBRARY})
