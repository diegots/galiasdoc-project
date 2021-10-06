"""Tratamiento de las regiones"""

import copy

from app.assign import assign_words_to_regions_geometric, trunk_lines
from app.constants import *
from app.hough import get_lines_with_hough
from app.lookup import find_word_value_ocurrences
from app.printer_region import print_not_implemented
from app.printer_region import print_region_r1 
from app.printer_region import print_region_r2
from app.printer_region import print_region_r3
from app.printer_region import print_region_t1
from app.printer_region import print_region_t2
from app.util import select_region_lines
from app.util import filter_regions_by_page_number


class R1:
    """
    | header_1 | content_row_1 |
    |----------|---------------|
    | header_2 | content_row_2 |
    | header_3 | content_row_3 |
    | ...      | ...           |
    | header_n | content_row_n |
    """
    def __init__(self, page_region):
        self.page_region = page_region
        self.r_col0 = {k_x_min: page_region[k_cols][0][k_x_min], k_x_max: page_region[k_cols][0][k_x_max], k_y_min: page_region[k_y_min], k_y_max: page_region[k_y_max], k_lines:[]}
        self.r_col1 = {k_x_min: page_region[k_cols][1][k_x_min], k_x_max: page_region[k_cols][1][k_x_max], k_y_min: page_region[k_y_min], k_y_max: page_region[k_y_max], k_lines:[]}


    def assign_lines(self, lines):
        assign_words_to_regions_geometric(lines, self.r_col0, k_lines)
        assign_words_to_regions_geometric(lines, self.r_col1, k_lines)
        
        self.page_region[k_cols][0][k_lines] = self.r_col0[k_lines]
        self.page_region[k_cols][1][k_lines] = self.r_col1[k_lines]
        self.page_region[k_text_generator] = print_region_r1


    def print_text(self):
        print(debug_tag + 'self.r_col0' + str(self.r_col0))
        print(debug_tag + 'self.r_col1' + str(self.r_col1))


class R2:
    """
    | header_1      | header_2      | header_3      | ... | header_n      |
    |---------------|---------------|---------------|-----|---------------|
    | content_row_1 | content_row_2 | content_row_3 | ... | content_row_n |
    """
    def __init__(self, page_region):
        self.page_region = page_region
        self.cols = []
        for x_coord in page_region[k_cols]:
            self.cols.append({k_x_min: x_coord[k_x_min], k_x_max: x_coord[k_x_max], k_y_min: page_region[k_y_min], k_y_max: page_region[k_y_max], k_lines:[]})


    def assign_lines(self, lines):
        for col in self.cols:
            assign_words_to_regions_geometric(lines, col, k_lines)
        
        self.page_region[k_text_generator] = print_region_r2
        for col_idx,col in enumerate(self.cols):
            self.page_region[k_cols][col_idx][k_lines] = col[k_lines]
    
            
    def print_text(self):
        for col_idx, col in enumerate(self.cols):
            print(debug_tag + 'col' + str(col_idx) + ', ' + str(col))


class R3:
    """
    | contents |
    |----------|
    
    La región R3 es una región formada por una única celda. Para contenidos secuenciales"""
    
    def __init__(self, page_region):
        self.page_region = page_region
        self.r_col = {k_x_min: page_region[k_cols][0][k_x_min], 
                       k_x_max: page_region[k_cols][0][k_x_max], 
                       k_y_min: page_region[k_y_min], 
                       k_y_max: page_region[k_y_max], 
                       k_lines:[]}
    
        
    def assign_lines(self, lines):
        assign_words_to_regions_geometric(lines, self.r_col, k_lines)
        self.page_region[k_cols][0][k_lines] = self.r_col[k_lines]
        
        self.page_region[k_text_generator] = print_region_r3


