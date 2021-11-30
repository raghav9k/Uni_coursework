#pragma once

#include <array>

static constexpr std::array<char const*, 13> TestData
{
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_empty_file.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_single_line.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_simple_file.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_simple_file_comments.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_single_include.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_multiple_includes.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_nested_include.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/glx_circular_include.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/nested_include.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/uniform_bindings.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/uniform_matrices.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/circular_include_a.glsl",
    "H:/CSC305/labs/build/_deps/atlas-src/test/data/circular_include_b.glsl"
};

enum TestDataNames
{
    glx_empty_file = 0,
    glx_single_line,
    glx_simple_file,
    glx_simple_file_comments,
    glx_single_include,
    glx_multiple_includes,
    glx_nested_include,
    glx_circular_include,
    nested_include,
    uniform_bindings,
    uniform_matrices,
    circular_include_a,
    circular_include_b
};
