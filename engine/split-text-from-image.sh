#!/usr/bin/env bash

# Locate files without text
# pdftotext returns a file containing only 0xOC characters (FORM FEED) on it if
# there is no text to be extracted. With hexdump and wc it's possible to filter
# those files

echo '-> Separa PDF basados en imágen de los de texto'

job_id="$1"

workload_dir="$input_dir/$job_id/based-text"
base_image_dir="$input_dir/$job_id/based-image"

shopt -s nullglob
for i in $workload_dir/*.txt
do
    number_lines=$(hexdump -e '1/1 "%02X\n"' $i | wc -l)
    if [ $number_lines -le 2 ]
    then
    	#echo ">$(hexdump -e '1/1 "%02X\n"' $i | tr '\n' ' ')<"
    	if [ "$(hexdump -e '1/1 "%02X\n"' $i | tr '\n' ' ')" = '0C ' ]
    	then
    	    mv $i $base_image_dir
    	elif [ "$(hexdump -e '1/1 "%02X\n"' $i | tr '\n' ' ')" = '0C * ' ]
    	then
    	    mv $i $base_image_dir
    	fi
    fi
done
shopt -u nullglob
