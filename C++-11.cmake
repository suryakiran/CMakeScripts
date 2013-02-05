Include (CheckCXXSourceCompiles)
Include (CMakePushCheckState)

Function (CHECK_CXX11_FEATURE)
  Parse_Arguments (
    CXX11_FEATURE "FILE;NAME;VAR" "" ${ARGN}
    )

  If (CXX11_FEATURE_FILE)
    File(READ ${CMAKE_MODULE_PATH}/Src/${CXX11_FEATURE_FILE}.cxx
      FILE_AS_STRING)
  EndIf (CXX11_FEATURE_FILE)

  If (NOT ${CXX11_FEATURE_VAR})
    If (UNIX)
      Cmake_Push_Check_State()
      Set(CMAKE_REQUIRED_FLAGS "${COMPILER_FLAG_CXX11}")
      Check_Cxx_Source_Compiles("${FILE_AS_STRING}" ${CXX11_FEATURE_VAR})
      Cmake_Pop_Check_State()
    Else (UNIX)
      Check_Cxx_Source_Compiles("${FILE_AS_STRING}" ${CXX11_FEATURE_VAR})
    EndIf (UNIX)
  EndIf (NOT ${CXX11_FEATURE_VAR})
EndFunction (CHECK_CXX11_FEATURE)

If (CMAKE_COMPILER_IS_GNUCXX AND CXX11_SUPPORT_FLAG)
  Check_Cxx11_Feature(NAME "auto" FILE TestAuto VAR CXX11_FEATURE_AUTO)
  Check_Cxx11_Feature(NAME "lambda" FILE TestLambda VAR CXX11_FEATURE_LAMBDA)
  Check_Cxx11_Feature(NAME "nullptr" FILE TestNullPtr VAR CXX11_FEATURE_NULLPTR)
  Check_Cxx11_Feature(NAME "shared_ptr" FILE TestSharedPtr VAR CXX11_FEATURE_SHARED_PTR)
  Check_Cxx11_Feature(NAME "unique_ptr" FILE TestUniquePtr VAR CXX11_FEATURE_UNIQUE_PTR)
  Check_Cxx11_Feature(NAME "Fixed size array" FILE TestArray VAR CXX11_FEATURE_ARRAY)
  
  Check_Cxx11_Feature(
    NAME "Non-static data member initializers"  
    FILE TestNonStaticDataInit
    VAR CXX11_FEATURE_NON_STATIC_DATA_INIT
    )
EndIf (CMAKE_COMPILER_IS_GNUCXX AND CXX11_SUPPORT_FLAG)
