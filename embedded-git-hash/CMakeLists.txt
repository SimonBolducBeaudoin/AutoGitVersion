cmake_minimum_required(VERSION 3.11)
project(git-hash)

include(../cmake/CheckGit.cmake)
CheckGitSetup()

add_executable(main main.cpp)
target_link_libraries(main git_version)
