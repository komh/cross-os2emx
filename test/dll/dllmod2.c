#include <stdio.h>

__declspec(dllexport)
int hello2( int i )
{
    printf("This is hello2(%d)\n", i);

    return i;
}
