cmake_minimum_required(VERSION 3.11)
project(AutoGitVersion)

include(../AutoGitVersion.cmake) # Defined cmake functions : AutoGitVersion and others
AutoGitVersion()           # Sets up a target git_version.cpp that constains  kGitHash and GitTag; as const

add_executable(main main.cpp)
target_link_libraries(main git_version)
