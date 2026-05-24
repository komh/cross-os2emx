#include <stdio.h>

int hello( int i );

int hello2( int i );

int main( void )
{
    int i = 10;
    printf("hello(%d) = %d\n", i, hello( i ));
    printf("hello2(%d) = %d\n", i * 2, hello2( i * 2 ));

    return 0;
}
