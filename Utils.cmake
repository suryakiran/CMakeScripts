Include (${CMAKE_MODULE_PATH}/Macros.cmake)

Macro (SET_TARGET p_name)
  Set_Property (DIRECTORY PROPERTY Target_Name ${p_name})
EndMacro (SET_TARGET)

Function (CREATE_SHARED_LIBRARY)
 
  Parse_Arguments (
    Lib
    "SOURCES;TARGET;SOURCE_GLOB;DEPENDENCIES"
    ""
    ${ARGN}
    )

  Get_Property (tgt_name DIRECTORY PROPERTY Target_Name)

  If (Lib_SOURCE_GLOB)
    ForEach (g ${Lib_SOURCE_GLOB})
      Set (files)
      File (GLOB files ${CMAKE_CURRENT_SOURCE_DIR}/${g})
      List (APPEND Lib_SOURCES ${files})
    EndForEach (g)
  EndIf (Lib_SOURCE_GLOB)

  If (NOT tgt_name)
    Set (tgt_name ${Lib_TARGET})
  EndIf (NOT tgt_name)

  If (NOT tgt_name)
    Return()
  EndIf(NOT tgt_name)

  Add_Library (${tgt_name} SHARED ${Lib_SOURCES})

  If (Lib_DEPENDENCIES)
    Target_Link_Libraries (${tgt_name} ${Lib_DEPENDENCIES})
  EndIf (Lib_DEPENDENCIES)

  If (WIN32)
    Set_Target_Properties (${tgt_name} PROPERTIES 
      PREFIX lib
      IMPORT_PREFIX lib
      )
  EndIf (WIN32)

EndFunction (CREATE_SHARED_LIBRARY)
