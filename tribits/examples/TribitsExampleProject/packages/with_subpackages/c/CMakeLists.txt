TRIBITS_SUBPACKAGE(C)

TRIBITS_ADD_EXECUTABLE( c_util
  NOEXEPREFIX  NOEXESUFFIX
  SOURCES  c_util.cpp
  )

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/ShowLibErrors.cmake)

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
TRIBITS_ADD_LIBRARY(pws_c
  SOURCES C.cpp
  HEADERS C.hpp
  ${TAL_EXTRALIB_ARGS} # Used to show warnings and errors
  )

TRIBITS_ADD_TEST_DIRECTORIES(tests)

TRIBITS_SUBPACKAGE_POSTPROCESS()
