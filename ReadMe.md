# AutoGitVersion
Saving current git tag and git hash at compile time.

This is bassically a copy of : https://gitlab.com/jhamberg/cmake-examples.git and https://jonathanhamberg.com/post/cmake-embedding-git-hash/  with some slight modifications.

- Adding to your cmake project
    - Clone AutoGitVersion somewhere
    - In CMakeLists.txt (after project declaration)
        include(.../AutoGitVersion.cmake) # Defined cmake functions : AutoGitVersion and others
        AutoGitVersion(GIT_VERSION_TARGET ${PROJECT_NAME})                  # Sets up a target git_version.cpp that contains  kGitInfo; as const
    - GIT_VERSION_TARGET then contains the target name for that module/submodule's git_version
    - You can then link to it 
        add_library(${LIB_NAME} ${SRC_FILES})
        target_link_libraries(${LIB_NAME} ${GIT_VERSION_TARGET} ${LINKS})
    - You will now have the variable const char *kGitInfo available in you C/C++ project.
    - In your C/C++ project #include "git_version_project_name.h"
- Compiling the example 
   - cd example/
   - mkdir build
   - cmake -S . -B ./build
   - cmake --build build/
- Running the example
   - cd build
   - ./main.exe
   - Will print your current tag (default 0.0.0) and hash. 
