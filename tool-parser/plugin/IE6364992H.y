%{
#include "bison-prologue.h"
#define YYDEBUG 1

#define TABLE_COLS_NUMBER 6
#define TABLE_TITLE_LENGTH 35

char table_col_titles[TABLE_COLS_NUMBER][TABLE_TITLE_LENGTH] = {
    "Precio total",
    "Precio unitario",
    "Cantidad enviada",
    "Cantidad pendiente",
    "Cantidad solicitada",
    "Número de prod. & descr. art."
};

%}

%code requires {
    #include <string.h>

    #include "types.h"
    #include "gen.h"
    #include "gen-amount.h"
    #include "strbuf.h"
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
    lista lista;
    region *region;
    word_value *word_value;
    content_pair *content_pair;
}

%token A ARTICULO ARTICULOS
%token CREDITO CLIENTE COL_START COL_END CONTACTO CODIGO CANTIDAD
%token DE DIVISA DESCRIPCION
%token ENVIO
%token FACTURA FACTURACION FECHA FORMA
%token GASTOS
%token IMPORTE INCLUIDO IVA
%token LA LINE_END LINE_START
%token NUMERO NOTA
%token PEDIDO PAGAR PAGO PRECIO PRODUCTO
%token R1_START R1_END R2_START R2_END T2_START T2_END R3_END R3_START
%token TOTAL TIPO
%token Y
%token <word_value> WORD

%type<lista> col_content col_r2 cuadro_gris forma_pago line lines r3 regions resumen t2 tipo_iva words
%type<region> region
%type<word_value> word
%type<content_pair> tipo_documento numero_factura fecha_factura fecha_facturacion numero_pedido_clte numero_pedido cliente
%type<content_pair> articulos gastos_envio iva total_iva_incluido importe_a_pagar divisa

%start S

%%

S: regions {
    gen_contents($1, app_config_);
    gen_table_amounts(table_amounts_, app_config_);

    free_ast($1);
}

regions: regions region {
    $$ = $1;
    lista_append(&($$), $2);
}
| region {
    nueva_lista(&($$));
    lista_append(&($$), $1);
}

region: cuadro_gris {
    $$ = malloc(sizeof *$$);
    $$->type = R_R1;
    $$->r1 = $1;
} | resumen {
    $$ = malloc(sizeof *$$);
    $$->type = R_R1;
    $$->r1 = $1;
} | forma_pago {
    $$ = malloc(sizeof *$$);
    $$->type = R_R2;
    $$->r2 = $1;
} | tipo_iva {
    $$ = malloc(sizeof *$$);
    $$->type = R_R2;
    $$->r2 = $1;
} | r3 {
    $$ = malloc(sizeof *$$);
    $$->type = R_R3;
    $$->r3 = $1;
} | t2 {
    $$ = malloc(sizeof *$$);
    $$->type = R_T2;
    $$->t2.rows = $1;

    // Almacena los títulos de las columnas
    nueva_lista(&$$->t2.col_titles);
    for(int i=0; i<TABLE_COLS_NUMBER; i++) {
        lista_prepend(&$$->t2.col_titles, table_col_titles[i]);
    }
}

r3: R3_START words R3_END {
    nueva_lista(&$$);
    content_pair *cp = malloc(sizeof *cp);
    cp->header = strdup("Emisor");
    cp->words = $2;
    lista_append(&$$, cp);

} | R3_START NUMERO words R3_END {
    nueva_lista(&$$);
    content_pair *cp = malloc(sizeof *cp);
    cp->header = strdup("CIF");
    nueva_lista(&cp->words);
    word_value *wv = lista_get($3, $3.len-1);
    lista_append(&cp->words, wv);
    lista_append(&$$, cp);
}

t2: T2_START lines T2_END {
    $$ = $2;
}

resumen: R1_START articulos gastos_envio iva total_iva_incluido importe_a_pagar divisa R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3);
    lista_append(&($$), $4);
    lista_append(&($$), $5);
    lista_append(&($$), $6);
    lista_append(&($$), $7);
}

cuadro_gris: R1_START
        tipo_documento numero_factura fecha_factura fecha_facturacion numero_pedido_clte numero_pedido cliente R1_END {
    nueva_lista(&($$));
    lista_append(&($$), $2);
    lista_append(&($$), $3);
    lista_append(&($$), $4);
    lista_append(&($$), $5);
    lista_append(&($$), $6);
    lista_append(&($$), $7);
    lista_append(&($$), $8);
}

