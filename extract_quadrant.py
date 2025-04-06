from PIL import Image
import numpy as np

def extract_quadrant(img_path, jpg_path, width=390, height=390, quadrant="TL"):
    img_data = np.fromfile(img_path, dtype=np.uint8)
    img_data = img_data.reshape((height, width))

    mid_h, mid_w = height // 2, width // 2

    quadrants = {
        "TL": img_data[:mid_h, :mid_w],  # Superior izquierdo
        "TR": img_data[:mid_h, mid_w:],  # Superior derecho
        "BL": img_data[mid_h:, :mid_w],  # Inferior izquierdo
        "BR": img_data[mid_h:, mid_w:]   # Inferior derecho
    }

    if quadrant not in quadrants:
        print("Error: Cuadrante inválido. Usa 'TL', 'TR', 'BL' o 'BR'.")
        return

    cropped_img = quadrants[quadrant]
    img = Image.fromarray(cropped_img, mode='L')
    img.save(jpg_path)
    print(f"Imagen del cuadrante {quadrant} guardada como {jpg_path}")

# Preguntar al usuario qué cuadrante quiere
print("Seleccione el cuadrante a extraer:")
print("[TL] Superior Izquierdo")
print("[TR] Superior Derecho")
print("[BL] Inferior Izquierdo")
print("[BR] Inferior Derecho")

quadrant = input("Ingrese el código del cuadrante (TL, TR, BL, BR): ").strip().upper()
extract_quadrant("interpolated_image.img", f"quadrant_{quadrant}.jpg", quadrant=quadrant)

