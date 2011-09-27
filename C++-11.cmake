Include (CheckCXXSourceCompiles)

Function (CHECK_CXX11_FEATURE)
  Parse_Arguments (
    CXX11_FEATURE "FILE;NAME;VAR" "" ${ARGN}
    )

  If (CXX11_FEATURE_FILE)
    File(READ ${CMAKE_MODULE_PATH}/Src/${CXX11_FEATURE_FILE}.cxx
      FILE_AS_STRING)
  EndIf (CXX11_FEATURE_FILE)

  If (NOT ${CXX11_FEATURE_VAR})
    Message (STATUS "Checking for C++-11 feature: " ${CXX11_FEATURE_NAME})

    If (UNIX)
      Try_Compile (
        result
        ${CMAKE_BINARY_DIR}/C++11-Tests
        ${CMAKE_MODULE_PATH}/Src/${CXX11_FEATURE_FILE}.cxx
        CMAKE_FLAGS -DCOMPILE_DEFINITIONS:STRING=${COMPILER_FLAG_CXX11}
        OUTPUT_VARIABLE CXX11_FEATURE_OUTPUT
        )
    Else (UNIX)
      Try_Compile (
        result
        ${CMAKE_BINARY_DIR}/C++11-Tests
        ${CMAKE_MODULE_PATH}/Src/${CXX11_FEATURE_FILE}.cxx
        OUTPUT_VARIABLE CXX11_FEATURE_OUTPUT
        )
    EndIf (UNIX)

    If (result)
      Set (${CXX11_FEATURE_VAR} 1 CACHE INTERNAL "Support for C++ feature: ${CXX11_FEATURE_NAME}")
      Message (STATUS "Checking for C++-11 feature: ${CXX11_FEATURE_NAME} -- found")
    Else (result)
      Set (${CXX11_FEATURE_VAR} 0 CACHE INTERNAL "Support for C++ feature: ${CXX11_FEATURE_NAME}")
      Message (STATUS "Checking for C++-11 feature: ${CXX11_FEATURE_NAME} -- not found")
    EndIf (result)

  EndIf (NOT ${CXX11_FEATURE_VAR})
EndFunction (CHECK_CXX11_FEATURE)

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
