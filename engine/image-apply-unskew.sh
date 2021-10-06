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

echo '-> Corrige rotación'

# Example:
# ./scripts/correct_skew.sh input-data-dir

job_id="$1"
workload_dir="$input_dir/$job_id/based-image"
pdf_dir="$input_dir/$job_id/renamed"
ext='jpg'

shopt -s nullglob
for d in $workload_dir/*
do 
	dir_number=$(basename $d)

	for e in $d/$dir_number*.$ext
	do
		#echo '$e: ' $e
		file_name=$(echo -n $(basename $e) | cut -d\. -f1)
		#echo 'filename: ' $file_name
        #echo '$pdf_dir/$dir_number.pdf: ' $pdf_dir/$dir_number.pdf
        rot_ang="$(pdfinfo $pdf_dir/$dir_number.pdf | grep 'Page rot:' | cut -d: -f2 | sed 's_ __g')"
        convert $e -rotate $(($rot_ang-360)) $e 
		convert $e -deskew 80% "$d/$file_name-unskew.$ext"
	done
done
shopt -u nullglob

