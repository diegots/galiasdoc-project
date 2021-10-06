#!/usr/bin/env bash

echo '-> Genera imágenes para los based-text PDF'

job_id="$1"

renamed_dir="$input_dir/$job_id/renamed"
workload_dir="$input_dir/$job_id/based-text"

shopt -s nullglob
# Genera las imágenes con pdftocairo
for i in $workload_dir/*
do
    doc_number="$(basename -s .txt $i)"
    pdftocairo -q -r 300 -jpeg $renamed_dir/$doc_number.pdf $renamed_dir/$doc_number
done

# Mueve los ficheros generados a $workload_dir. Ajusta nombres
for i in $renamed_dir/*.jpg; do
    file_prefix="$(basename -s .jpg $i)"
    doc_number="$(echo -n $file_prefix | sed 's_-[0-9]*__')"
    p="$(echo -n $file_prefix | sed 's_^[0-9]*-__')"
    page_number="$($engine_dir/fix-page-numbers.sh $p)"
    mv $i $workload_dir/$doc_number/$doc_number-$page_number.jpg
done

shopt -u nullglob
