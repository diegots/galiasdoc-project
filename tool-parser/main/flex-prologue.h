#ifndef FLEX_PROLOGUE_H
#define FLEX_PROLOGUE_H

#include "types.h"

#ifndef DEBUG_LEXER
#define PRINTF(f_, ...)
#else
#define PRINTF(f_, ...) printf((f_), ##__VA_ARGS__)
#endif

word_value *split_id_value(char *contents);

#endif
