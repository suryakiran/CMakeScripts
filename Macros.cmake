INCLUDE (${CMAKE_MODULE_PATH}/Boost.cmake)

MACRO (GET_GCC_VERSION OUT)
  EXECUTE_PROCESS (
    COMMAND gcc -dumpversion 
    OUTPUT_VARIABLE ${OUT} 
    RESULT_VARIABLE gcc_return
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
    )
ENDMACRO (GET_GCC_VERSION)

MACRO (GET_POCO)
  SET (POCO_ROOT $ENV{POCO_ROOT})
  SET (Poco_INCLUDE_DIRS $ENV{POCO_ROOT}/include CACHE PATH "Poco Include Dir")
  SET (Poco_LIBRARY_DIRS $ENV{POCO_ROOT}/lib CACHE PATH "Poco Include Dir")
ENDMACRO (GET_POCO)

MACRO (SET_TARGET OUT target_name debug_build)
  IF (${debug_build} STREQUAL "YES")
    SET (${OUT} ${target_name}d CACHE FILEPATH "Debug Target Name")
  ELSE (${debug_build} STREQUAL "YES")
    SET (${OUT} ${target_name} CACHE FILEPATH "Release Target Name")
  ENDIF (${debug_build} STREQUAL "YES")
ENDMACRO (SET_TARGET)

MACRO (ADD_LIBRARIES_TO_TARGET TARGET LIBNAME)
  IF (WIN32)
    SET (DEBUG_LIBRARIES ${${LIBNAME}_DEBUG_LIBRARIES})
    SET (RELEASE_LIBRARIES ${${LIBNAME}_LIBRARIES})
  ELSE (WIN32)
    SET (DEBUG_LIBRARIES ${${LIBNAME}_LIBRARIES})
    SET (RELEASE_LIBRARIES ${${LIBNAME}_LIBRARIES})
  ENDIF (WIN32)

  FOREACH (LIB ${DEBUG_LIBRARIES})
    TARGET_LINK_LIBRARIES (
      ${TARGET}
      debug ${LIB}
      )
  ENDFOREACH (LIB)

  FOREACH (LIB ${RELEASE_LIBRARIES})
    TARGET_LINK_LIBRARIES (
      ${TARGET}
      optimized ${LIB}
      )
  ENDFOREACH (LIB)
ENDMACRO (ADD_LIBRARIES_TO_TARGET)

MACRO (ADD_POCO_LIBRARIES)
  PARSE_ARGUMENTS (POCO_LIB
    "NAME;LIBRARIES" "" ${ARGN})
  SET (TARGET ${POCO_LIB_NAME})
  SET (LIBRARIES ${POCO_LIB_LIBRARIES})

  IF (Poco_USE_STATIC_LIBS)
    FOREACH (LIB ${LIBRARIES})
      IF(WIN32)
        TARGET_LINK_LIBRARIES (
          ${TARGET}
          debug Poco${LIB}mtd optimized Poco${LIB}mt
          )
      ELSE(WIN32)
        TARGET_LINK_LIBRARIES (
          ${TARGET}
          debug ${Poco_LIBRARY_DIRS}/libPoco${LIB}d.a
          optimized ${Poco_LIBRARY_DIRS}/libPoco${LIB}.a
          )
      ENDIF(WIN32)
    ENDFOREACH (LIB)
  ELSE (Poco_USE_STATIC_LIBS)
    FOREACH (LIB ${LIBRARIES})
      TARGET_LINK_LIBRARIES (
        ${TARGET}
        debug Poco${LIB}d optimized Poco${LIB}
        )
    ENDFOREACH (LIB)
  ENDIF (Poco_USE_STATIC_LIBS)
ENDMACRO (ADD_POCO_LIBRARIES)

