import os
import subprocess
import numpy as np
from PIL import Image, ImageTk
import tkinter as tk
from tkinter import filedialog

GRID_SIZE = 4
SIZE = (390, 390)
INTERP_SIZE = 385  # Nuevo tamaño de imagen interpolada

class InterpolacionApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Interpolación Bilineal con NASM")
        self.img_path = ""
        self.quadrants = []
        self.qh = self.qw = 0
        self.interpolated_img = None

        self.btn_load = tk.Button(root, text="Cargar Imagen", command=self.load_image)
        self.btn_load.pack(pady=10)

        self.canvas = tk.Canvas(root, width=SIZE[0], height=SIZE[1])
        self.canvas.pack()
        self.canvas.bind("<Button-1>", self.on_click)

        self.output_frame = tk.Frame(root)
        self.output_frame.pack()

        self.btn_save = tk.Button(root, text="Guardar Interpolado", command=self.save_interpolated)
        self.btn_save.pack(pady=5)
        self.btn_save.config(state=tk.DISABLED)

    def load_image(self):
        file_path = filedialog.askopenfilename(filetypes=[("Image files", "*.jpg *.png")])
        if not file_path:
            return
        self.img_path = file_path
        img = Image.open(file_path).convert("L").resize(SIZE)
        img.save("processed_image.jpg")
        self.img_data = np.array(img)
        self.qh, self.qw = SIZE[0] // GRID_SIZE, SIZE[1] // GRID_SIZE
        self.divide_image()
        self.display_image(img)
        self.btn_save.config(state=tk.DISABLED)

    def divide_image(self):
        self.quadrants = []
        for i in range(GRID_SIZE):
            for j in range(GRID_SIZE):
                quadrant = self.img_data[i*self.qh:(i+1)*self.qh, j*self.qw:(j+1)*self.qw]
                self.quadrants.append(quadrant)

    def display_image(self, img):
        self.tk_img = ImageTk.PhotoImage(img)
        self.canvas.create_image(0, 0, anchor=tk.NW, image=self.tk_img)
        for i in range(1, GRID_SIZE):
            x = i * self.qw
            y = i * self.qh
            self.canvas.create_line(x, 0, x, SIZE[1], fill="red")
            self.canvas.create_line(0, y, SIZE[0], y, fill="red")

    def on_click(self, event):
        col = event.x // self.qw
        row = event.y // self.qh
        index = row * GRID_SIZE + col
        if index < len(self.quadrants):
            self.process_quadrant(index)

    def process_quadrant(self, index):
        quadrant = self.quadrants[index]
        quadrant.tofile("quadrant.img")

        subprocess.run(["nasm", "-f", "elf64", "interpol_bil.asm", "-o", "interpol_bil.o"])
        subprocess.run(["ld", "interpol_bil.o", "-o", "interpol_bil"])
        subprocess.run(["./interpol_bil"])

        # Leer imagen interpolada de 385x385
        interp_data = np.fromfile("interpolated_image.img", dtype=np.uint8).reshape((385, 385))
        self.interpolated_img = Image.fromarray(interp_data)
        self.show_images(self.img_data, quadrant, interp_data)
        self.btn_save.config(state=tk.NORMAL)

    def show_images(self, original, quadrant, interpolated):
        for widget in self.output_frame.winfo_children():
            widget.destroy()

        imgs = [
            Image.fromarray(original).resize((400, 400), resample=Image.BILINEAR),
            Image.fromarray(quadrant).resize((400, 400), resample=Image.BILINEAR),
            Image.fromarray(interpolated).resize((400, 400), resample=Image.BILINEAR)
        ]
        titles = ["Original", "Cuadrante", "Interpolado (4x4)"]

        for i in range(3):
            tk_img = ImageTk.PhotoImage(imgs[i])
            lbl = tk.Label(self.output_frame, text=titles[i])
            lbl.pack(side=tk.LEFT, padx=5)
            panel = tk.Label(self.output_frame, image=tk_img)
            panel.image = tk_img
            panel.pack(side=tk.LEFT, padx=5)

    def save_interpolated(self):
        if self.interpolated_img is None:
            return
        save_path = filedialog.asksaveasfilename(defaultextension=".jpg",
                                                 filetypes=[("JPEG files", "*.jpg"), ("All files", "*.*")],
                                                 title="Guardar imagen interpolada")
        if save_path:
            self.interpolated_img.save(save_path)
            print(f"Imagen guardada en: {save_path}")

if __name__ == '__main__':
    root = tk.Tk()
    app = InterpolacionApp(root)
    root.mainloop()

