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
