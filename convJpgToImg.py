from PIL import Image
import numpy as np

def process_uploaded_image(image_path, img_path):
    """Carga una imagen, la convierte a escala de grises y la guarda como .img."""
    img = Image.open(image_path).convert('L')  # Convertir a escala de grises
    img = img.resize((390, 390))  # Redimensionar a 390x390 si es necesario
    img.save("processed_image.jpg")  # Guardar como JPG para referencia
    img_data = np.array(img, dtype=np.uint8)  # Convertir a array numpy
    img_data.tofile(img_path)  # Guardar como archivo binario
    print(f"Imagen convertida y guardada como {img_path}")

# Procesar la imagen subida
process_uploaded_image("image.png", "processed_image.img")

