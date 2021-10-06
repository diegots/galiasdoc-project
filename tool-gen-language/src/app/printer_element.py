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
