#!/usr/bin/env bash

echo '-> Desempaqueta ficheros'

job_id="$1"
workload_dir="$input_dir/$job_id/frontend"
decompress_dir="$input_dir/$job_id/decompressed"

shopt -s nullglob
for f in $workload_dir/*.zip; do unzip -q $f -d $decompress_dir && rm $f; done

rm -rf $workload_dir

shopt -u nullglob

