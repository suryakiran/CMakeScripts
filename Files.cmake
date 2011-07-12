Find_File (
  CMAKE_DLL_H_IN_FILE
    Dll.h.in
  PATHS
    ${CMAKE_MODULE_PATH}/Configure
  )

Find_File (
  VCPROJ_ENV_IN_FILE
    vcproj.env.in
  PATHS
    ${CMAKE_MODULE_PATH}/Configure
  )

Find_File (
  VCPROJ_USER_IN_FILE
    vcproj.user.in
  PATHS 
    ${CMAKE_MODULE_PATH}/Configure
  )

Set (USER_OUT_FILE @TargetName@.vcproj.@MACHINE_NAME@.$ENV{USERNAME}.user)

Mark_As_Advanced (
  CMAKE_DLL_H_IN_FILE
  VCPROJ_ENV_IN_FILE
  VCPROJ_USER_IN_FILE
  )
