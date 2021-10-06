#!/usr/bin/env bash

# Configuración del entorno
conf_file='/app/conf/engine.sh'
source $conf_file

show_help() {
    printf 'Es necesario indicar el id del job que se quiere ejecutar\n'
    exit 0
}

# Argumentos de entrada
if [ "$1" == "-h" ]; then show_help && exit 0; fi
if [ "$1" == "--help" ]; then show_help && exit 0; fi

[[ -z "$1" ]] && printf 'Error: no se indicó el id del job\n' && exit 1

job_id=$1

# Procesa el job en el engine
$app_dir/engine/run.sh $job_id

