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
