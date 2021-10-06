%{

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

#include "bison-prologue.h"

#include <stdlib.h>
#include <string.h>

#include "util.h"

#define TABLE_COLS_NUMBER 3
#define TABLE_TITLE_LENGTH 15

char table_col_titles[TABLE_COLS_NUMBER][TABLE_TITLE_LENGTH] = {
    "Importe",
    "Descripción",
    "Fecha"
};

/*
 * Acción para región r3
 */
void r3_action(lista l, word_value *base, word_value *porcentaje, word_value *importe_iva, word_value *total) {
    nueva_lista(&l);

    content_pair *content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Base");
    nueva_lista(&content_pair->words);
    lista_append(&content_pair->words, base);
    lista_append(&l, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("% IVA");
    nueva_lista(&content_pair->words);
    lista_append(&content_pair->words, porcentaje);
    lista_append(&l, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Importe IVA");
    nueva_lista(&content_pair->words);
    lista_append(&content_pair->words, importe_iva);
    lista_append(&l, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Total");
    nueva_lista(&content_pair->words);
    lista_append(&content_pair->words, total);
    lista_append(&l, content_pair);
}

/* Crea un nuevo content_pair copiando el header e inicializando la lista de words.
 * La memoria devuelta debe ser liberada normalmente. */
content_pair *create_content_pair(char *header) {
    content_pair *content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup(header);
    lista *l = malloc(sizeof *l);
    nueva_lista(l);
    content_pair->words = *l;

    return content_pair;
}

%}

%code requires {
    #include <string.h>

    #include "types.h"
    #include "gen.h"
    #include "gen-amount.h"
    #include "util.h"

    int empty_cols_counter;
}

%define parse.error verbose

%code provides {
    void free_ast(lista ast);
}

%union {
    int *int_pointer;
    char *string;
    cols cols;
    lista lista;
    region *region;
    content_pair *content_pair;
    word_value *word_value;
}

%token BASE
%token CIF COL_START COL_END CONDICIONES
%token DE DESCRIPCION DOMICILIO
%token EUROS
%token FACTURA FECHA
%token GRAVABLE
%token IMPORTE IMPUESTOS IVA
%token NETO NO
%token NIF_CIF
%token LINE_START LINE_END
%token PAGO
%token T1_START T1_END TOTAL
%token R2_END R2_START R3_END R3_START REFERENCIA
%token VENCIMIENTO
%token <word_value> WORD
%token <word_value> PRODWARE

%type<lista> t1 r2 r3 words regions t1_col lines line col_r2
%type<region> region
%type<word_value> word
%start S

%%
S: regions {
    gen_contents($1, app_config_);
    gen_table_amounts(table_amounts_, app_config_);

    free_ast($1);
}

regions: regions region  {
    $$ = $1;
    lista_append(&($$), $2);
} | region {
    nueva_lista(&($$));
    lista_append(&($$), $1);
}

region: r2 {
    $$ = malloc(sizeof *$$);
    $$->type = R_R2;
    $$->r2 = $1;
} | r3 {
    $$ = malloc(sizeof *$$);
    $$->type = R_R3;
    $$->r3 = $1;
} | t1 {
    $$ = malloc(sizeof *$$);
    $$->type = R_T2;
    $$->t2.rows = $1;

    nueva_lista(&$$->t2.col_titles);
    for(int i=0; i<TABLE_COLS_NUMBER; i++) {
        lista_prepend(&$$->t2.col_titles, table_col_titles[i]);
    }
}
r3: R3_START BASE WORD IVA IMPORTE IVA WORD WORD WORD TOTAL WORD R3_END {
    r3_action($$, $7, $8, $9, $11);

} | R3_START WORD IVA IMPORTE IVA BASE WORD WORD WORD TOTAL WORD R3_END {
    /* Caso para el documento 38 que sigue una ordenación diferente */
    r3_action($$, $7, $8, $9, $11);

} | R3_START CONDICIONES PAGO words R3_END {
    nueva_lista(&($$));

    content_pair *content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Condiciones de pago");
    content_pair->words = $4;
    lista_append(&$$, content_pair);

} | R3_START PRODWARE word word words CIF word DOMICILIO words R3_END {
    nueva_lista(&($$));

    content_pair *content_pair = create_content_pair("Emisor");
    lista_append(&content_pair->words, $2);
    lista_append(&content_pair->words, $3);
    lista_append(&content_pair->words, $4);
    lista_append(&$$, content_pair);

    content_pair = create_content_pair("CIF");
    lista_append(&content_pair->words, $7);
    lista_append(&$$, content_pair);

    content_pair = create_content_pair("Razón social");
    lista_cat(&content_pair->words, $9);
    lista_append(&$$, content_pair);

}

t1: T1_START lines T1_END {
    $$ = $2;
}

lines: lines line {
    $$ = $1;
    lista *l = malloc(sizeof *l);
    nueva_lista(l);
    lista_cat(l, $2);

    lista_append(&$$, l);
} | line {
    nueva_lista(&$$);
    lista *l = malloc(sizeof *l);
    nueva_lista(l);
    /* lista_cat(l, $1); */
    /* lista_append(&$$, l); */

    // Reserva memoria para la tabla en la primera linea
    table_amount *ta = malloc(sizeof *ta);
    nueva_lista(&ta->singles);
    ta->subtotal_type = WITHOUT;
    lista_append(table_amounts_->tables, ta);
}

line: LINE_START t1_col t1_col t1_col LINE_END {
  /* LINE_START FECHA DESCRIPCION IMPORTE LINE_END */
    nueva_lista(&$$);

    lista *l = malloc(sizeof *l);
    nueva_lista(l);
    lista_cat(l, $2);
    lista_append(&$$, l);

    l = malloc(sizeof *l);
    nueva_lista(l);
    lista_cat(l, $3);
    lista_append(&$$, l);

    l = malloc(sizeof *l);
    nueva_lista(l);
    lista_cat(l, $4);
    lista_append(&$$, l);

    // Genera floats para los importes
    for(int i=0; i<$4.len; i++) {
        word_value *word_value = lista_get($4, i);
        fix_string_float(word_value->value);
    }

    // Acumula las palabras de la tabla
    if($4.len) {
        table_amount *ta = lista_get(*table_amounts_->tables, 0);
        lista_cat(&ta->singles, $4);
        ta->subtotal = NULL;
    }
}

t1_col: COL_START FECHA COL_END {}
| COL_START DESCRIPCION COL_END {}
| COL_START IMPORTE COL_END {}
| COL_START words COL_END {
    $$ = $2;
}

r2: R2_START factura fecha referencia fecha_vcto nif_cif col_r2 col_r2 col_r2 col_r2 col_r2 R2_END {
    nueva_lista(&($$));
    content_pair *content_pair;

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Factura");
    content_pair->words = $7;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Fecha");
    content_pair->words = $8;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Referencia");
    content_pair->words = $9;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Fecha vencimiento");
    content_pair->words = $10;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("NIF/CIF");
    content_pair->words = $11;
    lista_append(&$$, content_pair);

} | R2_START no_gravable gravable importe_neto impuestos total_euros col_r2 col_r2 col_r2 col_r2 col_r2 R2_END {
    nueva_lista(&($$));
    content_pair *content_pair;

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("No gravable");
    content_pair->words = $7;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Gravable");
    content_pair->words = $8;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Importe neto");
    content_pair->words = $9;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Impuestos");
    content_pair->words = $10;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Total euros");
    content_pair->words = $11;
    lista_append(&$$, content_pair);

    word_value *w0 = lista_get($9, 0);
    fix_string_float(w0->value);
    table_amounts_->base = w0;

    word_value *w1 = lista_get($10, 0);
    fix_string_float(w1->value);
    table_amounts_->iva_tax = w1;

    word_value *w2 = lista_get($11, 0);
    fix_string_float(w2->value);
    table_amounts_->total = w2;

}

factura: COL_START FACTURA COL_END
fecha: COL_START FECHA COL_END
referencia: COL_START REFERENCIA COL_END
fecha_vcto: COL_START FECHA DE VENCIMIENTO COL_END
nif_cif: COL_START NIF_CIF COL_END

no_gravable: COL_START NO GRAVABLE COL_END
gravable: COL_START GRAVABLE COL_END
importe_neto: COL_START IMPORTE NETO COL_END
impuestos: COL_START IMPUESTOS COL_END
total_euros: COL_START TOTAL EUROS COL_END

col_r2: COL_START words COL_END {
    $$ = $2;
} | COL_START COL_END {}

words: words word {
    $$ = $1;
    lista_append(&($$), $2);
} | word {
    nueva_lista(&($$));
    lista_append(&($$), $1);
}

word: WORD {
    $$ = $1;
    if(app_config_->max_page_number < $1->w_page_number_numeric) {
        app_config_->max_page_number = $1->w_page_number_numeric;
    }
}

%%

#include "bison-epilogue.h"

void free_ast(lista ast) {
    for (int i=0; i<ast.len; i++) {
        region *region = lista_get(ast, i);
        switch(region->type) {
            case R_R1:
                break;
            case R_R2:
                break;
            case R_R3:
                break;
            case R_T1:
                break;
            case R_T2:
                break;
        }
        free(region);

    }
    lista_free(&ast, false);
}
