/*
 * GaliasDoc: information extraction from PDF sources with common templates
 * Copyright (C) 2021 Diego Trabazo Sardón
 *
 * This file is part of GaliasDoc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>
 */

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
