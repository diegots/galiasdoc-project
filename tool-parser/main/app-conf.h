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
