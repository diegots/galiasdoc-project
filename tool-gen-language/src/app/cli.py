"""Tratamiento de los argumentos de entrada"""

import gettext
import json
import os
import ntpath
import re

from app.constants import *
from app.input_handler import hOCRParser, XHTMLParser
from app.task import get_task
from app.util import exit_with_error


def translate_argparse_messages(s):
    current_dict = {
        'usage: ': 'Uso: ',
        'show this help message and exit': 'Muestra este mensaje de ayuda y finaliza',
        'optional arguments': 'Argumentos opcionales',
        'positional arguments': 'Argumentos posicionales'
    }

    #print('orig string: ' + "'" + s + "'")
    if s in current_dict:
        return current_dict[s]
    return s

gettext.gettext = translate_argparse_messages
import argparse


def read_args():
    """Definición de los argumentos de entrada a la aplicación"""
    arg_parser = argparse.ArgumentParser()

    # Argumentos posicionales
    arg_parser.add_argument(k_parser_type,
                            help='''Selecciona el tipo de parser HTML utilizado.
                            Se puede seleccionar entre HOCR y XML.''')
    arg_parser.add_argument(k_text_with_coords,
                            help='''Ruta al fichero del texto extraido/reconocido por OCR con
                            la información de coordenadas.''')
    arg_parser.add_argument(k_template,
                            help='''Ruta a la plantilla que ha de utilizarse con el
                            modelo.''')
    arg_parser.add_argument(k_output_base,
                            help='''Ruta base de salida para los ficheros generados''')
    arg_parser.add_argument(k_number_pages,
                            help='''Número de páginas del documento''')
    arg_parser.add_argument(k_page_image_path,
                            help='''Ruta a la imagen de la página''')

    # Puede haber otros argumentos opcionales
    arg_parser.add_argument('-w', '--worktask',
                        help='''Escoge el tipo de salida deseada. Por detecto produce la lista de palabras del fichero
                         de entrada''')

    return vars(arg_parser.parse_args())


def parse_arguments():
    """Tratamiento de los argumentos de entrada"""
    args = read_args()

    known_parsers = ['HOCR', 'XML']
    parsers_impl = [hOCRParser(), XHTMLParser()]

    if args[k_parser_type] not in known_parsers:
        exit_with_error('Tipo de parser no reconocido. Los tipos disponibles son HOCR y XML')

    html_parser = parsers_impl[known_parsers.index(args[k_parser_type])]

    # Obtención del número de página del documento
    current_page = 0
    text_with_coords = ntpath.basename(args[k_text_with_coords])
    #print(debug_tag + 'text_with_coords: ' + text_with_coords)
    found_obj = re.search(r'-\d\d\d.', text_with_coords)
    if found_obj is not None:
        found_str = found_obj.group(0).translate({ord(i): None for i in '-.'})
        current_page = int(found_str)

    current_page += 1
    #print(debug_tag + 'current_page: ' + str(current_page))

    # Lectura del fichero de text+coordenadas
    try:
        f = open (args[k_text_with_coords])
    except:
        exit_with_error('No se pudo abrir ' + args[k_text_with_coords] + ' para lectura')

    #print(debug_tag + 'text_with_coords: ' + args['text_with_coords'])

    f_text_coords = f.read()
    f.close()

    # Lectura de la plantilla
    if os.stat(args[k_template]).st_size == 0:
        exit_with_error("El template indicado está vacío")

    try:
        f = open (args[k_template])
    except:
        exit_with_error('No se pudo abrir ' + args[k_template] + ' para lectura')

    template = json.load(f)
    f.close()

    # Selección del tipo de salida
    task = get_task(args[k_worktask])

    number_pages = int(args[k_number_pages])

    return {k_html_parser:html_parser, 
                  k_f_text_coords:f_text_coords, 
                  k_template: template, 
                  k_task: task,
                  k_current_page: current_page, 
                  k_output_base: args[k_output_base], 
                  k_number_pages: number_pages, 
                  k_page_image_path: args[k_page_image_path]}
