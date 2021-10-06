%{
#include "bison-prologue.h"
%}

%code requires {

}

%define parse.error verbose

%code provides {

}

%union {
    int * int_pointer;
}

%token T2

%type<int_pointer> regla

%start S

%%

S: regla {}

regla: T2 {}

%%

#include "bison-epilogue.h"
