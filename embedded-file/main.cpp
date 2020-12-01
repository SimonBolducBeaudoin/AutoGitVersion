#include "message_txt.h"
#include <iostream>

int main()
{
    for(unsigned i = 0;i < message_txt_size;i++)
    {
        std::cout << message_txt_data[i];
    }
    std::cout << "\n";
}
