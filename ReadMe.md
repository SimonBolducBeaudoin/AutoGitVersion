# AutoGitVerion
Saving current git tag and git hash at compile time.

This is bassically a copy of : https://gitlab.com/jhamberg/cmake-examples.git with some slight modifications.

- Adding to your cmake project
    - Clone AutoGitVersion as a submodule into your project
    - In CMakeLists.txt add

        include(.../AutoGitVersion.cmake) # Defined cmake functions : AutoGitVersion and others
      
        AutoGitVersion()                  # Sets up a target git_version.cpp that contains  kGitHash and GitTag; as const
- Compiling the example 
   - cd example/
   - mkdir build
   - cmake -S . -B ./build
   - cmake --build build/
- Running the example
   - cd build
   - ./main.exe
   - Will print your current tag (default 0.0.0) and hash. 