lines: lines line {
    $$ = $1;
    if ($2.len) {
        lista *l = malloc(sizeof *l);
        *l = $2;
        lista_append(&($$), l);
    }
} | line {
    nueva_lista(&($$));
    if ($1.len) {
        lista *l = malloc(sizeof *l);
        *l = $1;
        lista_append(&($$), l);
    }
}

line: LINE_START col_head col_head col_head col_head col_head col_head LINE_END {
    empty_cols_counter = 0;
    nueva_lista(&($$));
}
| LINE_START col_content col_content col_content col_content col_content col_content LINE_END {
    nueva_lista(&($$));
    if(empty_cols_counter < 6) {
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

        l = malloc(sizeof *l);
        *l = $7;
        lista_append(&$$, l);

        // Guarda importe(s) de la tabla para comprobación posterior
        if($7.len) {
            word_value *w = lista_get($7, 0);
            fix_string_float(w->value);

            table_amount *ta = lista_get(*table_amounts_->tables, 0);
            lista_append(&ta->singles, w);
        }
    }

    empty_cols_counter = 0;
}

col_head: COL_START NUMERO DE PRODUCTO Y DESCRIPCION DE ARTICULO COL_END
    | COL_START CANTIDAD COL_END
    | COL_START PRECIO COL_END
    | COL_START PRECIO TOTAL COL_END

col_content: COL_START words COL_END {
    $$ = $2;
} | COL_START COL_END {
    nueva_lista(&($$));
    empty_cols_counter++;
}

tipo_iva: R2_START codigo_iva tipo_iva col_r2 col_r2 R2_END {
    nueva_lista(&($$));
    content_pair *content_pair;

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Código IVA");
    content_pair->words = $4;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("IVA total");
    content_pair->words = $5;
    lista_append(&$$, content_pair);
}

forma_pago: R2_START forma_pago contacto col_r2 col_r2 R2_END {
    nueva_lista(&($$));
    content_pair *content_pair;

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Forma de pago");
    content_pair->words = $4;
    lista_append(&$$, content_pair);

    content_pair = malloc(sizeof *content_pair);
    content_pair->header = strdup("Contacto");
    content_pair->words = $5;
    lista_append(&$$, content_pair);
}

codigo_iva: COL_START CODIGO DE IVA COL_END {}
tipo_iva: COL_START TIPO DE IVA COL_END {}

forma_pago: COL_START FORMA DE PAGO COL_END {}
contacto: COL_START CONTACTO COL_END {}

col_r2: COL_START words COL_END {
    $$ = $2;
}

tipo_documento: words FACTURA '/' NOTA DE CREDITO {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Tipo documento");
    $$->words = $1;
}

numero_factura: words NUMERO DE FACTURA {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Número de factura");
    $$->words = $1;
}

fecha_factura: words FECHA DE LA FACTURA {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Fecha de factura");
    $$->words = $1;
}

fecha_facturacion: words FECHA DE FACTURACION {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Fecha de facturación");
    $$->words = $1;
}

numero_pedido_clte: words NUMERO DE PEDIDO DE CLIENTE {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Número de pedido de cliente");
    $$->words = $1;
}

numero_pedido: words NUMERO DE PEDIDO {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Número de pedido");
    $$->words = $1;
}

cliente: words CLIENTE {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Cliente");
    $$->words = $1;
}

articulos: words ARTICULOS {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Artículos");
    $$->words = $1;

    // Guarda el valor del precio de todos los artículos
    word_value *w = lista_get($1, 0);
    fix_string_float(w->value);
    table_amounts_->base = w;

    // Inicializa la tabla del documento
    table_amount *ta = malloc(sizeof *ta);
    nueva_lista(&ta->singles);
    ta->subtotal = NULL;
    ta->subtotal_type = WITHOUT;
    lista_append(table_amounts_->tables, ta);
}

gastos_envio: words GASTOS DE ENVIO {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Gastos de envío");
    $$->words = $1;
}

iva: words IVA {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("IVA");
    $$->words = $1;

    // Guarda el importe del IVA de la compra
    word_value *w = lista_get($1, 0);
    fix_string_float(w->value);

    table_amounts_->iva_tax = w;
}

total_iva_incluido: words TOTAL IVA INCLUIDO {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Total IVA incluido");
    $$->words = $1;

    // Guarda el importe total de la compra
    word_value *w = lista_get($1, 0);
    fix_string_float(w->value);

    table_amounts_->total = w;
}

importe_a_pagar: words IMPORTE A PAGAR {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Importe a pagar");
    $$->words = $1;
}

divisa: words DIVISA {
    $$ = malloc(sizeof *$$);
    $$->header = strdup("Divisa");
    $$->words = $1;
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
    lista_free(&ast, false);
}