MACRO (ADD_COMPILER_FLAGS)
  PARSE_ARGUMENTS (
    COMPILER_FLAGS
    "COMMON;DEBUG;RELEASE;RELWITHDEBINFO" "" 
    ${ARGN}
    )

  SET (COMMON_FLAGS ${COMPILER_FLAGS_COMMON})
  SET (RELEASE_FLAGS ${COMPILER_FLAGS_RELEASE})
  SET (DEBUG_FLAGS ${COMPILER_FLAGS_DEBUG})

  IF (COMMON_FLAGS)

    FOREACH (FLAG ${COMMON_FLAGS})
      SET (CRF ${CMAKE_CXX_FLAGS})
      SEPARATE_ARGUMENTS (CRF)
      LIST_CONTAINS (CVAR ${FLAG} ${CRF})
      IF (NOT CVAR)
        SET (CMAKE_CXX_FLAGS
          "${CMAKE_CXX_FLAGS} ${FLAG}"
          CACHE STRING
          "Compilation Flags" FORCE)
      ENDIF (NOT CVAR)
    ENDFOREACH (FLAG)

  ENDIF (COMMON_FLAGS)

  IF (RELEASE_FLAGS)
    SET (CRF ${CMAKE_CXX_FLAGS_RELEASE})
    SEPARATE_ARGUMENTS (CRF)

    FOREACH (FLAG ${RELEASE_FLAGS})
      LIST_CONTAINS (RVAR ${FLAG} ${CRF})
      IF (NOT RVAR)
        SET (CMAKE_CXX_FLAGS_RELEASE
          "${CMAKE_CXX_FLAGS_RELEASE} ${FLAG}"
          CACHE STRING
          "Release Compilation Flags" FORCE)
      ENDIF (NOT RVAR)
    ENDFOREACH (FLAG)

  ENDIF (RELEASE_FLAGS)

  IF (DEBUG_FLAGS)
    SET (CDF ${CMAKE_CXX_FLAGS_DEBUG})
    SEPARATE_ARGUMENTS (CDF)

    FOREACH (FLAG ${DEBUG_FLAGS})
      LIST_CONTAINS (DVAR ${FLAG} ${CDF})
      IF (NOT DVAR)
        SET (CMAKE_CXX_FLAGS_DEBUG 
          "${CMAKE_CXX_FLAGS_DEBUG} ${FLAG}"
          CACHE STRING
          "Debug Flags for Gtkmm" FORCE)
      ENDIF (NOT DVAR)
    ENDFOREACH (FLAG)

  ENDIF (DEBUG_FLAGS)

ENDMACRO (ADD_COMPILER_FLAGS)

MACRO (SET_GTK_FLAGS)
  IF (WIN32)
    ADD_COMPILER_FLAGS (COMMON /wd4250 /wd4251 /wd4275 /wd4800 /wd4805 /wd4503)
    ADD_DEFINITIONS("-D_SCL_SECURE_NO_WARNINGS")
    IF (USE_MP)
      ADD_COMPILER_FLAGS (COMMON /MP4)
    ENDIF (USE_MP)
  ENDIF (WIN32)
ENDMACRO (SET_GTK_FLAGS)

MACRO (SET_MODULE_TARGET TARGET module_name)
  IF (UNIX)
    SET (${TARGET} ${module_name} CACHE STRING "Module Name")
  ELSE (UNIX)
    SET (${TARGET} lib${module_name} CACHE STRING "Module Name")
  ENDIF (UNIX)
ENDMACRO (SET_MODULE_TARGET)

MACRO(PARSE_ARGUMENTS prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option} FALSE)
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})
    LIST_CONTAINS(is_arg_name ${arg} ${arg_names})
    IF (is_arg_name)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name)
      LIST_CONTAINS(is_option ${arg} ${option_names})
      IF (is_option)
        SET(${prefix}_${arg} TRUE)
      ELSE (is_option)
        SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option)
    ENDIF (is_arg_name)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(PARSE_ARGUMENTS)

MACRO(CAR var)
  SET(${var} ${ARGV1})
ENDMACRO(CAR)

MACRO(CDR var mylist)
  SET(${var} ${ARGN})
ENDMACRO(CDR)

