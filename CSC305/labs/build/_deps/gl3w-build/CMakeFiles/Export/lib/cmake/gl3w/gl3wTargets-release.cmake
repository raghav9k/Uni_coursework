#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "gl3w::gl3w" for configuration "Release"
set_property(TARGET gl3w::gl3w APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(gl3w::gl3w PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/gl3w.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS gl3w::gl3w )
list(APPEND _IMPORT_CHECK_FILES_FOR_gl3w::gl3w "${_IMPORT_PREFIX}/lib/gl3w.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
