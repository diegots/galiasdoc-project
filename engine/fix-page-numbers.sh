#!/usr/bin/env bash

two_zeroes='00'
one_zero='0'

fix_page_number() {
    page_number="$(($1-1))"

    # Ahora añade padding conociendo la longitud del string page_number
    if [ ${#page_number} -eq 1 ]
    then
        echo $two_zeroes$page_number

    elif [ ${#page_number} -eq 2 ]
    then
        echo $one_zero$page_number

    else
        echo $page_number
    fi
}

[ $1 -lt 1 ] || [ $1 -gt 1000 ] && echo 'Número de página no soportado. Valores admitidos entre 1 y 1000' && exit 1

fix_page_number $1
