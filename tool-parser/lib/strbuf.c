/*
 * strbuf.c - Un buffer para cadenas de caracteres que crece de tamaño de
 *            manera automática.
 *
 * La implementación usa un bloque de memoria al que se accede a traves de
 * un puntero char*. Los primeros "sizeof(int)" (lo normal 4) contienen el
 * tamaño del bloque, estando la cadena a partir de ahí, siendo una cadena
 * teminada en '\0' como es estándar en C. Las funciones de manejos de
 * cadenas de la librería estándar de C pueden trabajar con esta parte sin
 * problema.
 *
 * Se crean dos macros que permiten acceder a ambas partes del bloque:
 *   - SIZE(buf): traduce a "int" la parte del bloque que almacena el
 *                tamaño del mismo, para poder hacer los calculos que
 *                dependan de este tamaño.
 *   - STR(buf): devuelve un puntero a la cadena contenida en el buffer
 *               que puede ser usada por cualquier función que acepte
 *               char* terminados en '\0'. Para ello calcula la posición
 *               de memoria del byte "sizeof(int)" del bloque (i.e. "&(buf[4])").
 *               Esta expresión es de tipo char*.
 *
 * Para implementar la funcionalidad calcula cuál serñia el tamaño resultante
 * de la cadena tras realizar la operación y si el tamaño del bloque no es su-
 * ficiente para almacenar el resultado aumenta el tamaño del buffer hasta que
 * lo sea.
 *
 * La única excepción es en el caso de strbufprintf, donde no es posible cal-
 * cular de manera cómoda cual es el tamaño final sin realizar la llamada a
 * snprintf, por lo que usa un bloque local que aumenta de tamaño hasta que
 * entre el resultado, que despues concatena al buffer pasado antes de devol-
 * verlo.
 */

#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

#include "strbuf.h"

#define MIN_CAPACITY 128

#define MAX_BUF 256

/* La cadena propiamente dicha */
#define STR(b) (&((b)[sizeof(int)]))
/* Tamaño del trozo de memoria usado */
#define SIZE(b) (*((int*) (b)))

strbuf strbufnew() {
    int s = sizeof(char) * MIN_CAPACITY + sizeof(int);
    strbuf res;
    if ( (res = malloc(s)) == NULL) {
        perror("strbufnew");
        exit(EXIT_FAILURE);
    }
    SIZE(res) = s;
    STR(res)[0] = '\0';
  
    return res;
}

strbuf strbufnew_ensuring(int capacity) {
    int s = sizeof(char) * capacity + sizeof(int);
    strbuf res;
    if ( (res = malloc(s)) == NULL) {
        perror("strbufnew");
        exit(EXIT_FAILURE);
    }
    SIZE(res) = s;
    STR(res)[0] = '\0';

    return res;
}

strbuf strbufdup(const char* src) {
    int s = strlen(src) + 1 + sizeof(int);
    strbuf res;
    if ( (res = malloc(s)) == NULL) {
        perror("strbufnew");
        exit(EXIT_FAILURE);
    }
    SIZE(res) = s;
    strcpy(STR(res), src);

    return res;
}

strbuf grow(strbuf buf) {
    int s = SIZE(buf);
    int new_s = s * 2;
    strbuf new_buf = malloc(new_s);
    memcpy(new_buf, buf, s);
    SIZE(new_buf) = new_s;
    free(buf);

    return new_buf;
}

strbuf strbufncat(strbuf dest, const char* src, int n) {
    int l = strlen(STR(dest)) + n + 1;

    while (l > (SIZE(dest) - sizeof(int))) {
        dest = grow(dest);
    }

    strncat(STR(dest), src, n);

    return dest;
}

strbuf strbufcat(strbuf dest, const char* src) {
    return strbufncat(dest, src, strlen(src));
}

strbuf strbufprintf(strbuf buf, const char* fmt, ...) {
    char buffer[MAX_BUF];
    int l;
    va_list ap;
    
    va_start(ap, fmt);
    l = vsnprintf(buffer, MAX_BUF, fmt, ap);
    va_end(ap);
    
    if (l < 0) {
        perror("strbufprintf");
        exit(EXIT_FAILURE);
    }
    
    if (l >= MAX_BUF) {
        int tam = MAX_BUF;
        char *d_buffer = NULL;
        while (l >= tam) {
            free(d_buffer);
            tam = l + 1;
            d_buffer = malloc(sizeof(char) * tam);
            if (d_buffer == NULL) {
                perror("strbufprintf");
                exit(EXIT_FAILURE);
            }
            va_start(ap, fmt);
            l = vsnprintf(d_buffer, tam, fmt, ap);
            va_end(ap);
            if (l < 0) {
                perror("strbufprintf");
                exit(EXIT_FAILURE);
            }
        }
        buf = strbufcat(buf, d_buffer);
        free(d_buffer);
    } else {
        buf = strbufcat(buf, buffer);
    }
    
    return buf;
}

char * strbuf2str(strbuf buf) {
    return STR(buf);
}

char * strbuf2str_dup(strbuf buf) {
    return strdup(STR(buf));
}

