set( AutoGitVersion_DIR  ${CMAKE_CURRENT_LIST_DIR} ) # This files (aka AutoGitVersion.cmake)

function(GetGitInfo git_info module_dir)
    # Get the abbreviated commit hash
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${module_dir}
        OUTPUT_VARIABLE GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE GIT_ERROR
    )

    # Get the author's name
    execute_process(
        COMMAND git log -1 --format=%an
        WORKING_DIRECTORY ${module_dir}
        OUTPUT_VARIABLE GIT_AUTHOR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the commit date
    execute_process(
        COMMAND git log -1 --format=%ad --date=iso
        WORKING_DIRECTORY ${module_dir}
        OUTPUT_VARIABLE GIT_DATE
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the commit #message
    execute_process(
        COMMAND git log -1 --format=%s
        WORKING_DIRECTORY ${module_dir}
        OUTPUT_VARIABLE GIT_#message
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the current branch name
    execute_process(
        COMMAND git symbolic-ref --short HEAD
        WORKING_DIRECTORY ${module_dir}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if ((GIT_BRANCH STREQUAL "") OR (GIT_BRANCH STREQUAL "fatal: ref HEAD is not a symbolic ref"))
        set(GIT_BRANCH "DETACHED HEAD")
    endif()

    # Get the repository URL
    execute_process(
        COMMAND git remote get-url origin
        WORKING_DIRECTORY ${module_dir}
        OUTPUT_VARIABLE GIT_URL
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get the latest tag or set to "0.0.0" if no tag exists
    execute_process(
        COMMAND git describe --tags --abbrev=0
        WORKING_DIRECTORY ${module_dir}
        OUTPUT_VARIABLE GIT_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if ((GIT_TAG STREQUAL ""))
        set(GIT_TAG "0.0.0")
    endif()
        
    # Create a dictionary to hold the Git information
    
    set(${git_info}
        "\\n\\tHash: ${GIT_HASH}\\n\\tAuthor: ${GIT_AUTHOR}\\n\\tDate: ${GIT_DATE}\\n\\tmessage: ${GIT_message}\\n\\tBranch: ${GIT_BRANCH}\\n\\tURL: ${GIT_URL}\\n\\tTag: ${GIT_TAG}"
        PARENT_SCOPE
    )
endfunction()

function(GetGitCache git_info)
    if (EXISTS ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion/git-state.txt)
        file(READ ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion/git-state.txt CONTENT)
        set(${git_info} ${CONTENT} PARENT_SCOPE)
    endif()
endfunction()

function(UpdateGitCache module_dir module_binary_dir)  
    GetGitInfo(GIT_INFO ${module_dir})
    GetGitCache(GIT_INFO_CACHE)
    if (NOT DEFINED GIT_INFO_CACHE)
        set(GIT_INFO_CACHE "INVALID_GIT_INFO")
    endif ()
    if (NOT (${GIT_INFO} STREQUAL ${GIT_INFO_CACHE}) OR NOT EXISTS ${module_binary_dir}/AutoGitVersion/git_version.cpp)
        file(WRITE ${module_binary_dir}/AutoGitVersion/git-state.txt "${GIT_INFO}")
        configure_file(${AutoGitVersion_DIR}/git_version.cpp.in ${module_binary_dir}/AutoGitVersion/git_version.cpp @ONLY)
    endif()
endfunction()

function(AutoGitVersion git_version_target project_name)
    #This function is called in the module or submodule's CMakeLists
    #It sets up a target containt the current git informations 
    #This target gets updated at compile time iif the git hash as changed.
    add_custom_target(AlwaysCheckGit_${project_name} COMMAND ${CMAKE_COMMAND}
    -DRUN_UPDATE_GIT_CACHE=1
    -DGIT_INFO_CACHE="INVALID_GIT_INFO"              # Git as not been called yet
    -DMODULE_DIR=${CMAKE_CURRENT_SOURCE_DIR}         # The module/submodule's build directory
    -DMODULE_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}         # The module/submodule's build directory
    -P ${AutoGitVersion_DIR}/AutoGitVersion.cmake    # This files (aka AutoGitVersion.cmake)
    BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion/git_version.cpp
    )
    
    if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion)
    endif ()
    if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion/git_version.h)
        configure_file(${AutoGitVersion_DIR}/git_version.h ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion/git_version.h COPYONLY)
    endif()
    
    set(GIT_INFO_CACHE "INVALID_GIT_INFO") # Default value
    configure_file(${AutoGitVersion_DIR}/git_version.cpp.in ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion/git_version.cpp @ONLY)
    set(target git_version_${project_name})
    add_library(${target} ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion/git_version.cpp)
    set_target_properties(${target} PROPERTIES OUTPUT_NAME git_version)
    target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/AutoGitVersion)
    add_dependencies(${target} AlwaysCheckGit_${project_name})
    set(${git_version_target} ${target} PARENT_SCOPE)
endfunction()

# This is used to run this function from an external cmake process.
if (RUN_UPDATE_GIT_CACHE)
    UpdateGitCache(${MODULE_DIR} ${MODULE_BINARY_DIR} )
endif ()

