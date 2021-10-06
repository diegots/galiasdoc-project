#ifndef STRBUF_H
#define STRBUF_H

#ifndef __GNUC__
#  define  __attribute__(x)  /*NOTHING*/
#endif

typedef char* strbuf;

/* Crea un nuevo strbuf.
 * La memoria creada se puede liberar con free.
 */
strbuf strbufnew();

/* Crea un nuevo strbuf con la capacidad indicada.
 * Esta capacidad incluye el \0 al final pero no cualquier
 * otra necesidad de memoria del buffer.
 * La memoria crear se puede liberar con free.
 */
strbuf strbufnew_ensuring(int c);

/* Copia el string a un nuevo strbuf.
 * La memoria creada puede ser liberada con free.
 */
strbuf strbufdup(const char *src);

/* Añade el string al final del strbuf
 * La memoria usada por el strbuf pasado puede no ser válida a
 * la vuelta. Usar siempre el strbuf devuelto. E.g.:
 *     strbuf buf = strbufnew();
 *     buf = strbufcat(buf, "hola");
 */
strbuf strbufcat(strbuf dest, const char *src);

/* Añada el string al final del strbuf, copiando como máximo n
 * chars del string de origen.
 * La memoria usada por el strbuf pasado puede no ser válida a
 * la vuelta. Usar siempre el strbuf devuelto. E.g.:
 *     strbuf buf = strbufnew();
 *     buf = strbufncat(buf, "hola", 3);  // buf contiene "hol"
 */
strbuf strbufncat(strbuf dest, const char *src, int n);

/* Añade la cadena despues de aplicarle el formato con sprintf.
 * Si el compilador es GCC este checkea que el número y el tipo
 * de los argumentos se corresponda con el formato de la cadena.
 * La memoria usada por el strbuf pasado puede no ser válida a
 * la vuelta. Usar siempre el strbuf devuelto. E.g.:
 *     strbuf buf = strbufnew();
 *     buf = strbufprintf(buf, "hola %s", "Manuel");
 */
strbuf strbufprintf(strbuf dest, const char *format, ...) __attribute__ ((format (printf, 2, 3)));

/* Devuelve un string terminado en null standard de C.
 * No se debe llamar free a la memoria devuelta por esta función.
 * Usar strbuf2str_dup para obtener una cadena cuya memoria deba ser
 * manejada de la manera standard a las creadas por las funciones de
 * string.h.
 *
 * Esta función es util cuando se desea pasar el contenido del strbuf
 * a otra función que realiza una copia de los char* que recibe. Usar
 * esta funcion evita la realización de una copia extra que ademas
 * ha de ser liberada. Comparar el ejemplo respecto a como se haría con
 * strbuf2str_dup:
 *
 * 		strbuf buf = strbufdup("Manuel");
 * 		printf("hola %s", strbuf2str(buf);   // No es necesario manejar el char* devuelto.
 *
 * 		strbuf buf2 = strbufdup("Marta");
 * 		char *copia = strbuf2str_dup(buf2);  // Realiza una copia.
 * 		printf("hola %s", copia);
 * 		free(copia);                         // Es necesario liberar la copia.
 */
char * strbuf2str(strbuf src);

/* Devuelve una copia del string contenido en el buffer.
 * La memoria devuelta por esta función es independiente de la memoria
 * del strbuf y ha de ser manejada independientemente (i.e. ha de ser
 * liberada de forma independiente a la liberación de la memoria del
 * strbuf).
 */
char * strbuf2str_dup(strbuf src);

#endif
