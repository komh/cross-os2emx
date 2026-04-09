#include <stdio.h>

int hello( int i );

#ifdef BUILD_OMF
int hello2( int i );
#endif

int main( void )
{
    int i = 10;
    printf("hello(%d) = %d\n", i, hello( i ));
#ifdef BUILD_OMF
    printf("hello2(%d) = %d\n", i * 2, hello2( i * 2 ));
#endif

    return 0;
}
