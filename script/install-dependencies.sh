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

# Clonado desde el repositorio (actualmente Github)
git clone git@github.com:diegots/galiasdoc.git

# Añade PPA de Tesseract para Ubuntu 18.04 (versión Tesseract actualizada)
sudo add-apt-repository ppa:alex-p/tesseract-ocr
sudo apt-get update

# Paquetes necesarios para la compilación
sudo apt-get build-essential libpcre2-dev bison flex

# Paquetes necesarios para la ejecución
sudo apt-get install unzip poppler-utils mediainfo tesseract-ocr tesseract-ocr-spa jq python3-opencv jq bc
