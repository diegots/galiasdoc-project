#!/usr/bin/env bash

echo '-> Extrae texto y reubica ficheros'

job_id="$1"

workload_dir="$input_dir/$job_id/decompressed"
renamed_dir="$input_dir/$job_id/renamed"
based_text_dir="$input_dir/$job_id/based-text"
result_dir="$input_dir/$job_id/result"

found_pdf_log="$input_dir/found-pdf-files.txt"

two_zeroes='00'
one_zero='0'

# Find paths for all received PDF files
find $workload_dir/ -regextype sed -regex "^.*\.[pP][dD][fF]$" \
    | sort -df > $found_pdf_log

# Rename files
file_number=1
while IFS= read -r line; do
    echo "$line" >> $result_dir/$file_number.name
    mv "$line" $renamed_dir/$file_number.pdf
    ((file_number++))
done < $found_pdf_log

find $renamed_dir -regextype sed -regex "^.*\.[pP][dD][fF]$" \
    | sort -df > $found_pdf_log

# Extract text from every file, if there is text to be extracted
while IFS= read -r line; do
    #echo "Text read from file: $line"
    n="$(basename $line | cut -d\. -f1)"
    last_page="$(pdfinfo $line | grep 'Pages:' | cut -c 7- | sed 's_ *__')"
    for ((page=1; page<=$last_page; page++))
    do
        page_number="$($engine_dir/fix-page-numbers.sh $page)"
        pdftotext -f $page -l $page -layout "$line" "$based_text_dir/$n-$page_number.txt"
    done
done < $found_pdf_log

rm $found_pdf_log
rm -rf $workload_dir

shopt -u nullglob
