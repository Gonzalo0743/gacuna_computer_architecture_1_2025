# Proyecto: Interpolación Bilineal en Ensamblador x86

## Autor
**Gonzalo Acuña Madrigal**  
Curso: CE4301 – Arquitectura de Computadores I  
Instituto Tecnológico de Costa Rica

---

## Descripción del Proyecto

Este proyecto implementa una aplicación para interpolar imágenes en escala de grises utilizando el algoritmo de interpolación bilineal. La lógica de procesamiento está implementada en lenguaje ensamblador NASM x86 sobre una imagen seleccionada por el usuario y la interfaz para mostrar las imágenes se encuentra implementado en Python. El objetivo es permitir la ampliación suave de un cuadrante de imagen seleccionada de los 16 que se pueden utilizar.

---

## Requisitos
- Linux
- NASM
- Python
- NumPy

---
## Instrucciones de Uso

1. Dentro de la carpeta con los archivos, se abre la terminal y se ejecuta el script de Python:

        python3 interpolacion_bilineal.py


2. Una vez dentro, se selecciona la imagen que se quiera interpolar.

3. Seguidamente, la imagen aparecerá redimensionada, a escala de grises y dividida en 16 cuadrantes. Se debe seleccionar el cuadrante al cual se le quiere interpolar.

4. Finalmente, luego de seleccionar el cuadrante deseado, se visualizará la imagen, el cuadrante seleccionado y el cuadrante interpolado.

5. Como extra, si se quiere guardar el cuadrante interpolado, se selecciona el botón de "Guardar Interpolado".



