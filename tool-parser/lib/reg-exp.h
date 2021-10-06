#ifndef REG_EXP_H
#define REG_EXP_H

#include <stdbool.h>

/*
 * A partir de un patrón, una expresión regular, genera su versión compilada.
 */
void *get_compiled_pattern(char *pattern_);

/*
 * Busca una expresión regular en una cadena
 *
 * re: expresión regular ya compilada
 * subject_: cadena sobre la que se quiere hacer la búsqueda
 * was_found: indica si la expresión fue hallada en la cadena
 */
int reg_exp_find(void *re, char *subject_, bool *was_found);

#endif
