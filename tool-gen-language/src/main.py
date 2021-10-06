#!/usr/bin/env python3

"""Módulo de entrada a la aplicación"""

from app.cli import parse_arguments
from app.constants import *

# Trata arg. entrada e inicia la tarea
input_info = parse_arguments()
input_info[k_task].run(input_info)
