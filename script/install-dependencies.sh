#!/usr/bin/env bash

# Clonado desde el repositorio (actualmente Github)
git clone git@github.com:diegots/galiasdoc.git

# Añade PPA de Tesseract para Ubuntu 18.04 (versión Tesseract actualizada)
sudo add-apt-repository ppa:alex-p/tesseract-ocr
sudo apt-get update

# Paquetes necesarios para la compilación
sudo apt-get build-essential libpcre2-dev bison flex

# Paquetes necesarios para la ejecución
sudo apt-get install unzip poppler-utils mediainfo tesseract-ocr tesseract-ocr-spa jq python3-opencv jq bc
