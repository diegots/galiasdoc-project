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

echo '-> Realiza OCR'
# Example:
# ./scripts/image-apply-ocr.sh input-data

# Ficheros de entrenamiento para Tesseract
tessdata_dir="$base_dir/$app_dir/conf/tesseract-traindata-fast"
#tessdata_dir="$base_dir/$app_dir/conf/tesseract-traindata-best"

# Fichero de configuración de Tesseract
tessconfig_file="$base_dir/$app_dir/conf/tesseract.conf"

job_id="$1"
workload_dir="$input_dir/$job_id/based-image"
pdf_dir="$input_dir/$job_id/renamed"

ext='jpg'

shopt -s nullglob

for dir in $workload_dir/*
do
	#echo 'OCR file in directory' $dir
	dir_number="$(basename $dir)"
	for file_path in $dir/$dir_number*.$ext
	do
		#echo 'OCR file' "$(basename $file_path)"
		outputbase="$dir/$(basename -s .$ext $file_path)"

		echo -n " $(basename -s .$ext $file_path)"

		page_size="$(pdfinfo "$pdf_dir/$dir_number.pdf" | grep 'Page size:')"
		dots_width=$(echo -n $page_size | cut -d' ' -f3)
		dots_heigh=$(echo -n $page_size | cut -d' ' -f5)

		if [ "$(mediainfo $file_path | grep 'Image')" = "Image" ]; then
			px_width=$(mediainfo --Inform="Image;%Width%" $file_path)
			px_height=$(mediainfo --Inform="Image;%Height%" $file_path)
		fi

		x_ppi=$(echo "$px_width / ($dots_width * (1/72))" | bc -l | cut -d\. -f1)
		y_ppi=$(echo "$px_height / ($dots_heigh* (1/72))" | bc -l | cut -d\. -f1)

		tesseract $file_path "$outputbase" \
		        -l spa \
		        --dpi 300 \
		        --psm 11 \
		        -c page_separator='' \
		        --tessdata-dir "$tessdata_dir" \
		        $tessconfig_file
	done
done

echo '' # Añade salto de linea

shopt -u nullglob
