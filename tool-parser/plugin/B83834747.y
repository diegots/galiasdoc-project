%{
#include "bison-prologue.h"

#include <strbuf.h>
#include <stdlib.h>
#include <string.h>

#include "strbuf.h"
#define TABLE_COLS_NUMBER 5
#define TABLE_TITLE_LENGTH 25

char table_col_titles[TABLE_COLS_NUMBER][TABLE_TITLE_LENGTH] = {
    "Precio IVA no incluído",
    "Precio unitario",
    "Cantidad",
    "Dominio",
    "Concepto"
};

bool fill_titles = true;

/* En estos documentos, cuando un importe es de cuatro cifras, los millares están separados de los
 * demás dígitos:
 *     1 234
 * En el caso anterior, la lista donde están almacenados, contiene dos words. Esta función concatena
 * los valores para obtener el número real.
 *
 * La memoria devuelta por esta función debe ser liberada con free.
 */
char *fix_four_digit_amounts(lista words) {
    strbuf b = strbufnew();
    for(int i=0; i<words.len-1; i++) {
        word_value *w = lista_get(words, i);
        b = strbufcat(b, w->value);
    }
    return strbuf2str_dup(b);
}

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

    #include "gen-amount.h"
    #include "types.h"
    #include "util.h"
    #include "gen.h"

    int empty_cols_counter;

    typedef struct resumen {
        content_pair *precio_iva_no;
        content_pair *iva;
        content_pair *total_iva_inc;
    } resumen;
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
    word_value *word_value;
    content_pair *content_pair;
    resumen resumen;
}

%token _21
%token DE
%token CLTE COL_START COL_END CANTIDAD
%token DOMINIO
%token FACTURA
%token FECHA
%token ID INCL IVA INSCRITA INSTALACION
%token LINE_START LINE_END
%token NO
%token ORDEN OFERTAS OTROS
%token PAGO PEDIDO PRECIO PORCENTAJE
%token R1_START R1_END R3_START R3_END RENOVACION
%token SUBTOTAL SUSCRIPCION
%token T2_START T2_END TOTAL TRANSFERENCIA
%token UNITARIO
%token VCTO
%token <word_value> HISPANO
%token <word_value> WORD

%type<lista> r1 r3 t2 words regions lines line col_content col_foot
%type<content_pair> factura fecha fecha_vcto id_clte orden pago total_iva_inc iva precio_iva_no suscripcion renovacion ofertas transferencia otros
%type<region> region
%type<word_value> word
%type<resumen> resumen

%start S

%%
S: regions {
    gen_contents($1, app_config_);
    gen_table_amounts(table_amounts_, app_config_);

    /* gen_table_csv(table_, app_config_); */

    free_ast($1);
}

regions: regions region  {
    $$ = $1;
    lista_append(&($$), $2);
} | region {
    nueva_lista(&($$));
    lista_append(&($$), $1);
}

region: r1 {
    $$ = malloc(sizeof *$$);
    $$->type = R_R1;
    $$->r1 = $1;
} | r3 {
    $$ = malloc(sizeof *$$);
    $$->type = R_R3;
    $$->r3 = $1;
} | t2 {
    $$ = malloc(sizeof *$$);
    $$->type = R_T2;
    $$->t2.rows = $1;

    nueva_lista(&$$->t2.col_titles);
    if(fill_titles) {
        for(int i=0; i<TABLE_COLS_NUMBER; i++) {
            lista_prepend(&$$->t2.col_titles, table_col_titles[i]);
        }
        fill_titles = false;
    }
}

r3: R3_START word HISPANO words R3_END {
    nueva_lista(&$$);
    content_pair *cp = malloc(sizeof *cp);
    cp->header = strdup("Emisor, Razón social");
    nueva_lista(&cp->words);
    lista_append(&cp->words, $2);
    lista_append(&cp->words, $3);
    lista_delete(&$4, 1);
    lista_cat(&cp->words, $4);
    lista_append(&$$, cp);

} | R3_START words INSCRITA words R3_END {
    nueva_lista(&$$);
    content_pair *cp = malloc(sizeof *cp);
    cp->header = strdup("CIF");
    nueva_lista(&cp->words);
    word_value *wv = lista_get($2, 1);
    lista_append(&cp->words, wv);
    lista_append(&$$, cp);
}

t2: T2_START lines T2_END {
    $$ = $2;
}

lines: lines line {
    empty_cols_counter = 0;
    $$ = $1;
    if ($2.len) { /* Si la linea contiene columnas con contenido */
        lista *l = malloc(sizeof *l);
        *l = $2;
        lista_append(&($$), l);
    }
} | line {
    empty_cols_counter = 0;
    nueva_lista(&($$));
    if ($1.len) {
        lista *l = malloc(sizeof *l);
        *l = $1;
        lista_append(&($$), l);
    }
}

