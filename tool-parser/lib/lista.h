/*
 * GaliasDoc: information extraction from PDF sources with common templates
 * Copyright (C) 2021 Alfonso Landín Piñeiro
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

#ifndef LISTA_H
#define LISTA_H

#include <stdbool.h>

typedef struct lists_s {
    void    **contenido;
    int       len;
    int       max;
} lista;

/* Los elementos de la lista se indexan como los arrays en C,
 * i.e., son 0-based, los elementos de una lista de longitud n
 * se encuentran en el rango de índices de 0 a n-1
 */

/* Crea una nueva lista */
void nueva_lista(lista *l);

/* Crea una nueva lista con el tamaño indicado. */
void nueva_lista_tamano(lista *l, int tamano);

/* Añade un nuevo elemento al final de la lista */
void lista_append(lista *l, void *e);

/* Añade un nuevo elemento al principio de la lista */
void lista_prepend(lista *l, void *e);

/* Añade un elemento en la posición dada, desplazando los elementos
 * a partir de dicha posicion hacia adelante.
 * El comportamiento no está definido si la posición está
 * fuera del rango actual de la lista
 */
void lista_add(lista *l, int pos, void *e);

/* Elimina el elemento en la posicón dada, desplazando los elementos
 * a partir de dicha posición hacia atras.
 * El comportamiento no está definido si la posicón está fuera del
 * rango actual de la lista.
 */
void lista_delete(lista *l, int pos);

/* Obtiene el n-ésimo elemento de la lista.
 * Devuelve NULL si el índice está fuera de los límites.
 */
void * lista_get(lista l, int pos);

/* Establece el n-ésimo elemendo de la lista, sustituyendo el valor
 * anterior.
 * El comportamiento no está definido si la posición está
 * fuera del rango actual de la lista.
 */
void lista_set(lista l, int pos, void *e);


/* Libera la memoria de la lista.
 * Opcionalmente llamará a free sobre cada elemento de la lista si se le
 * pide, indicandolo por un valor true del segundo parámetro.
 */
void lista_free(lista *l, bool free_elementos);

/* Añade los contenidos de una segunda lista a la primera.
 * Al ser una lista de punteros los elementos no son duplicados, por lo que
 * los elementos añadidos a la primera lista apuntaran a los mismo elementos
 * que la segunda lista
 */
void lista_cat(lista *dest, lista src);

/* Operaciones para trabajar con la lista como si fuera una pila. No se define
 * push que es equivalente a append.
 *
 * Si la "pila" está vacía devuelven NULL.
 */
void * lista_peek(lista l);
void * lista_pop(lista *l);
#endif
