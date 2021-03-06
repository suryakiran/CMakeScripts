If (USE_QT)
  Add_Definitions ("-DQT_NO_KEYWORDS")
EndIf (USE_QT)

If (USE_POCO)
  Add_Definitions ("-DPOCO_NO_WSTRING")
EndIf (USE_POCO)

If (UNIX)
	Add_Definitions ("-DUNIX")
  # Set (CMAKE_SKIP_BUILD_RPATH TRUE)
Else (UNIX)
  Set_Property (GLOBAL PROPERTY USE_FOLDERS TRUE)
  Add_Definitions ("-DWINDOWS")
  Add_Definitions ("-D_CRT_SECURE_NO_WARNINGS")
  If (USE_BOOST)
    Add_Definitions ("-DBOOST_TYPEOF_SILENT")
    Add_Definitions ("-DBOOST_ALL_DYN_LINK")
    Set (Boost_LIB_DIAGNOSTIC_DEFINITIONS "-DBOOST_LIB_DIAGNOSTIC")
  EndIf (USE_BOOST)
  If (${CMAKE_SYSTEM_VERSION} EQUAL 6.0)
	  Add_Definitions ("-DWIN_VISTA")
  EndIf (${CMAKE_SYSTEM_VERSION} EQUAL 6.0)
EndIf (UNIX)

If (NOT CMAKE_BUILD_TYPE)
  Set (CMAKE_BUILD_TYPE "Debug")
EndIf (NOT CMAKE_BUILD_TYPE)
