
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <stdbool.h>
#include <unistd.h>
#include <ctype.h>

#include "strbuf.h"
#include "main.h"
#include "app-conf.h"
#include "global-vars.h"

/*
 * Global runtime values for the application.
 */
FILE *yyin;

/*
 * Local prototypes
 */
void initialize_global_variables();
void compose_plugin_file_name(app_config *);
void free_config(app_config *);
void handle_app_flags(app_config *, int, char *[]);
void action_help();
int action_parse(app_config *);
language_file *get_language_file_parts(char *language_path);

/*
 * Main entry point
 */
int main(int argc, char *argv[]) {

	// Initialization
    app_config_ = malloc(sizeof *app_config_);
    app_config_->max_page_number = 0;

    initialize_global_variables();

    // Arguments handling
    handle_app_flags(app_config_, argc, argv);

    int completed = action_parse(app_config_);

    free_config(app_config_);

    return completed;
}

/**
 * Inicializa las variables globales de global-vars.h
 */
void initialize_global_variables() {

    amounts_ = malloc(sizeof *amounts_);
    nueva_lista(&amounts_->singles);

    table_amounts_ = malloc(sizeof *table_amounts_);
    table_amounts_->tables = malloc(sizeof *table_amounts_->tables);
    nueva_lista(table_amounts_->tables);

    table_ = malloc(sizeof *table_);
    nueva_lista(&table_->col_titles);
    nueva_lista(&table_->rows);
}

/*
 * Build plug-in file name from its name
 */
void compose_plugin_file_name(app_config *app_config) {

	strbuf b = strbufnew();
    b  = strbufprintf(b, "%s%s", app_config->plugin_name, PLUGIN_EXT);
    app_config->plugin_path = strbuf2str_dup(b);

    free(b);
}

/*
 * Free memory
 */
void free_config(app_config *app_config) {

	free(app_config->plugin_name);
	free(app_config->plugin_path);
	free(app_config->template_id);
    free(app_config->language_file->path);
    free(app_config->language_file->id);
    free(app_config->language_file->page);
    free(app_config->language_file);
	free(app_config);
}

/*
 * Input arguments can establish app properties for modifying its behavior or can set and actions to perform.
 */
void handle_app_flags(app_config *app_config, int argc, char *argv[]) {

	opterr = 0; // set getopt() to not printing error messages

	char opt;
    while ((opt = getopt(argc, argv, "hi:t:p:")) != -1) {
        switch(opt) {

		case 'h':
			action_help();
			exit(0);
		case 'i':
			yyin = fopen(optarg, "r");
            app_config->language_file = get_language_file_parts(optarg);
            break;
		case 't':
			app_config->template_id = strdup(optarg);
			break;
		case 'p':
			app_config->plugin_name = strdup(optarg);
			break;
		case '?':
			if (optopt == 'i'
					|| optopt == 't'
					|| optopt == 'p')
			{
				fprintf (stderr, "La opción -%c requiere un parámetro.\n", optopt);
			} else if (isprint (optopt)) {
				fprintf (stderr, "Opción desconocida '-%c'.\n", optopt);
			} else {
				fprintf (stderr, "Caracter desconocido '\\x%x'.\n", optopt);
			}
			exit(1);
		default:
			break;
        }
    }

    if (yyin == NULL) {
    	printf ("Leyendo de la entrada estándar.\n");
    	yyin = stdin;
    }

    if (app_config->template_id == NULL) {
    	fprintf (stderr, "-t <Id del template> es un parámetro obligatorio.\n");
    	exit(1);
    }

    if (app_config->plugin_name == NULL) {
    	fprintf (stderr, "-p <nombre del plug-in> es un parámetro obligatorio.\n");
    	exit(1);
    }
}

void action_help() {

	printf("Esta es la ayuda del parser de Galiasdoc.\n");
	printf("Parámetros de entrada reconocidos:\n");
	printf("\t[-h]: muestra este mensaje de ayuda.\n");
	printf("\t[-i <fichero>]: ruta al fichero con lenguaje intermedio. Se realiza lectura de la entrada estándar en caso de no venir definido.\n");
	printf("\t-t <id>: identificador del template.\n");
	printf("\t-p <fichero>: nombre del plugin.\n");
}

int action_parse(app_config *app_config) {

	int (*parse)();

	compose_plugin_file_name(app_config);

    // Get dynamic library handler
    const char* error_message = NULL;
    void* handle = NULL;

    handle = dlopen(app_config->plugin_path, RTLD_LAZY);
    if(!handle) {
        // fprintf(stderr, "dlopen() %s\n", dlerror()); // error details
        fprintf(stderr, "!");
        exit(1);
    }

    // Get pointer to parser function
    dlerror();
    parse = dlsym(handle, PARSER_NAME);
    error_message = dlerror();
    if(error_message) // it means if it is not null
    {
        // fprintf(stderr, "dlsym() for function %s\n", error_message);
        fprintf(stderr, "!");
        dlclose(handle);
        exit(1);
    }

    // Call shared parser;
    int completed = (*parse)();

    // Clean and exit
    dlclose(handle);
    fclose(yyin);

    return !completed;
}

const char *delim = "-";
const char slash = '/';

int find_slash(char *s) {
        for(int i=strlen(s)-1; i>=0; i--) {
                if (s[i] == slash) {
                        return i;
                }
        }

        return -1;
}

language_file *create_data(char *s) {
        language_file *language_file= malloc(sizeof *language_file);
        language_file->path = strdup("");
        language_file->id = strdup(strtok(s, delim));
        language_file->page = strdup(strtok(NULL, delim));
        return language_file;
}

language_file *create_data_with_path(char *s, int idx) {
        char *ss = s;
        language_file *language_file = malloc(sizeof *language_file);
        idx++;
        strbuf buf = strbufnew();
        buf = strbufncat(buf, s, idx);
        language_file->path = strbuf2str_dup(buf);
        free(buf);

        ss += idx;
        buf = strbufnew();
        buf = strbufcat(buf, ss);
        char *sss = strbuf2str_dup(buf);

        language_file->id = strdup(strtok(sss, delim));
        language_file->page = strdup(strtok(NULL, delim));
        free(buf);
        free(sss);

        return language_file;
}

language_file *get_language_file_parts(char *language_path) {
        int idx = find_slash(language_path);
        if (idx<0 && !strlen(language_path)) {
                // Caso no se encontró el "/" y ruta vacía
                return NULL;

        } else if (idx<0 && strlen(language_path)) {
                // No se encontró "/". Ruta relativa desde directorio actual
                return create_data(language_path);

        } else {
                // Casos con ruta absoluta
                return create_data_with_path(language_path, idx);
        }
}