MACRO(LIST_INDEX var index)
  SET(list . ${ARGN})
  FOREACH(i RANGE 1 ${index})
    CDR(list ${list})
  ENDFOREACH(i)
  CAR(${var} ${list})
ENDMACRO(LIST_INDEX)

MACRO(LIST_CONTAINS var value)
  SET(${var})
  FOREACH (value2 ${ARGN})
    IF (${value} STREQUAL ${value2})
      SET(${var} TRUE)
    ENDIF (${value} STREQUAL ${value2})
  ENDFOREACH (value2)
ENDMACRO(LIST_CONTAINS)

MACRO (SET_WINDOWS_EXE_PROPERTIES TargetName)
  If (WIN32)
    Set_Target_Properties ( ${TargetName} PROPERTIES
      LINK_FLAGS_RELEASE        "/SUBSYSTEM:WINDOWS"
      LINK_FLAGS_MINSIZEREL     "/SUBSYSTEM:WINDOWS"
      LINK_FLAGS_DEBUG          "/SUBSYSTEM:CONSOLE"
      LINK_FLAGS_RELWITHDEBINFO "/SUBSYSTEM:CONSOLE"
      LINK_FLAGS                "/ENTRY:mainCRTStartup"
      )
  EndIf (WIN32)
ENDMACRO(SET_WINDOWS_EXE_PROPERTIES)

MACRO (SET_DIRECTORY_PROPERTY PropName)
  Set (Args ${ARGN})
  If (Args)
    Set_Property (
      DIRECTORY APPEND
      PROPERTY ${PropName} ${ARGN}
      )
  EndIf (Args)
ENDMACRO (SET_DIRECTORY_PROPERTY)

Macro (WRITE_GVIM_SEARCH_DIRS)
  Set (GVIM_SEARCH_DIRS)
  ForEach (arg ${ARGN})
    If (GVIM_SEARCH_DIRS)
      Set (GVIM_SEARCH_DIRS "${GVIM_SEARCH_DIRS}\nset path+=${arg}")
    Else (GVIM_SEARCH_DIRS)
      Set (GVIM_SEARCH_DIRS "set path+=${arg}")
    EndIf (GVIM_SEARCH_DIRS)
  EndForEach (arg)
EndMacro(WRITE_GVIM_SEARCH_DIRS)

Macro (GET_LIB_DIRS p_prefix)
  Set (current_configuration)
  Set (conf_exists FALSE)
  Set (optimized_lib_dirs)
  Set (debug_lib_dirs)
  Set (p_libs ${ARGN})

  ForEach (lib ${p_libs})
    If (${lib} MATCHES "optimized|debug")
      Set (conf_exists TRUE)
    EndIf (${lib} MATCHES "optimized|debug")
  EndForEach (lib)


  If (conf_exists)
    ForEach (l ${p_libs})
      If (${l} MATCHES "optimized|debug")
        Set (current_configuration ${l})
      Else (${l} MATCHES "optimized|debug")
        Get_Filename_Component (l ${l} PATH)
        List (APPEND ${current_configuration}_lib_dirs ${l})
      EndIf (${l} MATCHES "optimized|debug")
    EndForEach (l)
  Else (conf_exists)
    Set (lib_dirs)
    ForEach (l ${p_libs})
      Get_Filename_Component (l ${l} PATH)
      List (APPEND lib_dirs ${l})
    EndForEach (l)

    Set (optimized_lib_dirs ${lib_dirs})
    Set (debug_lib_dirs ${lib_dirs})
  EndIf (conf_exists)

  If (optimized_lib_dirs)
    List (REMOVE_DUPLICATES optimized_lib_dirs)
  EndIf (optimized_lib_dirs)

  If (debug_lib_dirs)
    List (REMOVE_DUPLICATES debug_lib_dirs)
  EndIf (debug_lib_dirs)

  Set (${p_prefix}_OPTIMIZED_LIB_DIRS ${optimized_lib_dirs})
  Set (${p_prefix}_DEBUG_LIB_DIRS ${debug_lib_dirs})

EndMacro (GET_LIB_DIRS)
