#!/usr/bin/env bash

# Configuración del entorno
conf_file='/app/conf/engine.sh'
source $conf_file

# Obtiene un nuevo directorio de trabajo
$app_dir/engine/get-job-id.sh

