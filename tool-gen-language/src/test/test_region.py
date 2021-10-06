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

from app.constants import *
from app.region import get_line_y_boundaries, classify_page_regions


class TestGetLineBoundaries(unittest.TestCase):
    def test_get_line_y_boundaries(self):
        cells = get_line_y_boundaries(content_lines)
        self.assertEqual(47, len(cells))
        # Comprueba la primera celda
        self.assertEqual(118, cells[0][k_y_min])
        self.assertEqual(233, cells[0][k_y_max])
        # Comprueba la última celda
        self.assertEqual(3242, cells[len(cells)-1][k_y_min])
        self.assertEqual(3243, cells[len(cells)-1][k_y_max])

content_lines = [
    {k_y_min: 118, k_y_max: 118}, 
    {k_y_min: 233, k_y_max: 233},
    {k_y_min: 368, k_y_max: 368},
    {k_y_min: 371, k_y_max: 371},
    {k_y_min: 506, k_y_max: 506},
    {k_y_min: 508, k_y_max: 508},
    {k_y_min: 683, k_y_max: 683},
    {k_y_min: 686, k_y_max: 686},
    {k_y_min: 821, k_y_max: 821},
    {k_y_min: 824, k_y_max: 824},
    {k_y_min: 958, k_y_max: 958},
    {k_y_min: 961, k_y_max: 961},
    {k_y_min: 1096, k_y_max: 1096},  
    {k_y_min: 1099, k_y_max: 1099},
    {k_y_min: 1234, k_y_max: 1234},
    {k_y_min: 1236, k_y_max: 1236},
    {k_y_min: 1372, k_y_max: 1372},
    {k_y_min: 1374, k_y_max: 1374},
    {k_y_min: 1509, k_y_max: 1509},
    {k_y_min: 1511, k_y_max: 1511},
    {k_y_min: 1512, k_y_max: 1512},
    {k_y_min: 1647, k_y_max: 1647},
    {k_y_min: 1647, k_y_max: 1647},
    {k_y_min: 1649, k_y_max: 1649},
    {k_y_min: 1784, k_y_max: 1784},
    {k_y_min: 1787, k_y_max: 1787},
    {k_y_min: 1922, k_y_max: 1922},
    {k_y_min: 1924, k_y_max: 1924},
    {k_y_min: 2099, k_y_max: 2099},
    {k_y_min: 2102, k_y_max: 2102},
    {k_y_min: 2237, k_y_max: 2237},
    {k_y_min: 2239, k_y_max: 2239},
    {k_y_min: 2240, k_y_max: 2240},
    {k_y_min: 2415, k_y_max: 2415},
    {k_y_min: 2417, k_y_max: 2417},
    {k_y_min: 2552, k_y_max: 2552},
    {k_y_min: 2555, k_y_max: 2555},
    {k_y_min: 2690, k_y_max: 2690},
    {k_y_min: 2692, k_y_max: 2692},
    {k_y_min: 2827, k_y_max: 2827},
    {k_y_min: 2830, k_y_max: 2830},
    {k_y_min: 2964, k_y_max: 2964},
    {k_y_min: 2968, k_y_max: 2968},
    {k_y_min: 3102, k_y_max: 3102},
    {k_y_min: 3105, k_y_max: 3105},
    {k_y_min: 3240, k_y_max: 3240},
    {k_y_min: 3242, k_y_max: 3242},
    {k_y_min: 3243, k_y_max: 3243}]

class TestClassifyPageRegions(unittest.TestCase):
    def test_classify_page_regions(self):
        page_regions = [{k_doc_pages: 'single'}, 
                        {k_doc_pages: 'single'},
                        {k_doc_pages: 'multi'},
                        {k_doc_pages: 'single'},
                        {k_doc_pages: 'multi'},
                        {k_doc_pages: 'single'},
                        {k_doc_pages: 'all'}]
        singles, multies, alls = classify_page_regions(page_regions)
        self.assertEqual(4, len(singles))
        self.assertEqual(2, len(multies))
        self.assertEqual(1, len(alls))
        
