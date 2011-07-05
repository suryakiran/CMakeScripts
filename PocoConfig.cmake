# - Find the Poco includes and libraries.
# The following variables are set if Poco is found.  If Poco is not
# found, Poco_FOUND is set to false.
#  Poco_FOUND        - True when the Poco include directory is found.
#  Poco_INCLUDE_DIRS - the path to where the poco include files are.
#  Poco_LIBRARY_DIRS - The path to where the poco library files are.
#  Poco_BINARY_DIRS - The path to where the poco dlls are.

# ----------------------------------------------------------------------------
# If you have installed Poco in a non-standard location.
# Then you have three options. 
# In the following comments, it is assumed that <Your Path>
# points to the root directory of the include directory of Poco. e.g
# If you have put poco in C:\development\Poco then <Your Path> is
# "C:/development/Poco" and in this directory there will be two
# directories called "include" and "lib".
# 1) After CMake runs, set Poco_INCLUDE_DIR to <Your Path>/poco<-version>
# 2) Use CMAKE_INCLUDE_PATH to set a path to <Your Path>/poco<-version>. This will allow FIND_PATH()
#    to locate Poco_INCLUDE_DIR by utilizing the PATH_SUFFIXES option. e.g.
#    SET(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} "<Your Path>/include")
# 3) Set an environment variable called ${POCO_ROOT} that points to the root of where you have
#    installed Poco, e.g. <Your Path>. It is assumed that there is at least a subdirectory called
#    Foundation/include/Poco in this path.
#
# Note:
#  1) If you are just using the poco headers, then you do not need to use
#     Poco_LIBRARY_DIRS in your CMakeLists.txt file.
#  2) If Poco has not been installed, then when setting Poco_LIBRARY_DIRS
#     the script will look for /lib first and, if this fails, then for /stage/lib.
#
# Usage:
# In your CMakeLists.txt file do something like this:
# ...
# # Poco
# FIND_PACKAGE(Poco)
# ...
# INCLUDE_DIRECTORIES(${Poco_INCLUDE_DIRS})
# LINK_DIRECTORIES(${Poco_LIBRARY_DIRS})
#
# In Windows, we make the assumption that, if the Poco files are installed, the default directory
# will be C:\poco or C:\Program Files\Poco.

SET(POCO_INCLUDE_PATH_DESCRIPTION "top-level directory containing the poco include directories. E.g /usr/local/include/poco-1.2.1 or c:\\poco\\include\\poco-1.2.1")
SET(POCO_INCLUDE_DIR_MESSAGE "Set the Poco_INCLUDE_DIR cmake cache entry to the ${POCO_INCLUDE_PATH_DESCRIPTION}")
SET(POCO_LIBRARY_PATH_DESCRIPTION "top-level directory containing the poco libraries.")
SET(POCO_LIBRARY_DIR_MESSAGE "Set the Poco_LIBRARY_DIR cmake cache entry to the ${POCO_LIBRARY_PATH_DESCRIPTION}")


SET(POCO_DIR_SEARCH $ENV{POCO_ROOT})
IF(POCO_DIR_SEARCH)
  FILE(TO_CMAKE_PATH ${POCO_DIR_SEARCH} POCO_DIR_SEARCH)
ENDIF(POCO_DIR_SEARCH)


# Add in some path suffixes. These will have to be updated whenever a new Poco version comes out.
SET(SUFFIX_FOR_LIBRARY_PATH
  lib
  )

SET(Poco_FOUND 0)

#
# Look for an installation.
#
FIND_PATH(Poco_INCLUDE_DIR Poco/Foundation.h PATH_SUFFIXES include PATHS

  # Look in other places.
  ${POCO_DIR_SEARCH}

  # Help the user find it if we cannot.
  DOC "The ${POCO_INCLUDE_DIR_MESSAGE}"
)

If (Poco_INCLUDE_DIR) 
  Set (Poco_FOUND 1)
EndIf (Poco_INCLUDE_DIR)

Set (POCO_MODULES
  Foundation
  Util
  XML
  Net
  NetSSL
  Zip
  Data
  DataSQLite
  )

Set(CmakeFindLibrarySuffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})

Set (lib_dirs)
Set (lib_dirs_debug)

ForEach (module ${POCO_MODULES})
  If (UNIX)
    Set (CMAKE_FIND_LIBRARY_SUFFIXES ${CmakeFindLibrarySuffixes})
  EndIf(UNIX)

  Set (LibName Poco_${module}_LIBRARY)
  Set (lib lib-NOTFOUND)
  Set (lib_debug lib_debug-NOTFOUND)

  Find_Library (lib Poco${module} PATH_SUFFIXES lib PATHS ${POCO_DIR_SEARCH})
  Find_Library (lib_debug Poco${module}d PATH_SUFFIXES lib PATHS ${POCO_DIR_SEARCH})

  Get_Filename_Component (lib_dir ${lib} PATH)
  Get_Filename_Component (lib_dir_debug ${lib_debug} PATH)

  List (APPEND lib_dirs ${lib_dir})
  List (APPEND lib_dirs_debug ${lib_dir_debug})

  Set (LibMessage "Poco ${module} Library")

  If (lib AND lib_debug)
    Set (${LibName} optimized ${lib} debug ${lib_debug} CACHE STRING ${LibMessage})
  ElseIf (lib)
    Set (${LibName} ${lib} CACHE STRING ${LibMessage})
  ElseIf (lib_debug)
    Set (${LibName} ${lib_debug} CACHE STRING ${LibMessage})
  EndIf (lib AND lib_debug)

  If(UNIX)
    Set (CMAKE_FIND_LIBRARY_SUFFIXES .a)
  EndIf(UNIX)

  Find_Library (lib NAMES Poco${module} Poco${module}mt PATH_SUFFIXES lib PATHS ${POCO_DIR_SEARCH})
  Find_Library (lib_debug Poco${module}d Poco${module}mtd PATH_SUFFIXES lib PATHS ${POCO_DIR_SEARCH})

  Set (LibMessage "Poco ${module} Static Library")

  If (lib AND lib_debug)
    Set (${LibName}_STATIC optimized ${lib} debug ${lib_debug} CACHE STRING ${LibMessage})
  ElseIf (lib)
    Set (${LibName}_STATIC ${lib} CACHE STRING ${LibMessage})
  ElseIf (lib_debug)
    Set (${LibName}_STATIC ${lib_debug} CACHE STRING ${LibMessage})
  EndIf (lib AND lib_debug)

  Get_Filename_Component (lib_dir ${lib} PATH)
  Get_Filename_Component (lib_dir_debug ${lib_debug} PATH)

  List (APPEND lib_dirs ${lib_dir})
  List (APPEND lib_dirs_debug ${lib_dir_debug})

  Set (lib lib-NOTFOUND)
  Set (lib_debug lib_debug-NOTFOUND)
EndForEach (module)

Set (CMAKE_FIND_LIBRARY_SUFFIXES ${CmakeFindLibrarySuffixes})

List (REMOVE_DUPLICATES lib_dirs)
List (REMOVE_DUPLICATES lib_dirs_debug)

Set (Poco_LIBRARY_DIRS ${lib_dirs})
Set (Poco_LIBRARY_DIRS_DEBUG ${lib_dirs_debug})

Find_Program (Poco_BINARIES NAMES cpspc f2cpsp PATHS ${POCO_DIR_SEARCH}
  PATH_SUFFIXES bin)

If (Poco_BINARIES)
  Get_Filename_Component (Poco_BINARY_DIR ${Poco_BINARIES} PATH)
EndIf (Poco_BINARIES)

IF(NOT Poco_FOUND)
  IF(NOT Poco_FIND_QUIETLY)
    MESSAGE(STATUS "Poco was not found. ${POCO_DIR_MESSAGE}")
  ELSE(NOT Poco_FIND_QUIETLY)
    IF(Poco_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Poco was not found. ${POCO_DIR_MESSAGE}")
    ENDIF(Poco_FIND_REQUIRED)
  ENDIF(NOT Poco_FIND_QUIETLY)
ENDIF(NOT Poco_FOUND)

