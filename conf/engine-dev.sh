#!/usr/bin/env bash

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
