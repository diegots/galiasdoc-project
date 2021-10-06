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

# Ejecución del engine

job_id="$1"

$engine_dir/unpack.sh $job_id
$engine_dir/extract-text.sh $job_id
$engine_dir/split-text-from-image.sh $job_id
$engine_dir/extract-images.sh $job_id
$engine_dir/extract-text-coords.sh $job_id
$engine_dir/generate-images-for-text-based.sh $job_id
$engine_dir/image-apply-ocr.sh $job_id
$engine_dir/identify-grep.sh $job_id
$engine_dir/generate-json.sh $job_id
$engine_dir/populate-result.sh $job_id
