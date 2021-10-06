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
