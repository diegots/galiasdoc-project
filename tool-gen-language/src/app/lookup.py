""" Métodos de búsqueda"""

from app.constants import *


def get_max_id(data):
    """Busca en una lista de elementos aquel con mayor valor para una clave"""
    max_id = 0
    for entry in data:
        if entry[k_id] > max_id:
            max_id = entry[k_id]
    return max_id

def get_splitted_lines_ids(lines):
    """Recorre las lineas seleccionando los id que contienen la clave k_splits"""
    splitted_lines_ids = []
    for line in lines:
        if k_splits in line and len(line[k_splits]):
            splitted_lines_ids.append(line[k_id])
    return splitted_lines_ids


def find_actual_lines(lines, col_lines):
    actual_lines = []
    for line_in_col in col_lines:
        for line in lines:
            if line_in_col == line[k_id]:
                actual_lines.append({k_y_min: line[k_y_min], k_y_max: line[k_y_max]})

    return actual_lines


def find_line_by_id(lines, line_id):
    for line in lines:
        if line[k_id] == line_id:
            return line


def find_header_region_t2(region, cells_idx):
    """Busca el índice de celda que contendré los strings de la cabecera"""
    for cell_idx in cells_idx:
        for col in region[k_cols]:
            cell = col[k_cells][cell_idx]
            if cell[k_lines]:
                return cell_idx            


def find_words_by_line(lines, line_id):
    for line in lines:
        if line[k_id] == line_id:
            return line[k_words]


def find_word_value_ocurrences(words, value):
    """Encuentra todas las apariciones de un texto en el conjunto de las palabras"""
    res = []
    for word in words:
        if word[k_value] == value:
            res.append(word)
    
    return res


def find_words_by_id(words, ids):
    """Encuentra todas las palabras referidas en una lista de ids"""
    res = []
    for id_ in ids:
        res.append(words[id_])
    return res
