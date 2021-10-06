#!/usr/bin/env bash

# Crea los directorios necesarios para tratar un nuevo trabajo.

job_id=$(date -u +%s%6N)
job_id_dir="$input_dir/$job_id"

if [ ! -d "$job_id_dir" ]; then
    mkdir "$job_id_dir"
    mkdir "$job_id_dir/frontend"
    mkdir "$job_id_dir/decompressed"
    mkdir "$job_id_dir/based-image"
    mkdir "$job_id_dir/based-text"
    mkdir "$job_id_dir/renamed"
    mkdir "$job_id_dir/result"

    echo -n "$job_id"
fi
