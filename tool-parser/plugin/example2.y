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

%token T1

%type<int_pointer> regla

%start S

%%

S: regla {}

regla: T1 {}

%%

#include "bison-epilogue.h"
