#!/usr/bin/env bash

# GaliasDoc: information extraction from PDF sources with common templates
# Copyright (C) 2021 Diego Trabazo Sardón
#
# This file is part of GaliasDoc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>

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
