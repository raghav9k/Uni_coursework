cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(gl3w VERSION 1.0.0 LANGUAGES CXX C)

set(SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/src")
set(HEADER_DIR"${CMAKE_CURRENT_BINARY_DIR}/include")

# Set the source and header files.
set(HEADER_FILES
	"${HEADER_DIR}/GL/gl3w.h"
	"${HEADER_DIR}/GL/glcorearb.h"
	"${HEADER_DIR}/KHR/khrplatform.h"
)

set(SOURCE_FILES
	"${SOURCE_DIR}/gl3w.c"
)

find_package(OpenGL REQUIRED)
find_package(PythonInterp REQUIRED)

# Add a custom command that runs python and generates the files.
add_custom_command(
	OUTPUT
		"${SOURCE_DIR}/gl3w.c"
		"${HEADER_DIR}/GL/gl3w.h"
		"${HEADER_DIR}/GL/glcorearb.h"
		"${HEADER_DIR}/KHR/khrplatform.h"
	COMMAND "${PYTHON_EXECUTABLE}" ${CMAKE_CURRENT_SOURCE_DIR}/gl3w_gen.py
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/gl3w_gen.py
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# Add a phony target that depends on the generated files.
add_custom_target(
	gl3w_gen ALL
	DEPENDS
		"${SOURCE_DIR}/gl3w.c"
		"${HEADER_DIR}/GL/gl3w.h"
		"${HEADER_DIR}/GL/glcorearb.h"
		"${HEADER_DIR}/KHR/khrplatform.h"
)

# Now create the gl3w target
add_library(gl3w ${SOURCE_FILES} ${HEADER_FILES})
target_include_directories(gl3w PUBLIC
    $<INSTALL_INTERFACE:include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
    )
target_compile_features(gl3w PUBLIC cxx_std_17)
target_link_libraries(gl3w PUBLIC OpenGL::GL)
add_library(gl3w::gl3w ALIAS gl3w)

# Now make gl3w depend on the generator target
add_dependencies(gl3w gl3w_gen)

# Now lets add the install commands.
install(TARGETS gl3w
    EXPORT gl3w
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION lib
    INCLUDES DESTINATION include
    )

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
write_basic_package_version_file(
    gl3wConfigVersion.cmake
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY AnyNewerVersion
    )

install(EXPORT gl3w
    FILE gl3wTargets.cmake
    NAMESPACE gl3w::
    DESTINATION lib/cmake/gl3w
    )

install(FILES 
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/gl3w-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/gl3wConfigVersion.cmake"
    DESTINATION lib/cmake/gl3w
    )

install(DIRECTORY
    "${CMAKE_CURRENT_BINARY_DIR}/include/"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
