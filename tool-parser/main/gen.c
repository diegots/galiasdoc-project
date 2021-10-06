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

#include "gen.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "strbuf.h"
#include "cJSON.h"

#define CSV_DELIMITER "·"

/*
 *
 * PROTOTIPOS & DEFINICIONES
 *
 */

typedef void (*handler)(region *, lista *);
void handler_selected_words_r1(region *, lista *);
void handler_selected_words_r2(region *, lista *);
void handler_selected_words_r3(region *, lista *);
void handler_selected_words_t1(region *, lista *);
void handler_selected_words_t2(region *, lista *);

void handler_xml_contents_r1(region *, lista *);
void handler_xml_contents_r2(region *, lista *);
void handler_xml_contents_r3(region *, lista *);
void handler_xml_contents_t1(region *, lista *);
void handler_xml_contents_t2(region *, lista *);

/* Handlers para la generación del contenido */
#define GENERATION_MAP(X) \
    /* Region type, Handlers selected words,   Handlers XML contents */ \
    X(R_R1,         handler_selected_words_r1, handler_xml_contents_r1) \
    X(R_R2,         handler_selected_words_r2, handler_xml_contents_r2) \
    X(R_R3,         handler_selected_words_r3, handler_xml_contents_r3) \
    X(R_T1,         handler_selected_words_t1, handler_xml_contents_t1) \
    X(R_T2,         handler_selected_words_t2, handler_xml_contents_t2)

handler handlers_selected_words[] = {
#define X(op, fa, fb) [op] = fa,
        GENERATION_MAP(X)
#undef X
};

handler handlers_xml_contents[] = {
#define X(op, fa, fb) [op] = fb,
        GENERATION_MAP(X)
#undef X
};

int *int_list_to_array(lista int_list, int array_size);

void get_selected_words(lista regions, lista pages_words);
void start_selected_words(lista regions, handler handler_array[], void *contents);

strbuf get_xml_version(lista regions);
void start_xml_contents(lista regions, handler handler_array[], void *contents);

/*
 *
 * FUNCIONES GENERALES
 *
 */

 /*
  * Genera los ficheros de palabras seleccionadas
  */
 void gen_contents(lista regions, app_config *app_config) {

     // Iniciliza pages_words
     lista *pages_words = malloc(sizeof *pages_words);
     nueva_lista(pages_words);

     lista *l;
     for(int i=0; i<app_config->max_page_number; i++) {
         l = malloc(sizeof *l);
         nueva_lista(l);
         lista_append(pages_words, l);
     }

     // Llama a las funciones de selección
     get_selected_words(regions, *pages_words);

     for(int i=0; i<pages_words->len; i++) {
         lista *ids_list = lista_get(*pages_words, i);
         int *ids_array = int_list_to_array(*ids_list, ids_list->len);

         cJSON *root = cJSON_CreateObject();
         cJSON_AddItemToObject(root, "selected_words", cJSON_CreateIntArray(ids_array, ids_list->len));
         strbuf b = strbufnew();
         b = strbufcat(b, cJSON_Print(root));

         char * fixed_page_number = fix_page_number(app_config->language_file->page, i+1);
         strbuf c = strbufnew();
         c = strbufprintf(c, "%s%s-%s-selected.json",
             app_config->language_file->path,
             app_config->language_file->id,
             fixed_page_number);

         char *file_path = strbuf2str(c);
         write_file_out(file_path, strbuf2str(b));

         free(root);
         free(fixed_page_number);
     }

     strbuf b = get_xml_version(regions);
     strbuf c = strbufnew();
     c = strbufprintf(c, "%s%s-table.csv",
         app_config->language_file->path,
         app_config->language_file->id);
     write_file_out(strbuf2str(c), strbuf2str(b));
}

/*
 * Convierte una lista de enteros en un array de enteros
 */
int *int_list_to_array(lista int_list, int array_size) {

    int *int_array = malloc(array_size * sizeof *int_array);

    for (int i = 0; i < int_list.len; i++) {
        word_value *value = lista_get(int_list, i);
        int_array[i] = value->w_id_numeric;
    }

    return int_array;
}

char *fix_page_number(char *read_page_value, int current_page) {

    if(strcmp("xxx", read_page_value)) {
        return strdup(read_page_value);
    }

    strbuf b = strbufnew();
    strbuf c = strbufnew();
    b = strbufprintf(b, "%d", current_page - 1);
    if(strlen(strbuf2str(b)) < 2) {
        c = strbufprintf(c, "00%s", strbuf2str(b));
    } else if(strlen(strbuf2str(b)) < 3) {
        c = strbufprintf(c, "0%s", strbuf2str(b));
    } else {
        c = strbufcat(c, strbuf2str(b));
    }

    char *res = strbuf2str_dup(c);
    free(b);
    free(c);

    return res;
}

void write_file_out(char *file_path, char *contents) {
    // printf("path: %s\n", file_path);
    FILE *fp = fopen(file_path, "ab"); // "ab": Append; open or create file for writing at end-of-file.
    if (fp != NULL) {
        fputs(contents, fp);
        fclose(fp);
    }
}

/*
 * Ejecuta el handler de cada región
 */
void call_handlers(lista regions, handler handler_array[], void *contents) {

    /* Ejecuta el handler de cada región */
    for (int i = 0; i < regions.len; i++) {
        region *region = lista_get(regions, i);
        if (NULL != handler_array[region->type]) {
            handler_array[region->type](region, contents);
        }
    }
}

/*
 *
 * WORDS SELECCIONADAS
 *
 */

/*
 * Punto de entrada para la generación lista de palabras seleccionadas
 */
