#----------------------------------------------------------------
# Generated CMake target import file for configuration "MinSizeRel".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "gl3w::gl3w" for configuration "MinSizeRel"
set_property(TARGET gl3w::gl3w APPEND PROPERTY IMPORTED_CONFIGURATIONS MINSIZEREL)
set_target_properties(gl3w::gl3w PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_MINSIZEREL "C"
  IMPORTED_LOCATION_MINSIZEREL "${_IMPORT_PREFIX}/lib/gl3w.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS gl3w::gl3w )
list(APPEND _IMPORT_CHECK_FILES_FOR_gl3w::gl3w "${_IMPORT_PREFIX}/lib/gl3w.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
