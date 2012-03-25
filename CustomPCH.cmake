
# DON'T FORGET to include ${CMAKE_CURRENT_SOURCE_DIR} in include_directories for the compiler
# to see the header, and ${CMAKE_CURRENT_BINARY_DIR} for the compiler to see the GCC PCH 

# "sources" - unexpanded cmake variable holding all the source files
# "includes" - unexpanded cmake variable holding all include paths the PCH needs to know about
# "target_name" - the name of the a special target used to build the PCH for GCC
# "header_name" - the name of the PCH header, without the extension; "stdafx" or something similar;
#                  note that the source file compiling the header needs to have the same name 

Macro(PRECOMPILED_HEADER sources includes target_name header_name)

  # MSVC precompiled headers cmake code
  If ( MSVC )
    Set_Source_Files_Properties( ${header_name}.cpp PROPERTIES COMPILE_FLAGS "/Yc${header_name}.h" )

    ForEach( src_file ${${sources}} )
      If( ${src_file} MATCHES ".*cpp$" )
        set_source_files_properties( ${src_file} PROPERTIES COMPILE_FLAGS "/Yu${header_name}.h" )
      EndIf()
    EndForEach()

    # ${header_name}.cpp has to come before ${header_name}.h, 
    # otherwise we get a linker error...
    List( INSERT ${sources} 0 ${header_name}.h )
    List( INSERT ${sources} 0 ${header_name}.cpp )

    # GCC precompiled headers cmake code
    # We don't do this on Macs since GCC there goes haywire
    # when you try to generate a PCH with two "-arch" flags
  ElseIf( CMAKE_COMPILER_IS_GNUCXX AND NOT APPLE )

    # Get the compiler flags for this build type
    String( TOUPPER "CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}" flags_for_build_name )
    Set( compile_flags ${${flags_for_build_name}} )

    # Add all the Qt include directories
    ForEach( item ${${includes}} )
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

    Get_Filename_Component (header_basename ${header_name} NAME)
    Set (output_gch_file ${CMAKE_CURRENT_BINARY_DIR}/${header_basename}.gch)

    Add_Custom_Target( ${target_name} ALL
      DEPENDS ${output_gch_file}
      )

    Add_Custom_Command( OUTPUT ${output_gch_file} 
      COMMAND ${CMAKE_CXX_COMPILER} ${compile_flags} ${header_name} -o ${output_gch_file}
      MAIN_DEPENDENCY ${header_name}
      )
  EndIf() 
EndMacro()
