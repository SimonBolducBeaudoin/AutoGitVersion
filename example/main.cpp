#include <iostream>
#include "git_version.h"

int main()
{
    std::cout << "Git Tag: " << kGitTag << "\n";
    std::cout << "Git Hash: " << kGitHash << "\n";
    return 0;
}
