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

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

#include "reg-exp.h"

#include "util.h"

char * read_file(char *filename) {
    FILE *fp;
    char *ret = "";

    if( access( filename, F_OK ) != -1 ) {
        if (NULL == (fp = fopen(filename, "r"))) {
            fprintf (stderr, "No se ha podido abrir '%s' para lectura\n",
                    filename);
            exit(EXIT_FAILURE);
        }

        ret = read_fp(fp);
        fclose(fp);
    }

    return ret;
}

char * read_fp(FILE *fp) {
    long tamano;
    char *ret;

    fseek(fp, 0, SEEK_END);
    tamano = ftell(fp);
    rewind(fp);

    ret = malloc((tamano + 1) * sizeof(char));
    if (NULL == ret) {
        perror("read_fp");
        exit(EXIT_FAILURE);
    }

    if (tamano != fread(ret, sizeof(char), tamano, fp)) {
        perror("read_fp");
        exit(EXIT_FAILURE);
    }

    ret[tamano] = '\0';

    return ret;
}

void remove_char(char *str, char useless) {

    char *src, *dst;
    for (src = dst = str; *src != '\0'; src++) {
        *dst = *src;
        if (*dst != useless) dst++;
    }
    *dst = '\0';
}

int replace_char(char *str, char orig, char repl) {
    char *ix = str;
    int n = 0;
    while((ix = strchr(ix, orig)) != NULL) {
        *ix++ = repl;
        n++;
    }
    return n;
}

/* Elimina los espacios en blanco de la parte izquierda de un string */
char * left_trim(char * str) {

    unsigned char c;
    do {
        c = str[0];
        str++;
        //c = str[0];

    } while(isspace(c));

    char *r = str;
    return --r;
}

/* Elimina los espacios en blanco de la parte derecha de un string */
char * right_trim(char * str) {

    /* Si la cadena de entrada es vacía no se hace nada */
    if (strlen(str) <= 0)
        return str;

    char * back = str + strlen(str);

    unsigned char c;
    do {
        c = *--back;
    } while(isspace(c));

    *(back+1) = '\0';

    return str;
}

/* Elimina los espacios en blanco a ambos lados de un string */
char * trim(char * str) {
    return right_trim(left_trim(str));
}

char *flatten_strings(lista values) {
    return "flatten_strings not implemented";
}

void fix_string_float(char *float_) {

    char *reg_expr_float_number = "^[0-9.,-]+$";
    char thousands_separator = '.';

    void *re = get_compiled_pattern(reg_expr_float_number);
    bool was_found = false;
    reg_exp_find(re, float_, &was_found);
    if(was_found) {
        remove_char(float_, thousands_separator);
        replace_char(float_, ',', '.');
    }
}
