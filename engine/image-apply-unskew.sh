#!/usr/bin/env bash

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

