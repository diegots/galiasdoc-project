#!/usr/bin/env bash

echo '-> Ejecuta tests Python'

python3 -m unittest discover -s tool-gen-language/src/ -v
