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

import unittest

from app.constants import k_value
from app.lookup import find_word_value_ocurrences
from app.util import is_region_in_page, page_number_to_default_format 


class TestIsPageInRegion(unittest.TestCase):
    def test_is_page_in_region(self):
        # is_region_in_page(region_slice, current_page, number_pages)
        self.assertTrue(is_region_in_page("0", 1, 5))
        self.assertFalse(is_region_in_page("0", 2, 5))
        self.assertFalse(is_region_in_page("-1", 1, 1))
        self.assertFalse(is_region_in_page("-1", 1, 6))
        self.assertTrue(is_region_in_page("-1", 5, 5))
        self.assertFalse(is_region_in_page("-1", 4, 5))
        self.assertTrue(is_region_in_page("1:-1", 4, 7))
        self.assertFalse(is_region_in_page("1:-1", 1, 7))
        self.assertFalse(is_region_in_page("1:-1", 7, 7))

        
class TestPageNumberToDefaultFormat(unittest.TestCase):
    def test_page_number_to_default_format(self):
        self.assertEqual('000', page_number_to_default_format(1))
        self.assertEqual('001', page_number_to_default_format(2))
        self.assertEqual('009', page_number_to_default_format(10))
        self.assertEqual('010', page_number_to_default_format(11))
        self.assertEqual('998', page_number_to_default_format(999))
        self.assertEqual('999', page_number_to_default_format(1000))

    
class TestFindOcurrencesOfWordValue(unittest.TestCase):
    def test_find_ocurrences_of_word_value(self):
        words = [{k_value: 'SUSCRIPCIÓN'},
                 {k_value: 'ns3108512.ip-54-37-253.eu'},
                 {k_value: 'Servidor'},
                 {k_value: 'ns3108512.ip-54-37-253.eu'},
                 {k_value: 'E3-1270v6'},
                 {k_value: '450'},
                 {k_value: 'ns3108512.ip-54-37-253.eu'},
                 {k_value: '01-11-2019'}]
        
        res = find_word_value_ocurrences(words, 'ns3108512.ip-54-37-253.eu')
        self.assertEqual(3, len(res))
        res = find_word_value_ocurrences(words, 'NVMe')
        self.assertEqual(0, len(res))
        res = find_word_value_ocurrences(words, 'Servidor')
        self.assertEqual(1, len(res))        
        
        
