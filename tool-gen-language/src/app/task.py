"""Definición de las tareas disponibles en la aplicación"""

from enum import Enum, auto

from app.assign import trunk_lines
from app.constants import *
from app.input_handler import parse_text_coords
from app.region import generate
from app.printer_element import print_lines, print_words
from app.lookup import find_words_by_id


class Task(Enum):
    LIST_WORDS = auto()
    GENERATE = auto()
    TEST_TRUNK_LINES = auto()    


def get_task(task_name):
    if task_name == Task.LIST_WORDS.name:
        return TaskListWords()
    elif task_name == Task.GENERATE.name:
        return TaskGenerate()
    elif task_name == Task.TEST_TRUNK_LINES.name:
        return TaskTestTrunkLines()
    else:
        # Task por defecto
        return TaskGenerate()


class TaskTestTrunkLines():
    """Test de la función trunk_lines con datos reales"""
    def run(self, input_info):
        template_regions = input_info[k_template][k_regions]
        lines, words = parse_text_coords(input_info[k_f_text_coords], 
                                         input_info[k_html_parser])
        
        a = self.count_words(lines)        
        for region in template_regions:
            trunk_lines(lines, words, region)
        b = self.count_words(lines)

        
    def count_words(self, lines):
        counter = 0
        for line in lines:
            counter += len(line[k_words])
        
        return counter


class TaskListWords():
    """Muestra cada línea y palabra"""
    def run(self, input_info):
        lines, words = parse_text_coords(input_info[k_f_text_coords], input_info[k_html_parser])
        #print('words: \n' + str(words))
        
        output = ''
        for line in lines:
            output += ('L - id: ' + str(line[k_id])
            + '(xMin,xMax)=(' + str(line[k_x_min]) + ',' + str(line[k_x_max]) + ')'
            + '\n')
            word_ids = line[k_words]
            current_line_words = find_words_by_id(words, word_ids)
            for word in current_line_words:
                output += ('    W - id: ' + str(word[k_id]) + ' - ' 
                + '(xMin,xMax)=(' + str(word[k_x_min]) + ',' + str(word[k_x_max]) + ')' + ' - '
                + '(yMin,yMax)=(' + str(word[k_y_min]) + ',' + str(word[k_y_max]) + ')'
                + ' - value: ' + str(word[k_value])
                + '\n')
                
        print(output, end='')
        
        
class TaskGenerate():
    def run(self, input_info):
        # Inicializa las regiones
        template_regions = input_info[k_template][k_regions]
        
        #print('parser_type ', parser_type)
        #print('f_text_coords ', f_text_coords)
        #print('template ', str(template))
        
        # Parse de los datos de coordenadas
        lines, words = parse_text_coords(input_info[k_f_text_coords], 
                                         input_info[k_html_parser])

        # Asocia líneas y palabras a regiones
        for region in template_regions:
            #print(debug_tag + 'region: ' + str(region))
            trunk_lines(lines, words, region)

        document = {k_lines: lines,
                    k_words: words,
                    k_template_regions: template_regions,
                    k_current_page: input_info[k_current_page],
                    k_number_pages: input_info[k_number_pages],
                    k_page_image_path: input_info[k_page_image_path]}
        
        # Asignación de contenidos a regiones
        page_regions = generate(document)
        
        # Escribe los resultados a disco
        result = ''
        for page_region in page_regions:
            result += page_region[k_text_generator](page_region, lines, words, 
                                                    input_info[k_current_page])
        if result:
            f = open(input_info[k_output_base] + output_base_name, 'w')
            f.write(result)
            f.close()
        
        # Genera ficheros de lineas y palabras
        print_lines(lines, input_info[k_output_base])
        print_words(words, input_info[k_output_base])
        
        #print(json.dumps(words, indent=2))
        
        