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

echo -n '-> Extrae imágenes de PDF'

# Se utiliza pdfimages -j para obtener la mejor calidad de imagen posible.
# No obstante, las imágenes resultantes no tienen por que ser las de la páginas
# completa del PDF. pdfimages extrae todo contenido almacenado como imagen en
# el fichero, incluidos logotipos, sellos, etc.

job_id="$1"
renamed_dir="$input_dir/$job_id/renamed"
ext='jpg'

extract_images() {
    shopt -s nullglob

    files=($1/*.txt)
    [ ${#files[@]} -lt 1 ] && echo && exit

    items="$(basename -s .txt -a $1/*.txt | sed 's_-.*__' | uniq)"
    for item in $items
    do
        echo -n '' $item
        pdf_file=$renamed_dir/$item.pdf
        (cd $1 && pdfimages -j $pdf_file $item)
        mkdir $1/$item
        mv $1/$item-*.$ext $1/$item
    done
    shopt -u nullglob
}

workload_dir="$input_dir/$job_id/based-image"
extract_images $workload_dir

rm $workload_dir/*.txt

echo # Añade \n
