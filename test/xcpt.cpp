#include <iostream>
using namespace std;
int main() {
    try {
        throw "Throw exception!";
    }
    catch( char const *s ) {
        cout << "Catched exception = " << s << endl;
    }

    return 0;
}

