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

"""Tratamiento de los datos de entrada en formato hOCR y XHTML"""

from app.constants import *
from html.parser import HTMLParser


attr_ocr_line = 'ocr_line'
attr_ocrx_word = 'ocrx_word' 
tag_line = 'line'
tag_span = 'span'
tag_word = 'word'


class hOCRParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.store_word = False
        self.line_counter = -1
        self.lines = []
        self.word_counter = -1
        self.words = []
        
        
    def handle_starttag(self, tag, attrs):
        if tag == tag_span:
            if attrs[0][1] == attr_ocr_line:
                xMin, yMin, xMax, yMax = self.get_coords(attrs)
                self.line_counter += 1
                self.lines.append({k_id: self.line_counter, k_x_min: xMin, k_y_min: yMin, k_x_max: xMax, k_y_max: yMax, k_words: []})
                #print('-> line @ {0} {1} {2} {3}'.format(xMin, yMin, xMax, yMax))
            elif(attrs[0][1] == attr_ocrx_word):
                self.store_word = True
                self.wxMin, self.wyMin, self.wxMax, self.wyMax = self.get_coords(attrs)


    def handle_data(self, data):
        if self.store_word is True:
            self.word_counter += 1
            self.lines[-1][k_words].append(self.word_counter)
            self.words.append({k_id: self.word_counter,
                               k_value: data,
                               k_x_min: self.wxMin,
                               k_y_min: self.wyMin,
                               k_x_max: self.wxMax,
                               k_y_max: self.wyMax})
        #print('value: \'' + data, end='\'\n\n')


    def handle_endtag(self, tag):
        if tag == tag_span and self.store_word == True:
            self.store_word = False
            #print('end tag')


    def get_coords(self, attrs):
        xMin = int(attrs[2][1].split(' ')[1])
        yMin = int(attrs[2][1].split(' ')[2])
        xMax = int(attrs[2][1].split(' ')[3])
        yMax = int(attrs[2][1].split(' ')[4].strip(';'))
        return xMin, yMin, xMax, yMax                         


class XHTMLParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.store_word = False
        self.line_counter = -1
        self.lines = []
        self.word_counter = -1
        self.words = []

    
    def handle_starttag(self, tag, attrs):
        if tag == tag_line:
            self.line_counter += 1
            #print(debug_tag + 'self.line_counter: ' + str(self.line_counter))
            xMin, yMin, xMax, yMax = self.get_coords(attrs)
            self.lines.append({k_id: self.line_counter, k_x_min: xMin, k_y_min: yMin, k_x_max: xMax, k_y_max: yMax, k_words: []})
            #print(debug_tag + 'line @ {0} {1} {2} {3}'.format(xMin, yMin, xMax, yMax))
            self.store_word = True
        if tag == tag_word:
            self.word_counter += 1
            #print(debug_tag + '    self.word_counter: ' + str(self.word_counter))
            self.wxMin, self.wyMin, self.wxMax, self.wyMax = self.get_coords(attrs)

            
    def handle_data(self, data):
        if self.store_word == True and data.strip() != '':
            #print(debug_tag + '    word: ' + data)
            self.lines[-1][k_words].append(self.word_counter)
            self.words.append({k_id: self.word_counter, 
                               k_value: data, 
                               k_x_min: self.wxMin,
                               k_y_min: self.wyMin,
                               k_x_max: self.wxMax,
                               k_y_max: self.wyMax})

            
    def handle_endtag(self, tag):
        if tag == tag_line:
            self.store_word = False

            
    def get_coords(self, attrs):
        #print(debug_tag + 'attrs: ' + str(attrs))
        xMin = int(float(attrs[0][1]))
        yMin = int(float(attrs[1][1]))
        xMax = int(float(attrs[2][1]))
        yMax = int(float(attrs[3][1]))
        return xMin, yMin, xMax, yMax


def parse_text_coords(f_contents, parser):
    parser.feed(f_contents)
    parser.close()
    return parser.lines, parser.words