line: LINE_START col_head col_head col_head col_head col_head LINE_END {
    nueva_lista(&($$));

    table_amount *t = malloc(sizeof *t);
    nueva_lista(&t->singles);
    t->subtotal = NULL;
    t->subtotal_type = WITH;
    lista_append(table_amounts_->tables, t);
}
| LINE_START col_content col_content col_content col_content col_content LINE_END {
    nueva_lista(&($$));
    if(empty_cols_counter < 5) {
        lista *l = malloc(sizeof *l);
        *l = $2;
        lista_append(&$$, l);

        l = malloc(sizeof *l);
        *l = $3;
        lista_append(&$$, l);

        l = malloc(sizeof *l);
        *l = $4;
        lista_append(&$$, l);

        l = malloc(sizeof *l);
        *l = $5;
        lista_append(&$$, l);

        l = malloc(sizeof *l);
        *l = $6;
        lista_append(&$$, l);

        if($6.len) {
            word_value *w = lista_get($6, 0);
            table_amount *ta = lista_get(*table_amounts_->tables, table_amounts_->tables->len-1);
            lista_append(&ta->singles, w);
        }
    }
}
| LINE_START col_content col_content col_content col_foot col_content LINE_END {
    nueva_lista(&($$));
    lista *l = malloc(sizeof *l);
    *l = $2;
    lista_append(&$$, l);

    l = malloc(sizeof *l);
    *l = $3;
    lista_append(&$$, l);

    l = malloc(sizeof *l);
    *l = $4;
    lista_append(&$$, l);

    l = malloc(sizeof *l);
    *l = $5;
    lista_append(&$$, l);

    if($6.len) {
        word_value *w = lista_get($6, 0);
        w->value = fix_four_digit_amounts($6);

        while($6.len > 2) {
            lista_delete(&$6, 1);
        }

        table_amount *ta = lista_get(*table_amounts_->tables, table_amounts_->tables->len-1);
        ta->subtotal = w;
    }

    l = malloc(sizeof *l);
    *l = $6;
    lista_append(&$$, l);
}

col_head: COL_START SUSCRIPCION COL_END {}
| COL_START OTROS COL_END {}
| COL_START OFERTAS COL_END {}
| COL_START TRANSFERENCIA COL_END {}
| COL_START RENOVACION COL_END {}
| COL_START INSTALACION COL_END {}
| COL_START DOMINIO COL_END {}
| COL_START CANTIDAD COL_END {}
| COL_START PRECIO UNITARIO COL_END {}
| COL_START PRECIO IVA NO INCL COL_END {}

col_content: COL_START words COL_END {
    $$ = $2;
} | COL_START COL_END {
    nueva_lista(&($$));
    empty_cols_counter++;
}

col_foot: COL_START word SUBTOTAL COL_END {
    nueva_lista(&($$));
}

r1: R1_START factura fecha fecha_vcto orden pago id_clte R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3);
    lista_append(&($$), $4);
    lista_append(&($$), $5);
    lista_append(&($$), $6);
    lista_append(&($$), $7);
}
| R1_START suscripcion resumen R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3.precio_iva_no);
    lista_append(&($$), $3.iva);
    lista_append(&($$), $3.total_iva_inc);
} | R1_START renovacion suscripcion resumen R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3);
    lista_append(&($$), $4.precio_iva_no);
    lista_append(&($$), $4.iva);
    lista_append(&($$), $4.total_iva_inc);
} | R1_START renovacion resumen R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3.precio_iva_no);
    lista_append(&($$), $3.iva);
    lista_append(&($$), $3.total_iva_inc);
} | R1_START transferencia ofertas resumen R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3);
    lista_append(&($$), $4.precio_iva_no);
    lista_append(&($$), $4.iva);
    lista_append(&($$), $4.total_iva_inc);
} | R1_START otros resumen R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3.precio_iva_no);
    lista_append(&($$), $3.iva);
    lista_append(&($$), $3.total_iva_inc);
} | R1_START suscripcion R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
} | R1_START resumen R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2.precio_iva_no);
    lista_append(&($$), $2.iva);
    lista_append(&($$), $2.total_iva_inc);
}

resumen: precio_iva_no iva total_iva_inc {
    $$.precio_iva_no = $1;
    $$.iva = $2;
    $$.total_iva_inc = $3;

    // Guarda el precio neto, iva y total
    word_value *w0 = lista_get($1->words, 0);
    w0->value = fix_four_digit_amounts($1->words);
    table_amounts_->base = w0;

    word_value *w1 = lista_get($2->words, 0);
    w1->value = fix_four_digit_amounts($2->words);
    table_amounts_->iva_tax = w1;

    word_value *w2 = lista_get($3->words, 0);
    w2->value = fix_four_digit_amounts($3->words);
    table_amounts_->total = w2;
}

otros: OTROS words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Otros");
    $$->words = $2;
}

transferencia: TRANSFERENCIA words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Transferencia");
    $$->words = $2;
}

ofertas: OFERTAS words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Ofertas");
    $$->words = $2;
}

renovacion: RENOVACION words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Renovación");
    $$->words = $2;
}

suscripcion: SUSCRIPCION words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Suscripción");
    $$->words = $2;
}

precio_iva_no: PRECIO IVA NO INCL words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Precio IVA no incl.");
    $$->words = $5;
}
iva: IVA _21 PORCENTAJE words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("IVA 21");
    $$->words = $4;
}
total_iva_inc: TOTAL IVA INCL words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Total IVA incl.");
    $$->words = $4;
}

factura: FACTURA words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Factura");
    $$->words = $2;
}
fecha: FECHA words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Fecha");
    $$->words = $2;
}
fecha_vcto: FECHA DE words VCTO {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Fecha de vencimiento");
    $$->words = $3;
}
orden: ORDEN DE PEDIDO words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Orden de pedido");
    $$->words = $4;
}
pago: PAGO words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Pago");
    $$->words = $2;
}
id_clte: ID DE CLTE words {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Id de cliente");
    $$->words = $4;
}

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

#include "lista.h"
#include <stdlib.h>

void free_ast(lista ast) {
    for (int i=0; i<ast.len; i++) {
        region *region = lista_get(ast, i);
        switch(region->type) {
            case R_R1:
                for(int j=0; j<region->r1.len; j++) {
                    content_pair *line = lista_get(region->r1, j);
                    free(line->header);
                    lista_free(&line->words, true);
                    free(line);
                }
                lista_free(&region->r1, false);
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
