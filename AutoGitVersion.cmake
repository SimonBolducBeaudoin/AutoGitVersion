set(CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
if (NOT DEFINED pre_configure_dir)
    set(pre_configure_dir ${CMAKE_CURRENT_LIST_DIR})
endif ()

if (NOT DEFINED post_configure_dir)
    set(post_configure_dir ${CMAKE_BINARY_DIR}/generated)
endif ()

set(pre_configure_file ${pre_configure_dir}/git_version.cpp.in)
set(post_configure_file ${post_configure_dir}/git_version.cpp)

function(GetGitCache git_tag git_hash)
    if (EXISTS ${CMAKE_BINARY_DIR}/git-state.txt)
        file(STRINGS ${CMAKE_BINARY_DIR}/git-state.txt CONTENT)
        list(GET CONTENT 0 tag_line)
        list(GET CONTENT 1 hash_line)
        set(${git_tag} ${tag_line} PARENT_SCOPE)
        set(${git_hash} ${hash_line} PARENT_SCOPE)
    endif ()
endfunction()


function(GetGitHash git_hash)
    # Get the latest abbreviated commit hash of the working branch
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE GIT_ERROR
        )
    if (GIT_ERROR)
        message(WARNING "Git error: ${GIT_ERROR}")
        set(GIT_HASH "0")
    endif()
    set(${git_hash} ${GIT_HASH}  PARENT_SCOPE)
endfunction()

function(GetGitTag git_tag)
# Returns the last git tag into the git_tag variable
    # Get the latest version tag
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_VERSION_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE GIT_ERROR
    )
    
    # Check if there was an error in running the Git command
    if (GIT_ERROR)
        message(WARNING "Git error: ${GIT_ERROR}")
        set(GIT_VERSION_TAG "0.0.0")
    endif()
    
    set(${git_tag} ${GIT_VERSION_TAG}  PARENT_SCOPE)
endfunction()

function(WriteGitCache git_tag git_hash)
    file(WRITE ${CMAKE_BINARY_DIR}/git-state.txt "${git_tag}\n${git_hash}")
endfunction()

function(UpdateGitCache)  
    GetGitTag(GIT_TAG)
    GetGitHash(GIT_HASH)
    GetGitCache(GIT_TAG_CACHE GIT_HASH_CACHE)
    
    if (NOT DEFINED GIT_TAG)
        set(GIT_TAG "0.0.0")
    endif ()
    
    if (NOT DEFINED GIT_TAG_CACHE)
        set(GIT_TAG_CACHE "INVALID_TAG")
    endif ()
    
    if (NOT DEFINED GIT_HASH_CACHE)
        set(GIT_HASH_CACHE "INVALID_HASH")
    endif ()
    
    if (NOT EXISTS ${post_configure_dir})
        file(MAKE_DIRECTORY ${post_configure_dir})
    endif ()

    if (NOT EXISTS ${post_configure_dir}/git_version.h)
        file(COPY ${pre_configure_dir}/git_version.h DESTINATION ${post_configure_dir})
    endif()
    
    if (NOT ${GIT_HASH} STREQUAL "${GIT_HASH_CACHE}" )
        message(${GIT_HASH})
    endif()
    
    # Only update the git_version.cpp if the hash or tag has changed.
    # This will prevent unnecessary project rebuilding.
    if (NOT (${GIT_HASH} STREQUAL ${GIT_HASH_CACHE} AND ${GIT_TAG} STREQUAL ${GIT_TAG_CACHE}) OR NOT EXISTS ${post_configure_file})
        WriteGitCache(${GIT_TAG} ${GIT_HASH})
        configure_file(${pre_configure_file} ${post_configure_file} @ONLY)
    endif()
endfunction()

function(AutoGitVersion)

    add_custom_target(AlwaysCheckGit COMMAND ${CMAKE_COMMAND}
        -DRUN_UPDATE_GIT_CACHE=1
        -Dpre_configure_dir=${pre_configure_dir}
        -Dpost_configure_file=${post_configure_dir}
        -DGIT_HASH_CACHE=${GIT_HASH_CACHE}
        -P ${CURRENT_LIST_DIR}/CheckGit.cmake
        BYPRODUCTS ${post_configure_file}
        )

    add_library(git_version ${CMAKE_BINARY_DIR}/generated/git_version.cpp)
    target_include_directories(git_version PUBLIC ${CMAKE_BINARY_DIR}/generated)
    add_dependencies(git_version AlwaysCheckGit)

    UpdateGitCache()
endfunction()


# This is used to run this function from an external cmake process.
if (RUN_UPDATE_GIT_CACHE)
    UpdateGitCache()
endif ()
