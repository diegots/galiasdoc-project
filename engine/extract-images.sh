#!/usr/bin/env bash

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
