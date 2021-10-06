%{
#include "example1.tab.h"
#include "flex-prologue.h"
%}

%option noyywrap
%option nounput
%option noinput

%%

"T2" {return T2;}

%%
