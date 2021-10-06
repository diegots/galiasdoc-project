#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "lista.h"

#define TAMANO_INICIAL 10

void nueva_lista_tamano(lista *l, int tamano) {
    /* Si se solicita una lista de tamaño 0 no se asigna memoria para el
     * array de punteros.
     */
	if (0 == tamano)
		l->contenido = NULL;
	else
		l->contenido = calloc(sizeof(void*), tamano);
    l->len = 0;
    l->max = tamano;
}

void nueva_lista(lista *l) {
    nueva_lista_tamano(l, TAMANO_INICIAL);
}

/* Aumenta la capacidad máxima de la lista */
void expandir(lista *l) {
    void *temp = l->contenido;

    /* La lista crece de forma geométrica. Si la lista era de tamaño cero la
     * primera expanxión la convierte en una lista de tamaño máximo 1.
     */
    if (l->max == 0) {
        l->max = 1;
    } else {
        l->max *= 2;
    }

    if ((l->contenido = calloc(sizeof(void*), l->max)) == NULL) {
        perror("no se pudo extender la lista");
        exit(EXIT_FAILURE);
    }

    /* Copiamos los punteros en el viejo array al nuevo array */
    memcpy(l->contenido, temp, sizeof(void*) * l->len);

    free(temp);
}

void lista_append(lista *l, void *e) {
    /* Si la lista ya estaba en su capacidad máxima aumentamos la capacidad */
    if (l->len >= l->max)
        expandir(l);
    /* Aumentamos la longitud de la lista al mismo tiempo que añadimos el
     * puntero del nuevo elemento. El operador de postincremento permite que
     * hagamos esta operacion en una sola sentencia.
     */
    l->contenido[(l->len)++] = e;
}

void *lista_get(lista l, int p) {
    if (p < 0 || p > (l.len - 1))
        return NULL;
    return l.contenido[p];
}

void lista_set(lista l, int p, void *e) {
    if (p < 0 || p > (l.len - 1))
        return;
    l.contenido[p] = e;
}

void lista_free(lista *l, bool free_elementos) {
    if (free_elementos) {
        int i;
        for (i = 0; i < l->len; i++) {
            free(l->contenido[i]);
        }
    }
    free(l->contenido);
}

void lista_prepend(lista *l, void *e) {
    lista_add(l, 0, e);
}

void lista_add(lista *l, int p, void *e) {
    if (p < 0 || p > l->len)
        return;
    
    if (p == l->len)
        lista_append(l, e);
    else {
        if (l->len >= l->max)
            expandir(l);
        /* Movemos los punteros desde la posicion donde se esta añadiendo el
         * elemento nuevo en adelante a la posición siguiente del array de
         * punteros.
         */
        memmove(&l->contenido[p+1], &l->contenido[p],
                sizeof(void *) * ((l->len) - p));
        (l->len)++;
        l->contenido[p] = e;
    }
}

void lista_delete(lista *l, int p) {
    /* Si el índice está fuera del rango de la lista no hacemos nada */
    if (p < 0 || p >= l->len)
        return;


    if (p == l->len - 1) {
        /* Borrar la última posición supone simplemente disminuir la longitud
         * de la lista.
         */
        (l->len)--;
    } else {
        /* Mover todos los elementos en las posiciones siguientes una posición
         * para atrás.
         */
        memmove(&l->contenido[p], &l->contenido[p+1],
                sizeof(void *) * ((l->len) - (p+1)));
        (l->len)--;
    }
}

void lista_cat(lista *dest, lista src) {
    int i;
    
    /* Añadimos los elementos de la lista de origen uno a uno a la lista de
     * destino.
     *
     * TODO: usar memcpy para hacer esto de forma más eficiente.
     */
    for (i = 0; i < src.len; i++)
        lista_append(dest, lista_get(src, i));
}

/* Operaciones para trabajar con la lista como si fuera una pila. No se define
 * push que es equivalente a append.
 *
 * Si la "pila" está vacía devuelven NULL.
 */
void * lista_peek(lista l) {
    if (l.len <= 0)
        return NULL;
    else
        return l.contenido[l.len - 1];
}

void * lista_pop(lista *l) {
    if (l->len <= 0)
        return NULL;
    else
        /* Usar el operador de predecremento permite disminuir la longitud de
         * la lista al mismo tiempo que accedemos al último elemento.
         */
        return l->contenido[--(l->len)];
}

