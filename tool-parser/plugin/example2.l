%{
#include "example2.tab.h"
#include "flex-prologue.h"
%}

%option noyywrap
%option nounput
%option noinput

%%

"T1" {return T1;}

%%
