
# DON'T FORGET to include ${CMAKE_CURRENT_SOURCE_DIR} in include_directories for the compiler
# to see the header, and ${CMAKE_CURRENT_BINARY_DIR} for the compiler to see the GCC PCH 

# "sources" - unexpanded cmake variable holding all the source files
# "includes" - unexpanded cmake variable holding all include paths the PCH needs to know about
# "target_name" - the name of the a special target used to build the PCH for GCC
# "header_name" - the name of the PCH header, without the extension; "stdafx" or something similar;
#                  note that the source file compiling the header needs to have the same name 

Macro(PRECOMPILED_HEADER)

  Parse_Arguments (PCH
    "TYPE;SOURCES;TARGET_NAME;HEADER;INCLUDES" "" ${ARGN}
    )

  Set (PCH_IN_FILE ${CMAKE_BINARY_DIR}/test.xml)
  Set (PCH_SOURCE_FILE ${CMAKE_BINARY_DIR}/test.cxx)

  # MSVC precompiled headers cmake code
  If ( MSVC )
    Get_Filename_Component (PCH_HEADER_BASENAME ${PCH_HEADER} NAME)
    Configure_File (${CMAKE_PCH_IN_FILE} ${PCH_IN_FILE} @ONLY)
    Configure_File (${CMAKE_PCH_SOURCE_IN_FILE} ${PCH_SOURCE_FILE} @ONLY)
    Execute_Perl (
      FILE ${PL_FILE_PCH_FILE}
      ARGS -x ${PCH_IN_FILE} -c Debug
      )
    Set_Source_Files_Properties( ${PCH_HEADER}.cpp PROPERTIES COMPILE_FLAGS "/Yc${PCH_HEADER}.h" )

    ForEach( src_file ${PCH_SOURCES} )
      If( ${src_file} MATCHES ".*cpp$" )
        set_source_files_properties( ${src_file} PROPERTIES COMPILE_FLAGS "/Yu${PCH_HEADER}.h" )
      EndIf()
    EndForEach()

    # ${PCH_HEADER}.cpp has to come before ${PCH_HEADER}.h, 
    # otherwise we get a linker error...
    # TODO insert sources here
    #List( INSERT ${sources} 0 ${PCH_HEADER}.h )
    #List( INSERT ${sources} 0 ${PCH_HEADER}.cpp )

    # GCC precompiled headers cmake code
    # We don't do this on Macs since GCC there goes haywire
    # when you try to generate a PCH with two "-arch" flags
  ElseIf( CMAKE_COMPILER_IS_GNUCXX AND NOT APPLE )

    # Get the compiler flags for this build type
    String( TOUPPER "CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}" flags_for_build_name )
    Set( compile_flags ${${flags_for_build_name}} )
    List (APPEND compile_flags "${CMAKE_CXX_FLAGS}")

    If (PCH_TYPE)
      If (${PCH_TYPE} MATCHES "SHARED|MODULE")
        String(TOUPPER "CMAKE_SHARED_LIBRARY_CXX_FLAGS_${CMAKE_BUILD_TYPE}" flags_for_build_name)
        List (APPEND compile_flags ${${flags_for_build_name}})
        List (APPEND compile_flags ${CMAKE_SHARED_LIBRARY_CXX_FLAGS})
      EndIf (${PCH_TYPE} MATCHES "SHARED|MODULE")
    EndIf (PCH_TYPE)

    # Add all the Qt include directories
    ForEach( item ${PCH_INCLUDES} )
      List( APPEND compile_flags "-I${item}" )
    EndForEach()

    # Get the list of all build-independent preprocessor definitions
    Get_Directory_Property( defines_global COMPILE_DEFINITIONS )
    List( APPEND defines ${defines_global} )

    # Get the list of all build-dependent preprocessor definitions
    String( TOUPPER "COMPILE_DEFINITIONS_${CMAKE_BUILD_TYPE}" defines_for_build_name )
    Get_Directory_Property( defines_build ${defines_for_build_name} )
    List( APPEND defines ${defines_build} )

    # Add the "-D" prefix to all of them
    ForEach( item ${defines} )
      List( APPEND all_define_flags "-D${item}" )
    EndForEach()

    List( APPEND compile_flags ${all_define_flags} ) 

    # Prepare the compile flags var for passing to GCC
    Separate_Arguments( compile_flags )

    # Finally, build the precompiled header.
    # We don't add the buil command to add_custom_target
    # because that would force a PCH rebuild even when
    # the ${header_name}.h file hasn't changed. We add it to
    # a special add_custom_command to work around this problem.        

    Get_Filename_Component (header_basename ${PCH_HEADER} NAME)
    Set (output_gch_file ${CMAKE_CURRENT_BINARY_DIR}/${header_basename}.gch)

    Add_Custom_Target( ${PCH_TARGET_NAME} ALL
      DEPENDS ${output_gch_file}
      )

    Add_Custom_Command( OUTPUT ${output_gch_file} 
      COMMAND ${CMAKE_CXX_COMPILER} ${compile_flags} ${PCH_HEADER} -o ${output_gch_file}
      MAIN_DEPENDENCY ${PCH_HEADER}
      )
  EndIf() 
EndMacro()
