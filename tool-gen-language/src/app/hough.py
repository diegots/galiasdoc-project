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

"""Detección de líneas mediante el algoritmo de Hough"""

import os
import cv2
import numpy as np

from app.constants import *


def get_lines_with_hough(image_path):

    if not os.path.exists(image_path):
        raise FileNotFoundError('No se pudo abrir ' + image_path + ' para lectura') 

    src = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    dst = cv2.Canny(src, 50, 200, None, 3)
    linesP = cv2.HoughLinesP(dst, 1, np.pi / 180, 50, None, 350, 10)
    
    # Descarta las lineas verticales
    vertical_lines = []
    if linesP is not None:
        for i in range(0, len(linesP)):
            l = linesP[i][0]
            if abs(l[0] - l[2]) <= 0:
                continue
            vertical_lines.append(l)

    res = []
    for line in vertical_lines:
        res.append({k_x_min: line[0], k_y_min: line[1], k_x_max: line[2], k_y_max: line[3]})

    return res
