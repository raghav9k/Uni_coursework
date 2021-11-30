#pragma once

#include <array>

static constexpr std::array<char const*, 7> ExpectedFiles
{
    "H:/CSC305/a2/build/_deps/atlas-src/test/expected/glx_single_line.expected",
    "H:/CSC305/a2/build/_deps/atlas-src/test/expected/glx_simple_file.expected",
    "H:/CSC305/a2/build/_deps/atlas-src/test/expected/glx_simple_file_comments.expected",
    "H:/CSC305/a2/build/_deps/atlas-src/test/expected/glx_single_include.expected",
    "H:/CSC305/a2/build/_deps/atlas-src/test/expected/glx_multiple_includes.expected",
    "H:/CSC305/a2/build/_deps/atlas-src/test/expected/glx_nested_include.expected",
    "H:/CSC305/a2/build/_deps/atlas-src/test/expected/glx_circular_include.expected"
};

enum ExpectedFileNames
{
    glx_single_line_expected = 0,
    glx_simple_file_expected,
    glx_simple_file_comments_expected,
    glx_single_include_expected,
    glx_multiple_includes_expected,
    glx_nested_include_expected,
    glx_circular_include_expected
};
