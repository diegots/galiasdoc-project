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

echo '-> Identifica documentos por NIF/CIF'

job_id="$1"

# Array para almacenar los identificadores conocidos
ids_=()

# Almacena los identificadores como expresiones regulares
read_identifiers() {
    while IFS= read -r line; do
        # Add id if line has contents
        [ ! -z $line ] && ids_+=("$(echo -n $line | sed 's_._.*&_g' | cut -c 3-)")
    done < $1
}

read_identifiers "$base_dir/$app_dir/data/id-cif*"
read_identifiers "$base_dir/$app_dir/data/id-nif*"
echo '    - Cargado(s)' ${#ids_[@]} 'identificador(es)'

# Obtiene la lista de ficheros con texto extraido
shopt -s nullglob
files="$(echo $input_dir/$job_id/based-*/*/*.{hocr,txt})"
shopt -u nullglob

for file in $files
do

    # En el caso de los ficheros basados en imagen, se podría hacer el grep sobre cada página
    # guardando todos los resultados. Finalmente se puede utilizar algún algoritmo que *decida*
    # cual de los identificadores es el correcto.

    number="$(basename -s .txt $file | sed 's_-.*$__g')"
    dir_name="$(dirname $file)"

    # Parámetros usados en grep:
    # -w: selecciona líneas que contienen matches sobre palabras completas, no partes
    # -c: la salida de grep es el número de ocurrencias

    for id_ in "${ids_[@]}"; do
        if [ "$(grep -w -c "$id_" $file)" -ge 1 ]; then
            #echo 'Found id: "'$id_'" in file: "'$file'"'
            echo $id_ | sed -E 's_\*|\.__g' > $dir_name/$number.id
            break
        fi
    done
done
