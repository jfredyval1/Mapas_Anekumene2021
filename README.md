# Creación de mapas temáticos con R

R como lenguaje tiene una gran cantidad de características para la manipulación y análisis de datos, la información geográfica no escapa a este espectro. R cuenta con una gran cantidad de librerías útiles para la construcción y análisis de información geográfica, pero también para su diagramación y comunicación mediante mapas.

En el marco del artículo *El uso formativo del mapa: una mirada en la experiencia del semillero Scripta Geographica* se realizaron varios mapas temáticos con el ánimo de ejemplificar cómo un mismo fenómeno expresando en una variable determinada puede ser comunicado e incluso distorsionado en función de la estrategia comunicativa que se adopte para su socialización.

Este repositorio agrupa los datos utilizados y el procedimiento implementado para diagramar los mapas que se publican en conjunto con el artículo, buscando así contribuir a la replicación de ejercicios de esta índole, o incluso servir de base para la construcción de ejemplos con orientaciones similares.

## Implementación del script

Al clonar el repositorio en un ordenador local encontrará una carpeta en donde se aloja la información geográfica utilizada, tomada del censo socioeconómico SISBEN 2016, y de la cartografía base IDECA 2019.
El repositorio cuenta con dos **branch** siendo ellos en su orden:
 
 - Master
 - Cartography

Estos solo se diferencian en las librerías que implementa para la construcción de las figuras. El texto al que se hace referencia ha usado los productos derivados del proceso ejecutado en el branch *cartography*.

## Reproducir los mapas

Al descargar la información puede ejecutar el script en su ordenador usando el lenguaje `R`, este demanda de algunas librerías que, en caso de no estar instaladas, lo harán antes de generar las figuras.
El resultado del proceso se reflejará al crear una nueva carpeta en la dirección en la que aloje el srcipt, posterior a su ejecución encontrará en la carpeta *Gráficos* los archivos `.jpeg` para su consulta.

El código se ha realizado en un entorno `R` versión `4.0.4`.

### Branch master y cartography

 - El código que se comparte en el **branch** *master* genera salidas gráficas usando la librerías `ggplot2`.
 - El código que se comparte en el **branch** *cartography* genera salidas gráficas usando la librerías `cartography`.


