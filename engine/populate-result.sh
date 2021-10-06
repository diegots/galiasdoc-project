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
