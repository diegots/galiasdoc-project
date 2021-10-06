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

"""Contenedor de constantes utilizadas en la aplicación"""

debug_tag = 'D -> '

# Claves en diccionarios
k_cells = 'cells'
k_cells = 'cells'
k_cols_1 = 'cols_1'
k_cols_2 = 'cols_2'
k_cols = 'cols'
k_current_page = 'current_page'
k_doc_pages = 'doc_pages'
k_id = 'id'
k_lines = 'lines'
k_number_pages = 'number_pages'
k_output_base = 'output_base'
k_page_image_path = 'page_image'
k_page = 'page'
k_parser_type = 'parser_type'
k_regions = 'regions'
k_splits = 'splits'
k_template_regions = 'template_regions'
k_template = 'template'
k_text_generator = 'text_generator'
k_text_with_coords = 'text_with_coords'
k_type = 'type'
k_value = 'value'
k_words = 'words'
k_worktask = 'worktask'
k_x_max = 'xMax'
k_x_min = 'xMin'
k_y_max = 'yMax'
k_y_min = 'yMin'

# Tipos de regiones
r_r1 = 'R1'
r_r2 = 'R2'
r_r3 = 'R3'
r_t1 = 'T1'
r_t2 = 'T2'
r_t2_t2 = 'T2_T2'
r_t2_t2_r1 = 'T2_T2_R1'

# Claves de los datos de entrada
k_html_parser = 'html_parser'
k_f_text_coords = 'f_text_coords'
k_template = 'template'
k_task = 'task'
k_current_page = 'current_page'
k_output_base = 'output_base'
k_number_pages = 'number_pages'
k_page_image_path = 'page_image_path'

# Otras constantes
page_fst = "0"
page_last = "-1"
output_base_name = 'language.txt'

# Símbolos para la generación de código
gen_sym_start = '_START'
gen_sym_end = '_END'
gen_sym_col_start = '└'
gen_sym_col_end = '┘'
gen_sym_line_start = '►'
gen_sym_line_end = '◄'
gen_sym_header = 'H'
gen_sym_word = 'W'
gen_sym_page = 'P'
gen_sym_word_separator = '·'
