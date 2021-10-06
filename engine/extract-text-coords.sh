#!/usr/bin/env bash

echo '-> Extrae coordenadas del texto'

job_id="$1"

workload_dir="$input_dir/$job_id/based-text"
pdf_dir="$input_dir/$job_id/renamed"

two_zeroes='00'
one_zero='0'

shopt -s nullglob

paths=(`find $workload_dir -maxdepth 1 -name "*.txt"`)
if [ ${#paths[@]} -gt 0 ]; then
    items="$(basename -s .txt -a ${paths[@]}| sed 's_-.*__' | sort | uniq)"
fi

for number in $items
do
    pdf_file="$pdf_dir/$number.pdf"
    last_page="$(pdfinfo $pdf_file | grep 'Pages:' | cut -c 7- | sed 's_ *__')"

    mkdir $workload_dir/$number

    for ((page=1; page<=$last_page; page++))
    do
        page_number="$(($page-1))"
        if [ ${#page_number} -eq 1 ]
        then
            #echo $two_zeroes$page_number
            page_number=$two_zeroes$page_number
        elif [ ${#page_number} -eq 2 ]
        then
            #echo $one_zero$page_number
            page_number=$one_zero$page_number
        else
            echo 'page_number length NOT SUPPORTED'
        fi

        pdftotext -r 300 -f $page -l $page -bbox-layout "$pdf_file" - > \
                $workload_dir/$number/"$number-$page_number.xml"
    done

    # Move txt files to their destination directories
    mv $workload_dir/$number-*.txt $workload_dir/$number

done
shopt -u nullglob
