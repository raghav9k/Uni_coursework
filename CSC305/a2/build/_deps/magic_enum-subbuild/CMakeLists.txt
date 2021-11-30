# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.15.2)

# We name the project and the target for the ExternalProject_Add() call
# to something that will highlight to the user what we are working on if
# something goes wrong and an error message is produced.

project(magic_enum-populate NONE)

include(ExternalProject)
ExternalProject_Add(magic_enum-populate
                     "UPDATE_DISCONNECTED" "False" "GIT_REPOSITORY" "https://github.com/Neargye/magic_enum" "GIT_TAG" "v0.6.4"
                    SOURCE_DIR          "H:/CSC305/a2/build/_deps/magic_enum-src"
                    BINARY_DIR          "H:/CSC305/a2/build/_deps/magic_enum-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
                    USES_TERMINAL_DOWNLOAD  YES
                    USES_TERMINAL_UPDATE    YES
)