class T1:
    """
    | header_1    | header_2    | header_3    | ... | header_n    |
    |-------------|-------------|-------------|-----|-------------|
    | content_row | content_row | content_row | ... | content_row |
    | content_row | content_row | content_row | ... | content_row |
    | content_row | content_row | content_row | ... | content_row |
    | content_row | content_row | content_row | ... | content_row |
    """
    def __init__(self, page_region):
        self.page_region = page_region
        self.cols = []
        for x_coord in page_region[k_cols]:
            self.cols.append({k_x_min: x_coord[k_x_min], 
                              k_x_max: x_coord[k_x_max], 
                              k_y_min: page_region[k_y_min], 
                              k_y_max: page_region[k_y_max], 
                              k_lines:[]})

    
    def assign_lines(self, lines):
        for col in self.cols:
            assign_words_to_regions_geometric(lines, col, k_lines)
        
        self.page_region[k_text_generator] = print_region_t1
        for col_idx,col in enumerate(self.cols):
            self.page_region[k_cols][col_idx][k_lines] = col[k_lines]
            

class T2:
    """
    | header_1    | header_2    | header_3    | ... | header_n    |
    |-------------|-------------|-------------|-----|-------------|
    | content_row | content_row | content_row | ... | content_row |
    | content_row | content_row | content_row | ... | content_row |
    | content_row | content_row | content_row | ... | content_row |
    | content_row | content_row | content_row | ... | content_row |

    En la región T2, los límites entre filas se calculan por medio de la transformada de Hough."""

    def __init__(self, page_region, page_image_path):
        self.page_region = page_region
        self.cells = []
        self.cols = []
        self.vertical_lines = get_lines_with_hough(page_image_path)
        self.vertical_lines.sort(key = lambda e: (e[k_y_min]))
        self.content_lines = select_region_lines({k_y_min: page_region[k_y_min], k_y_max: page_region[k_y_max]}, self.vertical_lines)

        for x_coord in page_region[k_cols]:
            cells = generate_column_cells(x_coord[k_x_min], x_coord[k_x_max], self.content_lines)
            
            for cell in cells:
                cell[k_lines] = []
            self.cols.append({k_cells: cells})


    def assign_lines(self, lines):
        # seleccionar las lineas que están en la región
        for col in self.cols:
            for cell in col[k_cells]:
                #print(k_x_min + ': ' + str(cell[k_x_min])+ ', ' + k_x_max + ': ' + str(cell[k_x_max])+ ', ' + k_y_min + ': ' + str(cell[k_y_min])+ ', ' + k_y_max + ': ' + str(cell[k_y_max]))
                assign_words_to_regions_geometric(lines, cell, k_lines)
                #print('cell -> ' + str(cell))
        
        self.page_region[k_text_generator] = print_region_t2
        for col_idx,col in enumerate(self.cols):
            self.page_region[k_cols][col_idx][k_cells] = col[k_cells]

                
    def print_text(self):
        for col_idx, col in enumerate(self.cols):
            print(debug_tag + 'col' + str(col_idx) + ', ' + str(col))