void get_selected_words(lista regions, lista pages_words) {

    // Extrae las palabras de las regiones
    call_handlers(regions, handlers_selected_words, &pages_words);
}

/*
 * Handler de selección de palabras para regiones r1
 */
void handler_selected_words_r1(region *region, lista *pages_words) {

    for (int i=0; i<region->r1.len; i++) {
        content_pair *content_pair = lista_get(region->r1, i);
        for (int j = 0; j < content_pair->words.len; j++) {
            word_value *word_value = lista_get(content_pair->words, j);
            lista *page_words = lista_get(*pages_words, word_value->w_page_number_numeric-1);
            lista_append(page_words, word_value);
        }
    }
}

/*
 * Handler de selección de palabras para regiones r2
 */
void handler_selected_words_r2(region *region, lista *pages_words) {

    for (int i=0; i<region->r2.len; i++) {
        content_pair *content_pair = lista_get(region->r2, i);
        for (int j = 0; j < content_pair->words.len; j++) {
            word_value *word_value = lista_get(content_pair->words, j);
            lista *page_words = lista_get(*pages_words, word_value->w_page_number_numeric-1);
            lista_append(page_words, word_value);
        }
    }
}

/*
 * Handler de selección de palabras para regiones r3
 */
void handler_selected_words_r3(region *region, lista *pages_words) {

    for (int i=0; i<region->r3.len; i++) {
        content_pair *content_pair = lista_get(region->r3, i);
        for (int j = 0; j < content_pair->words.len; j++) {
            word_value *word_value = lista_get(content_pair->words, j);
            lista *page_words = lista_get(*pages_words, word_value->w_page_number_numeric-1);
            lista_append(page_words, word_value);
        }
    }
}

/*
 * Handler de selección de palabras para regiones t1
 */
void handler_selected_words_t1(region *region, lista *pages_words) {

    for(int i=0; i<region->t1.rows.len; i++) {
        lista *cols = lista_get(region->t1.rows, i);
        for(int j=0; j<cols->len; j++) {
            lista *words = lista_get(*cols, j);
            for(int k=0; k<words->len; k++) {
                word_value *word_value = lista_get(*words, k);
                lista *page_words = lista_get(*pages_words, word_value->w_page_number_numeric-1);
                lista_append(page_words, word_value);
            }
        }
    }
}

/*
 * Handler de selección de palabras para regiones t2
 */
void handler_selected_words_t2(region *region, lista *pages_words) {

    for (int i=0; i<region->t2.rows.len; i++) {
        lista *cols = lista_get(region->t2.rows, i);
        for (int j=0; j<cols->len; j++) {
            lista *words = lista_get(*cols, j);
            for (int k=0; k<words->len; k++) {
                word_value *word_value = lista_get(*words, k);
                lista *page_words = lista_get(*pages_words, word_value->w_page_number_numeric-1);
                lista_append(page_words, word_value);
            }
        }
    }
}

/*
 *
 * TABLA A CSV
 *
 */

/*
 * Punto de entrada para la generación de la salida XML
 */
strbuf get_xml_version(lista regions) {
    lista *l = malloc(sizeof *l);
    nueva_lista(l);
    call_handlers(regions, handlers_xml_contents, l);

    strbuf c = strbufnew();
    for(int i=0; i<l->len; i++) {
        strbuf b = lista_get(*l, i);
        c = strbufcat(c, strbuf2str(b));
    }

    free(l);
    return c;
}

/*
 * Handler de generación XML para regiones r1
 */
void handler_xml_contents_r1(region *region, lista *output) {
    // printf("handler_xml_contents_r1\n");
}

/*
 * Handler de generación XML para regiones r2
 */
void handler_xml_contents_r2(region *region, lista *output) {
    // printf("handler_xml_contents_r2\n");
}

/*
 * Handler de generación XML para regiones r3
 */
void handler_xml_contents_r3(region *region, lista *output) {
    // printf("handler_xml_contents_r3\n");
}

/*
 * Handler de generación XML para regiones t1
 */
void handler_xml_contents_t1(region *region, lista *output) {
    // printf("handler_xml_contents_t1\n");
}

/*
 * Handler de generación XML para regiones t2
 */
void handler_xml_contents_t2(region *region, lista *output) {

    char *tmp;
    strbuf b = strbufnew();
    strbuf c = strbufnew();

    // Añade cabecera
    if(region->t2.col_titles.len) {
        for(int i=0; i<region->t2.col_titles.len; i++) {
            char *col_title = lista_get(region->t2.col_titles, i);

            if(!i) {
                c = strbufprintf(c, "%s", col_title);
            } else {
                c = strbufprintf(c, "%s%s", CSV_DELIMITER, col_title);
            }
        }

        b = strbufprintf(b, "%s\n", strbuf2str(c));
        free(c);
    }

    // Añade cuerpo del CSV
    for(int i=0; i<region->t2.rows.len; i++) {

        lista *cols = lista_get(region->t2.rows, i);
        c = strbufnew();
        for (int j=0; j<cols->len; j++) {

            c = strbufcat(c, CSV_DELIMITER);
            lista *words = lista_get(*cols, j);
            for (int k=0; k<words->len; k++) {
                word_value *word_value = lista_get(*words, k);

                if(!k) {
                    c = strbufprintf(c, "%s", word_value->value);
                } else {
                    c = strbufprintf(c, " %s", word_value->value);
                }
            }
        }
        c = strbufcat(c, "\n");
        tmp = strbuf2str(c);
        tmp+=2;
        b = strbufcat(b, tmp);
        tmp-=2;

        free(c);
    }

    lista_append(output, b);
}
