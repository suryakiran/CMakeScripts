Include (${CMAKE_MODULE_PATH}/Xerces.cmake)

Find_Libraries (
  ZORBA
  EXECUTABLE zorba
  HEADER xqc.h
  LIBRARIES zorba_simplestore
  )