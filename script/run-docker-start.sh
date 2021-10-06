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

