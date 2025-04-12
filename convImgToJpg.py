from PIL import Image
import numpy as np

def img_to_jpg(img_path, jpg_path, width=390, height=390):
    """Convierte un archivo .img (RAW) a JPG."""
    img_data = np.fromfile(img_path, dtype=np.uint8)
    img_data = img_data.reshape((height, width))  # Ajustar dimensiones
    img = Image.fromarray(img_data, mode='L')  # Crear imagen en escala de grises
    img.save(jpg_path)
    print(f"Imagen convertida y guardada como {jpg_path}")

# Ejecutar conversión
img_to_jpg("interpolated_image.img", "interpolated_image.jpg")