class T2_T2:
    """Región especial que engloba varias regiones T2 consecutivas"""
    def __init__(self, page_region, page_image_path, words):
        self.page_region = page_region
        self.page_image_path = page_image_path

        top = page_region[k_y_min]
        bottom = page_region[k_y_max]
        search_term_1 = 'UBTOTAL'
        search_term_2 = 'SUSCRIPCIÓN'
        self.page_regions_t2_t2 = []

        if page_region[k_doc_pages] == "multi" and page_region[k_page] == page_last:
            res = find_word_value_ocurrences(words, search_term_1)
            if not len(res): # una única región T2
                print('última página sin final de tabla')
            elif len(res) == 1: # una última región
                self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: top, 
                        k_y_max: bottom, 
                        k_cols: page_region[k_cols]})
                
        if page_region[k_doc_pages] == "multi" and page_region[k_page] != page_last and page_region[k_page] != page_fst: 
            res_1 = find_word_value_ocurrences(words, search_term_1)
            res_2 = find_word_value_ocurrences(words, search_term_2)
            
            if not len(res_1): # una única región T2
                self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: top, 
                        k_y_max: bottom, 
                        k_cols: page_region[k_cols]})

            elif len(res_2) and res_2[-1][k_x_min] > 1210:
                self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: top, 
                        k_y_max: res_2[-1][k_y_min] - 41, 
                        k_cols: page_region[k_cols]})
                self.page_region_r1 = {
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_r1,
                        k_y_min: res_2[-1][k_y_min] - 40,
                        k_y_max: res_2[-1][k_y_max] + 40,
                        k_cols: [{k_x_min: 1168, k_x_max: 1568}, {k_x_min: 1569, k_x_max: 2150}]}
                                    
        if page_region[k_doc_pages] == "multi" and page_region[k_page] == page_fst:
            res = find_word_value_ocurrences(words, search_term_1)
            res_2 = find_word_value_ocurrences(words, search_term_2)
            if not len(res): # una única región T2
                self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: top, 
                        k_y_max: bottom, 
                        k_cols: page_region[k_cols]})
            elif len(res) == 1: # dos regiones
                self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: top, 
                        k_y_max: res[0][k_y_max] + 40, 
                        k_cols: page_region[k_cols]})
                self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: res[0][k_y_max] + 41, 
                        k_y_max: bottom, 
                        k_cols: page_region[k_cols]})
            else:
                for i in range(0,len(res)):
                    self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: res[i-1][k_y_max] + 41, 
                        k_y_max: res[i][k_y_max] + 40, 
                        k_cols: copy.deepcopy(page_region[k_cols])})
                self.page_regions_t2_t2[0][k_y_min] = top # corrige primero
                
                if len(res_2) and res_2[-1][k_x_min] > 1210:
                    self.page_region_r1 = {
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_r1,
                        k_y_min: res_2[-1][k_y_min] - 40,
                        k_y_max: bottom,
                        k_cols: [{k_x_min: 1168, k_x_max: 1568}, {k_x_min: 1569, k_x_max: 2150}]}
                else:
                    self.page_regions_t2_t2.append({
                            k_doc_pages: page_region[k_doc_pages],
                            k_page: page_region[k_page],
                            k_type: r_t2,
                            k_y_min: res[1][k_y_max] + 41, 
                            k_y_max: bottom, 
                            k_cols: copy.deepcopy(page_region[k_cols])})

        if page_region[k_doc_pages] == "single" and page_region[k_page] == page_fst:
            res = find_word_value_ocurrences(words, search_term_1)
            if res:
                self.page_regions_t2_t2.append({
                    k_doc_pages: page_region[k_doc_pages],
                    k_page: page_region[k_page],
                    k_type: r_t2,
                    k_y_min: top, 
                    k_y_max: res[0][k_y_max] + 40, 
                    k_cols: page_region[k_cols]})
                for i in range(1,len(res)):
                    self.page_regions_t2_t2.append({
                        k_doc_pages: page_region[k_doc_pages],
                        k_page: page_region[k_page],
                        k_type: r_t2,
                        k_y_min: res[i-1][k_y_max] + 41, 
                        k_y_max: res[i][k_y_max] + 40, 
                        k_cols: copy.deepcopy(page_region[k_cols])})
        
        
    def assign_lines(self, lines, words):
        self.page_region[k_text_generator] = print_not_implemented
        
        for page_region_t2_t2 in self.page_regions_t2_t2:
            trunk_lines(lines, words, page_region_t2_t2)


class T2_T2_R1:
    """Región especial que engloba una región T2_T2 segida de otra R1"""
    def __init__(self, page_region, page_image_path, words):
        self.page_region = page_region
        self.page_image_path = page_image_path
        
        search_term_1 = 'UBTOTAL'
        search_term_2 = 'pagadera'
        
        res = find_word_value_ocurrences(words, search_term_1)
        if res:
            y_max_t2 = res[-1][k_y_max] + 40
            y_min_r1 = res[-1][k_y_max] + 80
            res = find_word_value_ocurrences(words, search_term_2)
            y_max_r1 = res[0][k_y_min] - 20
    
            self.page_region_t2_t2 = {k_doc_pages: page_region[k_doc_pages], 
                                      k_page: page_region[k_page], 
                                      k_type: r_t2_t2, 
                                      k_y_min: page_region[k_y_min], 
                                      k_y_max: y_max_t2, 
                                      k_cols: page_region[k_cols_1]}
            
            self.page_region_r1 = {
                k_doc_pages: page_region[k_doc_pages], 
                k_page: page_region[k_page], 
                k_type: r_r1, 
                k_y_min: y_min_r1, 
                k_y_max: y_max_r1, 
                k_cols: page_region[k_cols_2]}
        
        else:
            res = find_word_value_ocurrences(words, search_term_2)
            self.page_region_r1 = {
                k_doc_pages: page_region[k_doc_pages],
                k_page: page_region[k_page],
                k_type: r_r1,
                k_y_min: page_region[k_y_min], 
                k_y_max: res[0][k_y_min] - 20,
                k_cols: page_region[k_cols_2]}
            
            
    def assign_lines(self, lines, words):
        self.page_region[k_text_generator] = print_not_implemented
        
        trunk_lines(lines, words, self.page_region_r1)


