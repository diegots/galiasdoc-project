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

"""Utilidades compartidas"""

import sys

from app.constants import *


def exit_with_error(message):
    """Finaliza el programa con un mensaje de error"""
    sys.exit(message)


def select_region_lines(region, lines):
    """Selecciona las lineas que están en una región, considerando únicamente la altura"""
    res = []
    for line in lines:
        if line[k_y_min] > region[k_y_min] and line[k_y_max] < region[k_y_max]:
            res.append(line)
    
    return res


def sort_line_ids_by_height(lines, line_ids):
    """Ordena una lista de ids, primero eje Y, después eje X"""
    line_ids.sort() # ordena los ids para poder usar dict.fromkeys
    line_ids = list(dict.fromkeys(line_ids))

    # ordenación de los id por altura de las lineas
    aa = []
    for line_id in line_ids:
        aa.append({k_id: line_id, k_x_min: lines[line_id][k_x_min], k_y_min: lines[line_id][k_y_min]})
    aa.sort(key=lambda e: (e[k_y_min], e[k_x_min]), reverse=False)
    
    ii = []
    for i in aa:
        ii.append(i[k_id])
    
    return ii


def filter_regions_by_page_number(regions, current_page, number_pages):
    """Filtra las regiones por número de página"""
    page_regions = []
    for region in regions:
        #print(debug_tag + 'region[\'page\']: ' + str(region['page']) + ', current_page: ' + str(current_page))
        if is_region_in_page(region[k_page], current_page, number_pages):
            page_regions += [region]
            
    return page_regions


def is_region_in_page(region_slice, current_page, number_pages):
    """Decide si la página actual se encuentra en el la región actual, de acuerdo a su slide"""
    if region_slice == page_fst and current_page == 1:
        return True

    doc_page_numbers = list(range(1, number_pages+1))
    
    if ":" in region_slice:
        actual_doc_page_numbers = eval(f"doc_page_numbers[{region_slice}]")
        return current_page in actual_doc_page_numbers
    
    # La región aplica solo a la última página
    if region_slice == page_last:
        return current_page == doc_page_numbers[int(region_slice)]


def page_number_to_default_format(page_number):
    """Convierte los números de página al formato utilizado para los ficheros de salida"""
    n = str(page_number - 1)
    if len(n) == 1:
        return '00' + n
    elif len(n) == 2:
        return '0' + n
    else:
        return n


def is_composite_region(region):
    """Decide si una región es compuesta o no. Una región compuesta es aquella que tiene definidos
    n conjuntos de columnas que derán lugar n regiones al ser procesados"""
    if region[k_type] == r_t2_t2:
        return True
    if region[k_type] == r_t2_t2_r1:
        return True
    
    return False

