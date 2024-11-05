#include <stidio>
extern void zig_do( void );
extern int add_number( int a, int b );
extern void dump_stack_trace( void );

void print_number( int a, int b ) {
        printf( )
}

void baz( ) {
        dump_stack_trace( );
}

void bar( ) {
        baz( );
}

void foo( ) {
        bar( );
}

int main( int argc, char **argv ) {
        ( void ) argc;
        ( void ) argv;

        zig_do( );
        foo( );
        return ( 0 );
}
