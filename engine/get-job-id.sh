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
