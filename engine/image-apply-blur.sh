#!/usr/bin/env bash

echo '-> Aplica efecto blur'
# Example:
# ./scripts/apply-blur.sh input-data

job_id="$1"
workload_dir="$input_dir/$job_id/based-image"
ext='jpg'

shopt -s nullglob
for d in $workload_dir/*
do 
	dir_number=$(basename $d)

	for e in $d/$dir_number*-unskew.$ext
	do
		#echo '$e: ' $e
		file_name=$(echo -n $(basename $e) | cut -d\. -f1)
		#echo 'filename: ' $file_name
		convert $e -blur 1x1 "$d/$file_name-blur.$ext"
	done
done
shopt -u nullglob

