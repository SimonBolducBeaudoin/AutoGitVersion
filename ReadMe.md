# Automatically sets CMAKE_PROJECT_VERSION to the current git tag
# and automatically saves git current git hash into kGitHash const 

# Adding to your cmake project
    - Clone AutoGitVersion as a submodule into your project
    - In CMakeLists.txt add
        include(../CheckGit.cmake) # Defined cmake functions : AutoGitVersion and others
        AutoGitVersion()           # Sets up a target git_version.cpp that contains  kGitHash and GitTag; as const

# Compiling the example 
   - cd example/
   - mkdir build
   - cmake -S . -B ./build
   - cmake --build build/
# Running the example
   - cd build
   - ./main.exe
   - Will print your current tag (default 0.0.0) and hash. 

