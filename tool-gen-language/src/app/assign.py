"""Asignación de lineas a regiones"""

import json

from app.constants import *
from app.lookup import find_words_by_id, get_splitted_lines_ids, get_max_id
from app.util import is_composite_region
from _ast import If
 

def trunk_lines(lines, words, region):
    """Divide las lineas que se extienden por varias columnas. Reasigna las palabras a las regiones 
    correspondientes"""
    if is_composite_region(region):
        return
    
    # Genera la información de la región principal
    #print(debug_tag + str(region))
    rs = {}
    rs[k_x_min] = region[k_cols][0][k_x_min]
    rs[k_x_max] = region[k_cols][-1][k_x_max]
    rs[k_y_min] = region[k_y_min]
    rs[k_y_max] = region[k_y_max]
    rs[k_lines] = []

    # Asigna todas las lineas que pertenecen a la region principal
    assign_words_to_regions_geometric(lines, rs, k_lines)

    # obtiene las lineas que ocupan varias columnas
    for line_id in rs[k_lines]:
        line = lines[line_id]
        splitted_lines = []
        for col_idx, col in enumerate(region[k_cols]):

            # La línea no comienza en esta columna
            if line[k_x_min] > col[k_x_max]:
                continue

            # La linea encaja exactamente en la columna
            if line[k_x_min] > col[k_x_min] and line[k_x_max] < col[k_x_max]:
                break

            # La linea se extiende más allá de la columna
            if line[k_x_min] > col[k_x_min] and line[k_x_max] > col[k_x_max]:
                
                # La splitted line (nueva línea) comienza en el mismo punto pero se extiende
                # solo hasta el final de la columna actual
                splitted_lines.append({k_x_min: line[k_x_min], k_x_max: col[k_x_max]})
                
                # La línea actual mantiene su punto final pero ahora comienza en la
                # siguiente columna 
                line[k_x_min] = region[k_cols][col_idx+1][k_x_min] + 1

        line[k_splits] = splitted_lines

    # trocea las lineas
    max_line_id = get_max_id(lines)

    splitted_lines_ids = get_splitted_lines_ids(lines)

    for splitted_lines_id in splitted_lines_ids:
        line = lines[splitted_lines_id]
        line_words = find_words_by_id(words, line[k_words])

        for coords in line[k_splits]:
            max_line_id += 1

            tmp = {k_x_min: coords[k_x_min], 
                   k_y_min: line[k_y_min], 
                   k_x_max: coords[k_x_max],
                   k_y_max: line[k_y_max], k_words: []}
            
            assign_words_to_regions_geometric(line_words, tmp, k_words)
            if tmp[k_words]:
                lines.append({k_id:max_line_id, 
                              k_x_min: coords[k_x_min], 
                              k_y_min: line[k_y_min], 
                              k_x_max: coords[k_x_max], 
                              k_y_max: line[k_y_max], 
                              k_words: [item for list_ in [[], tmp[k_words]] for item in list_]})

                for element in lines[-1][k_words]:
                    idx = line[k_words].index(element)
                    line[k_words].pop(idx)
            
        line[k_splits] = []

    #print(json.dumps(lines,  indent=2))



def assign_words_to_regions_geometric(elements, container, key):
    """Decide si un área rectangular está dentro, o parcialmente dentro, de otra"""
    F = 0.3
    for element in elements:
        x_length = (element[k_x_max] - element[k_x_min]) * F
        y_length = (element[k_y_max] - element[k_y_min]) * F

        case_a = [element[k_x_min] >= container[k_x_min],
                  element[k_x_max] <= container[k_x_max],
                  element[k_y_min] >= container[k_y_min],
                  element[k_y_max] <= container[k_y_max]]

        case_b = [element[k_x_max] > container[k_x_min],
                  element[k_x_max] <= container[k_x_max],
                  element[k_y_min] >= container[k_y_min],
                  element[k_y_max] <= container[k_y_max],
                  element[k_x_min] < container[k_x_min],
                  container[k_x_min] - element[k_x_min] < x_length]
            
        case_c = [element[k_x_min] >= container[k_x_min],
                  element[k_x_min] < container[k_x_max],
                  element[k_y_min] >= container[k_y_min],
                  element[k_y_max] <= container[k_y_max],
                  element[k_x_max] > container[k_x_max],
                  element[k_x_max] - container[k_x_max] < x_length] 
        
        case_d = [element[k_x_min] >= container[k_x_min],
                  element[k_x_max] <= container[k_x_max],
                  element[k_y_max] <= container[k_y_max],
                  element[k_y_min] < container[k_y_min],
                  element[k_y_max] > container[k_y_min],
                  container[k_y_min] - element[k_y_min] < y_length]
            
        case_e = [element[k_y_min] >= container[k_y_min],
                  element[k_y_min] < container[k_y_max],
                  element[k_y_max] > container[k_y_max],
                  element[k_x_min] >= container[k_x_min],
                  element[k_x_max] <= container[k_x_max],
                  element[k_y_max] - container[k_y_max] < y_length]
            
        case_f = [element[k_x_max] <= container[k_x_max],
                  element[k_x_max] > container[k_x_min],
                  element[k_y_max] <= container[k_y_max],
                  element[k_y_max] > container[k_y_min],
                  element[k_y_min] < container[k_y_min],
                  element[k_x_min] < container[k_x_min],
                  container[k_y_min] - element[k_y_min] < y_length,
                  container[k_x_min] - element[k_x_min] < x_length]
            
        case_g = [element[k_y_max] > container[k_y_min],
                  element[k_y_max] <= container[k_y_max],
                  element[k_x_min] >= container[k_x_min],
                  element[k_x_min] < container[k_x_max],
                  element[k_y_min] < container[k_y_min],
                  element[k_x_max] > container[k_x_max],
                  container[k_y_min] - element[k_y_min] < y_length,
                  element[k_y_max] - container[k_x_max] < x_length]

        case_h = [element[k_x_max] <= container[k_x_max],
                  element[k_x_max] > container[k_x_min],
                  element[k_y_min] >= container[k_y_min],
                  element[k_y_min] < container[k_y_max],
                  element[k_x_min] < container[k_x_min],
                  element[k_y_max] > container[k_y_max],
                  container[k_x_min] - element[k_x_min] < x_length,
                  element[k_y_max] - container[k_y_max] < y_length]

        case_i = [element[k_x_min] >= container[k_x_min],
                  element[k_x_min] < container[k_x_max],
                  element[k_y_min] >= container[k_y_min],
                  element[k_y_min] < container[k_y_max],
                  element[k_x_max] > container[k_x_max],
                  element[k_y_max] > container[k_y_max],
                  element[k_y_max] - container[k_y_max] < y_length,
                  element[k_x_max] - container[k_x_max] < x_length]
                
        if all(case_a):
            container[key] += [element[k_id]]
            continue
        if all(case_b):
            container[key] += [element[k_id]]
            continue
        if all(case_c):
            container[key] += [element[k_id]]
            continue
        if all(case_d):
            container[key] += [element[k_id]]
            continue
        if all(case_e):
            container[key] += [element[k_id]]
            continue
        if all(case_f):
            container[key] += [element[k_id]]
            continue
        if all(case_g):
            container[key] += [element[k_id]]
            continue
        if all(case_h):
            container[key] += [element[k_id]]
            continue
        if all(case_i):
            container[key] += [element[k_id]]
            continue
