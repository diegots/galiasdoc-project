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

#ifndef REGION_H
#define REGION_H

#include "lista.h"

/*
 * word_value es un struct que contiene la información de una palabra.
 *     - 'value' es el contenido o texto de la palabra.
 *     - 'w_id_string' es el id de la palabra en formato char *.
 *     - 'w_id_numeric' es el id de la palabra en formato int.
 */
typedef struct word {
    char *value;
    char *w_id_string;
    int w_id_numeric;
    char *w_page_number_string;
    int w_page_number_numeric;
} word_value;

typedef struct content_pair {
    char *header;
    lista words; /* word_value */
} content_pair;

typedef lista cols;

/*
 * Almacena las tablas completas para la generación de CSV.
 */
typedef struct table {
    lista col_titles;
    lista rows;
} table;

typedef struct region {
    enum {
        R_R1,
        R_R2,
        R_R3,
        R_T1,
        R_T2
    } type;
    union {
        lista r1;
        lista r2;
        lista r3;
        table t1;
        table t2;
	};
} region;

/*
 * Struct para almacenar los importe de las tablas T1, T2.
 * Permite hacer comprobaciones posteriores con los datos
 */
typedef struct amounts {
    lista singles; /* lista<word_value> - importes individuales */
    word_value *base; /* importe total sin iva */
    word_value *iva_tax; /* importe del iva */
} amounts;

/*
 * Lista de importes individuales y total de dichos valores
 */
typedef struct table_amount {
    lista singles; /* lista<word_value> - importes individuales */
    // En caso de que la tabla contenga un resumen al pie, se indica con valor WITH
    enum {
        WITH,
        WITHOUT
    } subtotal_type;
    word_value *subtotal; /* subtotal de los valores individuales */
} table_amount;

/*
 * Almacena los importes de los documento
 */
typedef struct table_amounts {
    lista *tables; /* list<table_amount> */
    word_value *base; /* importe neto de la factura */
    word_value *iva_tax; /* importe del iva */
    word_value *total; /* importe total */
} table_amounts;

#endif
