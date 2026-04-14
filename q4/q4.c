#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main(){
    char op[6];
    int a , b;

    while(scanf("%5s %d %d" , op , &a , &b) == 3){
        char libname[20];
        snprintf(libname , sizeof(libname) , "./lib%s.so" , op);
        void *handle = dlopen(libname , RTLD_LAZY);
        int(*func)(int , int);
        *(void **)(&func) = dlsym(handle, op);
        int result = func(a, b);
        printf("%d\n", result);
        dlclose(handle);
    }
}
