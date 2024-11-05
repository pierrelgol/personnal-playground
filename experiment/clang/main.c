#include <execinfo.h>
#include <stdint.h>
#include <stdio.h>

struct Foo {
                char *name;
                int   age;

                struct Bar {
                                char *street;
                                char *address;
                                int   number;

                } address;

                float love_for_cpp;
};

int main() {

        struct Foo pierre = (struct Foo){
            .name = "Pierre",
            .age  = 24,
            .address =
                (struct Bar){
                             .street  = "fondary",
                             .address = "75015",
                             .number  = 64,

                             },
            .love_for_cpp = 0.42,
        };


        __builtin_dump_struct(&pierre, printf);




        // printf("__BASE_FILE__          = %s\n", __BASE_FILE__);
        // printf("__FILE_NAME__          = %s\n", __FILE_NAME__);
        // printf("__COUNTER__            = %d\n", __COUNTER__);
        // printf("__TIMESTAMP__          = %s\n", __TIMESTAMP__);
        // printf("__INCLUDE_LEVEL__      = %d\n", __INCLUDE_LEVEL__);
        // printf("__clang__              = %d\n", __clang__);
        // printf("__clang_major__        = %d\n", __clang_major__);
        // printf("__clang_minor__        = %d\n", __clang_minor__);
        // printf("__clang_patchlevel__   = %d\n", __clang_patchlevel__);
        // printf("__clang_version__      = %s\n", __clang_version__);

        // char* ptr = __builtin_alloca(10);
        // (void)ptr;

        //         // int i = 5;

        //         // __builtin_assume(i == 5);
        //         // if ((i > 5)) {
        //         //         (void)i;
        //         // } else {
        //         //         (void)i;
        //         // }

        //         unsigned long long t0 = __builtin_readcyclecounter();
        //         // do_something();
        //         unsigned long long t1                     = __builtin_readcyclecounter();
        //         unsigned long long cycles_to_do_something = t1 - t0; // assuming no overflow

        //         printf("cycles_to_do_something  = %llu\n", cycles_to_do_something);

        // #if __has_builtin(__builtin_readsteadycounter)
        //         t0 = __builtin_readsteadycounter();
        //         do_something();
        //         t1                                      = __builtin_readsteadycounter();
        //         unsigned long long secs_to_do_something = (t1 - t0) / 1000;
        //         printf("secs_to_do_something = %llu\n", secs_to_do_something);
        // #endif

        //         uint8_t  a = 1;
        //         uint16_t b = 2;
        //         uint32_t c = 3;
        //         uint64_t d = 4;

        //         uint8_t  rev_a = __builtin_bitreverse8(a);
        //         uint16_t rev_b = __builtin_bitreverse16(b);
        //         uint32_t rev_c = __builtin_bitreverse32(c);
        //         uint64_t rev_d = __builtin_bitreverse64(d);

        //         printf("a = %u, rev_a = %u\n", a, rev_a);
        //         printf("b = %u, rev_b = %u\n", b, rev_b);
        //         printf("c = %u, rev_c = %u\n", c, rev_c);
        //         printf("d = %lu, rev_d = %lu\n", d, rev_d);
        //         int i;


        // int j = i;
        // printf("i = %d\n", j);

        // return (0);

        return (0);
}

//
// typedef float m4x4_t __attribute__((matrix_type(4, 4)));

// void explode(void) __attribute__((deprecated("function is deprecated")));

// void do_something() {
//         printf("hi\n");
// }


// void foo(int* p) {
//         if (p == NULL) {
//                 __builtin_debugtrap();
//         }
// }
