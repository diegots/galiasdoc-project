#!/usr/bin/env bash

echo '-> Agrupa resultados'

job_id="$1"

result_dir="$input_dir/$job_id/result"
renamed_dir="$input_dir/$job_id/renamed"

# Mueve ficheros generados
shopt -s nullglob
for f in input/*/based-*/*/*{lines,words,selected,amounts,table}*
do
    mv $f $result_dir
done

# Mueve imágenes de las páginas
for f in input/*/based-*/*/*.jpg
do
    mv $f $result_dir
done

shopt -u nullglob
