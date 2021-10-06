#ifndef GEN_AMOUNT_H
#define GEN_AMOUNT_H

#include "app-conf.h"
#include "types.h"

/*
 *
 */
void gen_amount(amounts *amounts, app_config *app_config);

/*
 * Genera importes para las tablas y totales del documento
 */
void gen_table_amounts(table_amounts *table_amounts, app_config *app_config);

/*
 * Genera CSV de la tabla del documento
 */
void gen_table_csv(table *table, app_config *app_config);
#endif
