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
