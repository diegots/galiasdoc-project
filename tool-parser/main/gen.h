#ifndef GEN_H
#define GEN_H

#include "lista.h"
#include "app-conf.h"
#include "types.h"

void gen_contents(lista regions, app_config *app_config);

/*
 * Corrige la numeración de salida de las páginas en el caso de documentos que
 * se tratan globalmente. El valor devuelto debe ser liberado con free.
 *
 * read_page_value: puede ser 'xxx' para documentos globales u otro valor ya corregido
 * current_page: número de página actual: 1, 2, etc.
 */
char *fix_page_number(char *read_page_value, int current_page);

/*
 * Vuelca contents a un fichero en file_path. Si el fichero no
 * existe lo crea, si ya existe realiza append.
 */
void write_file_out(char *file_path, char *contents);

#endif
