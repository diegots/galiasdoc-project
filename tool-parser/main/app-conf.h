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

#ifndef APP_CONF_H
#define APP_CONF_H

typedef struct language_file {
        char *path;
        char *id;
        char *page;
} language_file;

/* Struct para los datos de configuración de la aplicación
 * 'plugin_name': nombre del plugin que se desea utilizar
 * 'plugin_path': path al plugin.
 * 'template_id': identificador del template
 * 'language_path': ruta al fichero con lenguaje intermedio */
typedef struct app_config {
    language_file *language_file;
    char *plugin_name;
    char *plugin_path;
    char *template_id;
    int max_page_number;
} app_config;

/* Variable global de la configuración, disponible en todos los módulos de la
 * aplicación. La reserva de memoria se hace en main.c */
app_config *app_config_;

#endif
