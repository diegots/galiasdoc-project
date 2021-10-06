#include "gen-amount.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cJSON.h"
#include "gen.h"
#include "strbuf.h"

void gen_amount(amounts *amounts, app_config *app_config) {

    cJSON *root = cJSON_CreateObject();

    // Amounts
    cJSON *amounts_array = cJSON_CreateArray();

    for(int i=0; i<amounts->singles.len; i++) {
        word_value *w = lista_get(amounts->singles, i);

        cJSON *amount = cJSON_CreateObject();

        cJSON *value = cJSON_CreateString(w->value);
        cJSON_AddItemToObject(amount, "value", value);

        cJSON *id = cJSON_CreateNumber(w->w_id_numeric);
        cJSON_AddItemToObject(amount, "id", id);

        cJSON_AddItemToArray(amounts_array, amount);
    }

    cJSON_AddItemToObject(root, "amount", amounts_array);

    // Base
    cJSON *base = cJSON_CreateObject();

    cJSON *base_value = cJSON_CreateString(amounts->base->value);
    cJSON_AddItemToObject(base, "base", base_value);

    cJSON *base_id = cJSON_CreateNumber(amounts->base->w_id_numeric);
    cJSON_AddItemToObject(base, "id", base_id);

    cJSON_AddItemToObject(root, "base", base);

    // IVA tax
    cJSON *iva_tax = cJSON_CreateObject();

    cJSON *iva_tax_value = cJSON_CreateString(amounts->iva_tax->value);
    cJSON_AddItemToObject(iva_tax, "iva_tax", iva_tax_value);

    cJSON *iva_tax_id = cJSON_CreateNumber(amounts->iva_tax->w_id_numeric);
    cJSON_AddItemToObject(iva_tax, "id", iva_tax_id);

    cJSON_AddItemToObject(root, "iva_tax", iva_tax);

    // Salida
    strbuf c = strbufnew();
    c = strbufprintf(c, "%s%s-amounts.json",
        app_config->language_file->path,
        app_config->language_file->id);

    write_file_out(strbuf2str(c), cJSON_Print(root));
}

void gen_table_amounts(table_amounts *table_amounts, app_config *app_config) {

    cJSON *root = cJSON_CreateObject();
    cJSON *words;
    cJSON *chunks = cJSON_CreateArray();
    cJSON *chunk_items = cJSON_CreateArray();
    cJSON *chunk;

    for(int i=0; i<table_amounts->tables->len; i++) {
        table_amount *ta = lista_get(*table_amounts->tables, i);

        // Usa la primera palabra para componer el número de la página
        word_value *w = lista_get(ta->singles, 0);
        char *page = fix_page_number(app_config->language_file->page, w->w_page_number_numeric);

        // Añade a este item el nombre de la página que lo contiene
        strbuf b = strbufnew();
        strbufprintf(b, "%s-%s-words.json", app_config->language_file->id, page);
        cJSON *chunk_item = cJSON_CreateObject();
        cJSON_AddStringToObject(chunk_item, "page", strbuf2str(b));

        // Compone el array de palabras
        words = cJSON_CreateArray();
        for(int j=0; j<ta->singles.len; j++) {

            word_value *w = lista_get(ta->singles, j);
            cJSON *word = cJSON_CreateObject();
            cJSON_AddNumberToObject(word, "id", w->w_id_numeric);
            cJSON_AddStringToObject(word, "amount", w->value);
            cJSON_AddItemToArray(words, word);
        }

        cJSON_AddItemToObject(chunk_item, "words", words);
        cJSON_AddItemToArray(chunk_items, chunk_item);

        switch(ta->subtotal_type) {
            case WITH:
            {
                if(ta->subtotal != NULL) {
                    cJSON *subtotal = cJSON_CreateObject();
                    cJSON_AddStringToObject(subtotal, "amount", ta->subtotal->value);
                    cJSON_AddNumberToObject(subtotal, "id", ta->subtotal->w_id_numeric);
                    cJSON_AddItemToObject(chunk_item, "subtotal", subtotal);

                    chunk = cJSON_CreateObject();
                    cJSON_AddItemToObject(chunk, "table", chunk_items);
                    cJSON_AddItemToArray(chunks, chunk);

                    chunk_items = cJSON_CreateArray();
                }
                break;
            }

            case WITHOUT:
                chunk = cJSON_CreateObject();
                cJSON_AddItemToObject(chunk, "table", chunk_items);
                cJSON_AddItemToArray(chunks, chunk);

                chunk_items = cJSON_CreateArray();
                break;
        }
    }

    // Añadir precio base, importe del iva, total con impuestos
    cJSON *base = cJSON_CreateObject();
    cJSON_AddStringToObject(base, "amount", table_amounts->base->value);
    cJSON_AddNumberToObject(base, "id", table_amounts->base->w_id_numeric);
    cJSON_AddItemToObject(root, "base", base);

    cJSON *iva_tax = cJSON_CreateObject();
    cJSON_AddStringToObject(iva_tax, "amount", table_amounts->iva_tax->value);
    cJSON_AddNumberToObject(iva_tax, "id", table_amounts->iva_tax->w_id_numeric);
    cJSON_AddItemToObject(root, "iva_tax", iva_tax);

    cJSON *total = cJSON_CreateObject();
    cJSON_AddStringToObject(total, "amount", table_amounts->total->value);
    cJSON_AddNumberToObject(total, "id", table_amounts->total->w_id_numeric);
    cJSON_AddItemToObject(root, "total", total);

    cJSON_AddItemToObject(root, "tables", chunks);

    // Compone la ruta para el fichero de salida
    strbuf c = strbufnew();
    c = strbufprintf(c, "%s%s-amounts.json",
        app_config->language_file->path,
        app_config->language_file->id);
    // printf("file_amounts: %s\n", strbuf2str(c));

    // Concatena o crea el fichero de amounts
    write_file_out(strbuf2str(c), cJSON_Print(root));

}

void gen_table_csv(table *table, app_config *app_config) {

    strbuf b = strbufnew();
    for(int i=0; i<table->col_titles.len; i++) {
        char *col_title = lista_get(table->col_titles, i);
        b = strbufprintf(b, ",%s", col_title);
    }
    b = strbufcat(b, "\n");
    char *tmp = strbuf2str_dup(b);
    char *titles = strdup(++tmp); // Avanza el primer caracter para descartarlo
    free(--tmp); // Retrocede antes de hacer el free


    // Compone la ruta para el fichero de salida
    strbuf c = strbufnew();
    c = strbufprintf(c, "%s%s-table.csv",
        app_config->language_file->path,
        app_config->language_file->id);
    // printf("file_amounts: %s\n", strbuf2str(c));

    write_file_out(strbuf2str(c), titles);
}
