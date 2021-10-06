#!/usr/bin/env bash

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

# Variables de configuración del sistema

# base_dir es el directorio de instalación de la aplicación.
base_dir=$(pwd)

# app_dir apunta al directorio donde está instalada la aplicación.
app_dir='dist'

# input_dir es la ruta absoluta al directorio donde están los datos de entrada
# p. ej.: input_dir='/var/data-files'
input_dir="$base_dir/input"

# ruta a los scripts del _engine_
engine_dir="$base_dir/$app_dir/engine"

# Se exportan las variables definidas
export base_dir
export app_dir
export input_dir
export engine_dir
