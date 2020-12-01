cmake_minimum_required(VERSION 3.11)
project(file-embed)

add_executable(main main.cpp)

include(../cmake/FileEmbed.cmake)
FileEmbedSetup()
FileEmbedAdd(${CMAKE_SOURCE_DIR}/message.txt)

target_link_libraries(main file_embed)
