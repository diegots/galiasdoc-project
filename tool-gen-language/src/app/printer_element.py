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

import json


def print_lines(lines, output_base):
    """Imprime las lineas con sus identificadores, coordenadas y palabras asociadas"""
    contents = json.dumps(lines, indent=4, sort_keys=True)
    f = open(output_base+'lines.json', 'w')
    f.write(contents)
    f.close()

#     for line in lines:
#         word_ids = ''
#         for word_id in line['words']:
#             word_ids += ' ' + str(word_id)
#         print('l' + str(line['id']) +
#               ', xMin: ' + str(line['xMin']) +
#               ', yMin: ' + str(line['yMin']) +
#               ', xMax: ' + str(line['xMax']) +
#               ', yMax: ' + str(line['yMax']) +
#               ', word_ids:' + word_ids)
#     #print('l' + str(line[0]) + ': (' + str(line[1]) +', '+ str(line[2]) +', '+ str(line[3]) +', '+ str(line[4]) +')')


def print_words(words, output_base):
    """Imprime las palabras, con su identificador, valor y coordenadas"""
    contents = json.dumps(words, indent=4, sort_keys=True)
    f = open(output_base+'words.json', 'w')
    f.write(contents)
    f.close()

#     for word in words:
#         print('w' + str(word['id']) + ', value: ' + word['value'] + ', xMin: ' + str(word['xMin']) + ', yMin: ' + str(word['yMin']) + ', xMax: ' + str(word['xMax']) + ', yMax: ' + str(word['yMax']))