def generate(document):
    #print(debug_tag + 'generic_plugin')

    page_regions = filter_regions_by_page_number(document[k_template_regions], document[k_current_page], document[k_number_pages])
    #print(debug_tag + 'page_regions: ' + str(document[k_template_regions]))
    
    treat_regions(page_regions, document)
    
    return page_regions


def treat_regions(page_regions, document):
    singles, multies, alls = classify_page_regions(page_regions)
    del page_regions[:]
    page_regions += alls
    if document[k_number_pages] == 1:
        page_regions += singles
    elif document[k_number_pages] >= 2:
        page_regions += multies
    
    for page_region in page_regions:
        
        # Región R1
        if page_region[k_type] == r_r1:
            r1 = R1(page_region)
            r1.assign_lines(document[k_lines])
    
        # Región R2
        if page_region[k_type] == r_r2:
            r2 = R2(page_region)
            r2.assign_lines(document[k_lines])
        
        # Región R3
        if page_region[k_type] == r_r3:
            r3 = R3(page_region)
            r3.assign_lines(document[k_lines])
        
        # Región T1        
        if page_region[k_type] == r_t1:
            t1 = T1(page_region)
            t1.assign_lines(document[k_lines])
                
        # Región T2
        if page_region[k_type] == r_t2:
            t2 = T2(page_region, document[k_page_image_path])
            t2.assign_lines(document[k_lines])
        
        # Región T2_T2
        if page_region[k_type] == r_t2_t2:
            t2_t2 = T2_T2(page_region, document[k_page_image_path], document[k_words])
            t2_t2.assign_lines(document[k_lines], document[k_words])

            page_regions += t2_t2.page_regions_t2_t2
            try:
                page_regions.append(t2_t2.page_region_r1)
            except AttributeError:
                pass
            
        # Región T2_T2_R1
        if page_region[k_type] == r_t2_t2_r1:
            t2_t2_r1 = T2_T2_R1(page_region, document[k_page_image_path], document[k_words])
            t2_t2_r1.assign_lines(document[k_lines], document[k_words])
            
            try:
                page_regions.append(t2_t2_r1.page_region_t2_t2)
            except AttributeError:
                pass

            page_regions.append(t2_t2_r1.page_region_r1)


def classify_page_regions(page_regions):
    """Clasifica cada page_region según se aplique a una única página del documento, a algunas 
    o a todas"""
    singles = []
    multies = []
    alls = []
    for page_region in page_regions:
        if page_region[k_doc_pages] == 'single':
            singles.append(page_region)
        elif page_region[k_doc_pages] == 'multi':
            multies.append(page_region)
        elif page_region[k_doc_pages] == 'all':
            alls.append(page_region)
    
    return singles, multies, alls


def get_line_y_boundaries(content_lines):
    """Toma la lista de lineas detectadas por Hough y organiza por pares k_y_min / k_y_max"""
    boundaries = []
    for idx in range(1, len(content_lines)):
        content_lines[idx]
        boundaries.append({k_y_min: content_lines[idx-1][k_y_min], k_y_max: content_lines[idx][k_y_min]})
        
    return boundaries


def generate_column_cells(x_min, x_max, content_lines):
    """Genera coordenadas de las celdas con las lineas de Hough y los límites de las columnas"""
    cells = []
    y_boundaries = get_line_y_boundaries(content_lines)
    for boundary in y_boundaries:
        cells.append({k_x_min: x_min, k_x_max: x_max, k_y_min: boundary[k_y_min], k_y_max: boundary[k_y_max]})
    
    return cells
