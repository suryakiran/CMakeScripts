Find_Libraries (
  POPPLER
  LIBRARIES poppler
  )

Find_Libraries (
  POPPLER_CPP
  HEADER poppler/cpp/poppler-version.h
  LIBRARIES poppler-cpp
  )

Find_Libraries (
  POPPLER_QT
  HEADER poppler/qt4/poppler-qt4.h
  LIBRARIES poppler-qt4
  )
