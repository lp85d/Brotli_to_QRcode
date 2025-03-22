import tkinter as tk
from tkinter import colorchooser, Scale, Button, Label, Canvas
import requests

def get_crypto_price():
    try:
        return requests.get("https://ji1.ru/to").json().get("USD", "N/A")
    except:
        return "N/A"

def update_label():
    canvas.itemconfig(text_item, text=f"TON: {get_crypto_price()} USD")

def periodic_update():
    update_label()
    root.after(int(update_freq.get() * 1000), periodic_update)

def start_drag(event):
    widget = event.widget.winfo_containing(event.x_root, event.y_root)
    if widget in [bg_opacity, update_freq, btn_color, btn_close, btn_freq, btn_opacity]:
        return "break"
    global x, y
    x, y = event.x, event.y

def drag(event):
    widget = event.widget.winfo_containing(event.x_root, event.y_root)
    if widget in [bg_opacity, update_freq, btn_color, btn_close, btn_freq, btn_opacity]:
        return "break"
    if 'x' not in globals() or 'y' not in globals():
        return
    root.geometry(f"+{root.winfo_x() + event.x - x}+{root.winfo_y() + event.y - y}")

def show_value(event, slider, label, text):
    label.config(text=f"{text}: {slider.get():.2f}")
    label.place(x=5, y=15)
    root.after(2000, lambda: (label.place_forget(), slider.place_forget()))

def change_colors():
    global current_fg_color
    if (bg := colorchooser.askcolor(title="Цвет фона")[1]): 
        root.config(bg=bg)
        canvas.config(bg=bg)
    if (fg := colorchooser.askcolor(title="Цвет текста")[1]): 
        current_fg_color = fg
        canvas.itemconfig(text_item, fill=fg)

def toggle_widget(widget):
    widget.place(x=2, y=15) if not widget.winfo_viewable() else widget.place_forget()

root = tk.Tk()
root.overrideredirect(True)
root.geometry("135x50")
root.attributes("-alpha", 0.8)
root.configure(bg="black")
root.geometry(f"+{(root.winfo_screenwidth()-135)//2}+{(root.winfo_screenheight()-50)//2}")

canvas = Canvas(root, width=135, height=50, bg="black", highlightthickness=0)
canvas.place(x=0, y=0)
text_item = canvas.create_text(5, 25, text="TON: loading...", font=("Arial", 12, "bold"), fill="#00ff00", anchor="w")

current_fg_color = "#00ff00"

opacity_label = Label(root, font=("Arial", 8), bg="#d9d9d9")
freq_label = Label(root, font=("Arial", 8), bg="#d9d9d9")

bg_opacity = Scale(root, from_=0.1, to=1.0, resolution=0.01, orient="h", length=130, showvalue=0, command=lambda v: root.attributes("-alpha", float(v)))
bg_opacity.set(0.8)
bg_opacity.bind("<ButtonRelease-1>", lambda e: show_value(e, bg_opacity, opacity_label, "Фон"))

update_freq = Scale(root, from_=1, to=60, resolution=1, orient="h", length=130, showvalue=0)
update_freq.set(10)
update_freq.bind("<ButtonRelease-1>", lambda e: show_value(e, update_freq, freq_label, "Интервал"))

btn_color = Button(root, text="", command=change_colors)
btn_color.place(x=0, y=0, width=10, height=10)

btn_close = Button(root, text="", command=root.destroy)
btn_close.place(x=125, y=0, width=10, height=10)

btn_freq = Button(root, text="", command=lambda: toggle_widget(update_freq))
btn_freq.place(x=0, y=40, width=10, height=10)

btn_opacity = Button(root, text="", command=lambda: toggle_widget(bg_opacity))
btn_opacity.place(x=125, y=40, width=10, height=10)

root.bind("<ButtonPress-1>", start_drag)
root.bind("<B1-Motion>", drag)
root.bind("<Button-3>", lambda e: root.destroy())

update_label()
root.after(int(update_freq.get() * 1000), periodic_update)
root.mainloop()
