# Bash shell

- `shopt -s nullglob` y `shopt -u nullglob`: se activa `nullglob` para evitar que Bash convierta el propio patrón en un literal, por ejemplo:

```
for f in doc/*.zip; do echo 'encontrado $f =' $f && echo unzip $f; done

shopt -s nullglob
for f in doc/*.zip; do echo 'encontrado $f =' $f && echo unzip $f; done
shopt -u nullglob
```
# C language

## Use of gdb

- Run gdb with params: `gdb --args executablename arg1 arg2 arg3`.
- Interactive commands:
    - `s`: Runs the next line of the program.
    - `p var`: Prints the current value of the variable `var`.
    - `b`: Puts a breakpoint at the current line.
    - `b N`: Puts a breakpoint at line N.

## Punteros
Cuando se habla de punteros hay tres ideas a considerar:
- La dirección del puntero como variable.
- El valor al que apunta.
- Los contenidos apuntados.

# Makefile

`$(patsub pattern, replacement, text)`

Esta operación en un Makefile, encuentra palabras indicadas en `text`, que estén separas por espacios, y acordes al patrón definido en `pattern`. Cambia cada ocurrencia por la indicada en `replacement`.

# Identificación de los documentos

## CIF: Código de Identificación Fiscal

- Detallado en [este](https://es.wikipedia.org/wiki/C%C3%B3digo_de_identificaci%C3%B3n_fiscal) artículo de la Wikipedia.
- La composición de los identificadores es como sigue:
    - 9 Caracteres con formato L PP NNNNN C, donde:
        - L: Letra que distingue el tipo de sociedad
        - P: Indicador de la provincia
        - N: Número correlativo de la organización en el registro
        - C: Código de control. Puede ser letra o cifra.

## DNI: Documento Nacional de Identidad

- En el caso de los profesionales autónomos que carecen de sociedad habitual utilizar el propio número de DNI.
- El número de DNI no es clave en BBDD.
- El formato es NNNNNNNN L, donde:
    - Los ocho prímeros símbolos son dígitos.
    - El último símbolo es una letra y se utiliza como código de control.

## NIF-IVA

- Más información en la [Agencia Tributaria](https://www.agenciatributaria.es/AEAT.internet/Inicio/_Segmentos_/Empresas_y_profesionales/Empresas/IVA/El_NIF_en_el_IVA.shtml).
- [Códigos de país](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
- Es utilizado por organizaciones que realizan operaciones intracomunitarias.
- Su formato es la concatenación del código del país en dos letras y el NIF.

## Generar PDF de imágenes

Los PDF creados por el comando `convert` contienen un carácter nulo al final de la linea. Para evitarlo, se actualiza el título manualmente.

```
rm -v *image.pdf
rm -v *.jpg
for i in *.pdf; do  pdftocairo -r 300 -jpeg $i "$(basename -s .pdf $i)"; done
for i in *.pdf; do ii="$(basename -s .pdf $i)" && convert $ii-*.jpg $ii-image.pdf && exiftool -Title="$ii-image.pdf" $ii-image.pdf; done
```
