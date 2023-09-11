set(CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
if (NOT DEFINED pre_configure_dir)
    set(pre_configure_dir ${CMAKE_CURRENT_LIST_DIR})
endif ()

if (NOT DEFINED post_configure_dir)
    set(post_configure_dir ${CMAKE_BINARY_DIR}/generated)
endif ()

if (NOT DEFINED WORKING_DIR)
    set(WORKING_DIR ${CMAKE_CURRENT_SOURCE_DIR})
endif ()

set(pre_configure_file ${pre_configure_dir}/git_version.cpp.in)
set(post_configure_file ${post_configure_dir}/git_version.cpp)

function(GetGitCache git_info)
    if (EXISTS ${CMAKE_BINARY_DIR}/git-state.txt)
        file(READ ${CMAKE_BINARY_DIR}/git-state.txt CONTENT)
        set(${git_info} ${CONTENT} PARENT_SCOPE)
    endif()
endfunction()

function(GetGitInfo git_info)

    # Get the abbreviated commit hash
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT_VARIABLE GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE GIT_ERROR
    )

    # Get the author's name
    execute_process(
        COMMAND git log -1 --format=%an
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT_VARIABLE GIT_AUTHOR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the commit date
    execute_process(
        COMMAND git log -1 --format=%ad --date=iso
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT_VARIABLE GIT_DATE
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the commit #message
    execute_process(
        COMMAND git log -1 --format=%s
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT_VARIABLE GIT_#message
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the current branch name
    execute_process(
        COMMAND git symbolic-ref --short HEAD
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the repository URL
    execute_process(
        COMMAND git remote get-url origin
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT_VARIABLE GIT_URL
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the latest tag or set to "0.0.0" if no tag exists
    execute_process(
        COMMAND git describe --tags --abbrev=0
        WORKING_DIRECTORY ${WORKING_DIR}
        OUTPUT_VARIABLE GIT_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if (GIT_TAG STREQUAL "")
        set(GIT_TAG "0.0.0")
    endif()
        
    # Create a dictionary to hold the Git information
    set(${git_info}
        "\\n\\tHash: ${GIT_HASH}\\n\\tAuthor: ${GIT_AUTHOR}\\n\\tDate: ${GIT_DATE}\\n\\tmessage: ${GIT_message}\\n\\tBranch: ${GIT_BRANCH}\\n\\tURL: ${GIT_URL}\\n\\tTag: ${GIT_TAG}"
        PARENT_SCOPE
    )
endfunction()

function(WriteGitCache git_info)
    file(WRITE ${CMAKE_BINARY_DIR}/git-state.txt "${git_info}")
endfunction()

function(UpdateGitCache)  
    GetGitInfo(GIT_INFO)
    GetGitCache(GIT_INFO_CACHE)
    
    if (NOT DEFINED GIT_INFO_CACHE)
        set(GIT_INFO_CACHE "INVALID_GIT_INFO")
    endif ()
    
    if (NOT EXISTS ${post_configure_dir})
        file(MAKE_DIRECTORY ${post_configure_dir})
    endif ()

    if (NOT EXISTS ${post_configure_dir}/git_version.h)
        file(COPY ${pre_configure_dir}/git_version.h DESTINATION ${post_configure_dir})
    endif()
        
    # Only update the git_version.cpp if the hash or tag has changed.
    # This will prevent unnecessary project rebuilding.
    if (NOT (${GIT_INFO} STREQUAL ${GIT_INFO_CACHE}) OR NOT EXISTS ${post_configure_file})
        WriteGitCache(${GIT_INFO})
        configure_file(${pre_configure_file} ${post_configure_file} @ONLY)
    endif()
endfunction()

function(AutoGitVersion)
   
    add_custom_target(AlwaysCheckGit COMMAND ${CMAKE_COMMAND}
        -DRUN_UPDATE_GIT_CACHE=1
        -Dpre_configure_dir=${pre_configure_dir}
        -Dpost_configure_file=${post_configure_dir}
        -DWORKING_DIR=${WORKING_DIR}
        -DGIT_INFO_CACHE=${GIT_INFO_CACHE}
        -P ${CURRENT_LIST_DIR}/AutoGitVersion.cmake
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
