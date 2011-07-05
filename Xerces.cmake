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

  If (XERCES_DEBUG_LIBRARY AND XERCES_OPTIMIZED_LIBRARY)
    Set (
      XERCES_LIBRARIES 
      optimized ${XERCES_OPTIMIZED_LIBRARY}
      debug ${XERCES_DEBUG_LIBRARY}
      )
  ElseIf (XERCES_DEBUG_LIBRARY)
    Set (XERCES_LIBRARIES ${XERCES_DEBUG_LIBRARY})
  ElseIf (XERCES_OPTIMIZED_LIBRARY)
    Set (XERCES_LIBRARIES ${XERCES_OPTIMIZED_LIBRARY})
  EndIf (XERCES_DEBUG_LIBRARY AND XERCES_OPTIMIZED_LIBRARY)

  Mark_As_Advanced (XERCES_DEBUG_LIBRARY XERCES_OPTIMIZED_LIBRARY
    XERCES_INCLUDE_DIR XERCES_LIBRARIES XERCES_ROOT_DIR)

  Get_Lib_Dirs (XERCES ${XERCES_LIBRARIES})

EndIf (NOT XERCES_LIBS)
