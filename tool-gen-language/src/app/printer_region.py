"""Métodos de impresión para las regiones"""

from app.constants import *
from app.lookup import find_words_by_line, find_actual_lines, find_line_by_id, find_header_region_t2
from app.util import sort_line_ids_by_height


def print_words(words, line_words_ids, word_type, current_page):
    res = ''
    for word_id in line_words_ids:
        #print('word_value: ' + str(words[word_id]['value']))
        res += ' ' + gen_sym_page + str(current_page) + gen_sym_word_separator + word_type + str(word_id) + gen_sym_word_separator + str(words[word_id][k_value]) + gen_sym_word_separator
    return res[1:]


def print_not_implemented(region, lines, words, current_page):
    return ''


def print_region_r1(region, lines, words, current_page):
    res = ''
    res += '\n\n'
    res += region[k_type] + gen_sym_start

    line_ids = []
    line_ids += region[k_cols][0][k_lines]
    line_ids += region[k_cols][1][k_lines]
    line_ids.sort() # ordena los ids para poder usar dict.fromkeys
    line_ids = list(dict.fromkeys(line_ids))

    # ordenación de los id por altura de las lineas
    aa = []
    for line_id in line_ids:
        aa.append({k_id: line_id, k_y_min: lines[line_id][k_y_min]})
    aa.sort(key=lambda e: (e[k_y_min]), reverse=False)

    for e in aa:
        line_id = e[k_id]
        if line_id in region[k_cols][0][k_lines]:
            res += '\n'
            line_words_ids = find_words_by_line(lines, line_id)
            res += print_words(words, line_words_ids, gen_sym_header, current_page)

        if line_id in region[k_cols][1][k_lines]:
            res += '\n'
            line_words_ids = find_words_by_line(lines, line_id)
            res += print_words(words, line_words_ids, gen_sym_word, current_page)
    res += '\n'
    res += region[k_type] + gen_sym_end
    
    return res


def print_region_r2(region, lines, words, current_page):
    res = ''
    res += '\n\n'
    res += region[k_type] + gen_sym_start

    empty_cols_idx = []
    for col_idx, col in enumerate(region[k_cols]):
        for line_idx,line_id in enumerate(col[k_lines]):
            if line_idx == 0: # caso primera fila (cabecera)
                if col_idx == 0:
                    res += '\n'
                res += ' ' + gen_sym_col_start + ' '
                line_words_ids = find_words_by_line(lines, line_id)
                res += print_words(words, line_words_ids, gen_sym_header, current_page)
                res += ' ' + gen_sym_col_end
                
                if len(col[k_lines]) == 1:
                    # En caso de tener una celda con cabecera pero sin datos en la siguiente fila,
                    # anotamos el id de la columna para generarlo posteriormente
                    empty_cols_idx.append(col_idx)

    for col_idx, col in enumerate(region[k_cols]):
        for line_idx,line_id in enumerate(col[k_lines]):
            
            if line_idx == 0 and col_idx in empty_cols_idx:
                # genera una celda vacía en esta columna
                res += ' ' + gen_sym_col_start + ' ' + gen_sym_col_end
                
            if line_idx > 0: # resto de filas
                if col_idx == 0:
                    res += '\n'
                res += ' ' + gen_sym_col_start + ' ' 
                line_words_ids = find_words_by_line(lines, line_id)
                res += print_words(words, line_words_ids, gen_sym_word, current_page)
                res += ' ' + gen_sym_col_end
    res += '\n'
    res += region[k_type] + gen_sym_end

    return res


def print_region_r3(region, lines, words, current_page):
    res = ''
    res += '\n\n'
    res += region[k_type] + gen_sym_start + ' \n'

    line_ids = []
    line_ids += region[k_cols][0][k_lines]
    line_ids_sorted = sort_line_ids_by_height(lines, line_ids)

    for line_id in line_ids_sorted:
        line_words_ids = find_words_by_line(lines, line_id)
        res += ' ' + print_words(words, line_words_ids, gen_sym_word, current_page)
    
    res += '\n'
    res += region[k_type] + gen_sym_end
    return res


def print_region_t1(region, lines, words, current_page):

    # Selecciona las lineas atendiendo a su altura
    doc = []
    actual_lines = find_actual_lines(lines, region[k_cols][1][k_lines])
    for actual_line in actual_lines:
        l = []
        for col in region[k_cols]:
            col_contents = []
            for line_id in col[k_lines]:
                line = find_line_by_id(lines, line_id)
                if line[k_y_min] >= actual_line[k_y_min] and line[k_y_max] <= actual_line[k_y_max]:
                    col_contents.append(line)
            l.append(col_contents)
        doc.append(l)
        
    # TODO el tratamiento de las líneas debe depender de la plantilla
    # Si en una fila, solo la columna central tiene contendo. Mueve el contenido
    # a la misma columna de la fila anterior
#    for idx, l in enumerate(doc):
#        if len(l[0]) == 0 and len(l[1]) == 1 and len(l[2]) == 0:
#            doc[idx-1][1].append(l[1][0])
#            doc.remove(l)
        
    res = '\n\n'
    res += region[k_type] + gen_sym_start + '\n'
    for idx, l in enumerate(doc):
        res += gen_sym_line_start
        for c in l:
            res += ' ' + gen_sym_col_start 
            for i in c:
                line_words_ids = find_words_by_line(lines, i[k_id])
                if not idx:
                    res += ' ' + print_words(words, line_words_ids, gen_sym_header, current_page)
                else:
                    res += ' ' + print_words(words, line_words_ids, gen_sym_word, current_page)
            res += ' ' + gen_sym_col_end
        res += ' ' + gen_sym_line_end + '\n'
    res += region[k_type] + gen_sym_end

    return res


def print_region_t2(region, lines, words, current_page):
    """Genera código para tablas divididas en celdas con el algoritmo de Hough"""
    res = '\n\n'
    res += region[k_type] + gen_sym_start + '\n'
    
    cells_idx = range(0, len(region[k_cols][0][k_cells]))
    cell_idx_header = find_header_region_t2(region, cells_idx)
    
    for cell_idx in cells_idx:
        res += gen_sym_line_start
        
        for col in region[k_cols]:
            res += ' ' + gen_sym_col_start 
            cell = col[k_cells][cell_idx]
            
            for line_id in cell[k_lines]:
                line_words_ids = find_words_by_line(lines, line_id)
                
                if cell_idx == cell_idx_header:
                    res += ' ' + print_words(words, line_words_ids, gen_sym_header, current_page)
                else:
                    res += ' ' + print_words(words, line_words_ids, gen_sym_word, current_page)
               
            res += ' ' + gen_sym_col_end
        res += ' ' + gen_sym_line_end  + '\n'
    res += region[k_type] + gen_sym_end
    
    return res
