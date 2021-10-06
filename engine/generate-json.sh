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

# Parámetros de entrada al programa
# $1: job_id
#

echo '-> Genera json'

process_coords="$base_dir/$app_dir/tool-gen-language/main.py"
parser="$base_dir/$app_dir/tool-parser/parser"
plugin_dir="$base_dir/$app_dir/tool-parser/plugin"
renamed_dir="$input_dir/$1/renamed"
workload_dir=''
parser_type=''

# $1: text-based or image-based working dir
# $2: parser_type for coords handling
run() {
    shopt -s nullglob

    #echo '$1:' $1
    #echo '$2:' $2

    for path in $1/*
    do

        dir_number="$(basename $path)"
        id_file=$path/$dir_number.id
        [ ! -f $id_file ] && echo -n ' !'$dir_number && continue

        # localiza el template de la página
        template_file="$base_dir/$app_dir/data/templates/template-$(<$id_file).json"
        [ ! -s $template_file ] && echo -n ' !'$dir_number && continue

        is_global="$(jq '.is_global' $template_file)"

        # obtiene el número total de páginas del documento
        number_pages="$(pdfinfo $renamed_dir/$dir_number.pdf | grep 'Pages:' | cut -c 7- \
                | sed 's_ *__')"

        echo -n '' $dir_number'('

        for coords_file in $path/$dir_number-*.{xml,hocr}
        do
            # obtiene el número de página tratado
            page_number="$(basename $coords_file | sed 's@.*-pag-@@' | sed 's@\..*$@@')"

            # genera texto intermedio
            file_name_prefix="$(basename $coords_file | sed 's@\..*$@@')"
            output_base="$path/$file_name_prefix-"

            $process_coords $2 $coords_file $template_file $output_base $number_pages \
                    $path/$page_number.jpg -w 'GENERATE'

            language_file="$path/$file_name_prefix-language.txt"
            [ ! -f $language_file ] && echo -n ' !'$page_number && continue
            echo -n ' '$page_number

            # genera json de la página si no es un documento global
            [ "$is_global" == "false" ] && \
                $parser -i $language_file -t $id_file -p "$plugin_dir/$(<$id_file)"

            #jq -s '.' $path/$dir_number-*.json > $path/$dir_number.json
        done

        # genera json de los documentos globales
        if [ "$is_global" == "true" ]
        then
            for f in $path/*-language.txt; do cat $f >> $path/$dir_number-xxx-language.txt; done
            $parser -i $path/$dir_number-xxx-language.txt -t $id_file -p "$plugin_dir/$(<$id_file)"
        fi

        echo -n ' )'
    done

    shopt -u nullglob
    echo # Añade \n a la salida final
}

# Variables para los casos de texto
workload_dir="$input_dir/$1/based-text"
parser_type='XML'
run $workload_dir $parser_type

# Casos de imagen
workload_dir="$input_dir/$1/based-image"
parser_type='HOCR'
run $workload_dir $parser_type

# Marca el job como finalizado
touch "$input_dir/$1/done-$(date -u +%s%6N)"
