# Uso de Docker

- Preparar la imagen:

```
docker build -t galiasdoc:<tag> .
```

- Exportar la imagen:

```
docker save galiasdoc:<tag> | gzip > galiasdoc-<tag>.tar.gz
```

- Arrancar la imagen desde WSL o Linux:

```
docker run -it --detach --name galias --mount type=bind,source="$(pwd)"/target,target=/input galiasdoc:<tag>
```

- Arrancar la imagen desde CMD

```
docker run -it --detach --name galias --mount "type=bind,source=%userprofile%\input,target=/input" galiasdoc:<tag>
```

- Abrir una shell al contenedor

```
docker exec -it <container_id> bash
```

## Ejecución de la aplicación bajo Windows

1. Se obtiene un nuevo id para un job:

```
docker exec galias /app/script/run-docker-get-new-id.sh > job_id.txt
set /p job_id=<job_id.txt
```

2. Se copia el zip con los PDF al punto de montaje añadiendo el id anterior:

```
<punto_montaje>\%job_id\frontend
```

3. Se ejecuta la aplicación indicando el job_id

```
docker exec galias /app/script/run-docker-start.sh %job_id%
```

Cuando la aplicación finaliza, se crea un fichero vacío para señalizarlo en:

```
<punto_montaje>\%job_id\done-%job_id%
```

Los ficheros de salida estarán en las siguientes rutas:

```
<punto_montaje>\%job_id\<identificador_documento>\based-text\*
<punto_montaje>\%job_id\<identificador_documento>\based-image\*
```

