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

#include "flex-prologue.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

word_value *split_id_value(char *contents) {

    // printf("contents: %s\n", contents);

    char *page_number = strtok(contents, "·");
    char *id = strtok(NULL, "·");
    char *value = strtok(NULL, "·");

    char *w_page_number_tmp = page_number;
    w_page_number_tmp++;
    char *w_page_number_string = strdup(w_page_number_tmp);
    int w_page_number_numeric = strtol(w_page_number_tmp, NULL, 10);

    char *w_id_tmp = id;
    w_id_tmp++;
    char *w_id_string = strdup(w_id_tmp);
    int w_id_numeric = strtol(w_id_tmp, NULL, 10);

    word_value *word_value = malloc(sizeof *word_value);
    word_value->value = strdup(value);
    word_value->w_id_string = w_id_string;
    word_value->w_id_numeric = w_id_numeric;
    word_value->w_page_number_string = w_page_number_string;
    word_value->w_page_number_numeric = w_page_number_numeric;

    // printf("\tword_value->w_page_number_string: %s\n", word_value->w_page_number_string);
    // printf("\tword_value->w_page_number_numeric: %d\n", word_value->w_page_number_numeric);
    // printf("\tword_value->w_id_string: %s\n", word_value->w_id_string);
    // printf("\tword_value->w_id_numeric: %d\n", word_value->w_id_numeric);
    // printf("\tword_value->value: %s\n", word_value->value);

    return word_value;
}
