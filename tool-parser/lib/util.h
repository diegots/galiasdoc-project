#ifndef UTIL_H
#define UTIL_H

#include <stdio.h>
#include "lista.h"

/* Lee el contenido completo de un fichero a un array de char. La memoria
 * devuelta por esta función ha de ser liberada por el llamador la misma */
char * read_file(char *filename);
char * read_fp(FILE *fp);

/* Elimina de un string cualquier número de ocurrencias de un determinado caracter */
void remove_char(char *str, char useless);

/*
 * Reemplaza toda ocurrencia de orig con repl. Devuelve el número de caracteres cambiados.
 */
int replace_char(char *str, char orig, char repl);

/* Realiza trim de una cadena */
char * left_trim(char * str);
char * right_trim(char * str);
char * trim(char * str);

/* Aplana una lista de strings */
char *flatten_strings(lista values);

/*
 * Detecta si la cadena de entrada contiene un número en formato
 * "1.234,56" y lo convierte a "1234.56"
 */
void fix_string_float(char *float_);

#endif
