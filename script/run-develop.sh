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

# Configuración del entorno
conf_file='conf/engine-dev.sh'

show_help() {
    printf 'Este script muestra el funcionamiento de Galiasdoc.\n'
    printf 'Es necesario indicar la ruta a un ZIP con PDF como argumento.\n'
    exit 0
}

# Argumentos de entrada
if [ "$1" == "-h" ]; then show_help && exit 0; fi
if [ "$1" == "--help" ]; then show_help && exit 0; fi

[[ -z "$1" ]] && printf 'Error: no se indicó fichero de datos para tratar.\n' && exit 1

input_file=$1

printf '#--#--# Carga configuración del engine:\n'
#read -p ''
source $conf_file
printf '    - %s\n' $conf_file

printf '#--#--# Crea, si no existe, el directorio de datos:\n'
#read -p ''
mkdir -p $input_dir
printf '    - %s\n' $input_dir

printf '#--#--# Obtiene un nuevo directorio de trabajo:\n'
#read -p ''
job_id=$($app_dir/engine/get-job-id.sh)
printf '    - %s\n' $job_id

printf '#--#--# Simula la llegada de un ZIP con PDF:\n'
#read -p ''
cp $input_file $input_dir/$job_id/frontend
printf '    - Copiado %s a %s\n' $1 $input_dir/$job_id/frontend

printf '#--#--# Procesa el job en el engine:\n'
#read -p ''
$app_dir/engine/run.sh $job_id
printf '    - ENGINE END\n'

#printf '#--#--# Borra directorio datos:'
#read -p ''
#rm -rf $input_dir
#printf '    - Borra %s\n' $input_dir

printf '#--#--# FIN\n'
