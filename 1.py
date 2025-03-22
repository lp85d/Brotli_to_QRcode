import tkinter as tk
from tkinter import colorchooser
import requests

current_fg_color = "#00ff00"
text_alpha = 1.0

def get_crypto_price():
    try:
        response = requests.get("https://min-api.cryptocompare.com/data/price?fsym=TON&tsyms=USD")
        return response.json()["USD"]
    except Exception:
        return "N/A"

def update_label():
    price = get_crypto_price()
    canvas.itemconfig(text_item, text=f"TON: {price} USD")

def periodic_update():
    update_label()
    root.after(int(update_freq.get() * 1000), periodic_update)

def update_text_opacity(value):
    global text_alpha
    text_alpha = float(value)
    apply_text_alpha()

def apply_text_alpha():
    try:
        bg_rgb = root.winfo_rgb(root.cget("bg"))
        fg_rgb = root.winfo_rgb(current_fg_color)
        
        r = int(fg_rgb[0]/256 * text_alpha + bg_rgb[0]/256 * (1 - text_alpha))
        g = int(fg_rgb[1]/256 * text_alpha + bg_rgb[1]/256 * (1 - text_alpha))
        b = int(fg_rgb[2]/256 * text_alpha + bg_rgb[2]/256 * (1 - text_alpha))
        
        hex_color = "#%02x%02x%02x" % (r, g, b)
        canvas.itemconfig(text_item, fill=hex_color)
    except tk.TclError:
        pass

def start_drag(event):
    widget = event.widget.winfo_containing(event.x_root, event.y_root)
    if widget in [bg_opacity, text_opacity, update_freq, button_color, button_close, button_text, button_opacity]:
        return "break"
    global x, y
    x = event.x
    y = event.y

def drag(event):
    widget = event.widget.winfo_containing(event.x_root, event.y_root)
    if widget in [bg_opacity, text_opacity, update_freq, button_color, button_close, button_text, button_opacity]:
        return "break"
    if 'x' not in globals() or 'y' not in globals():
        return
    deltax = event.x - x
    deltay = event.y - y
    root.geometry(f"+{root.winfo_x()+deltax}+{root.winfo_y()+deltay}")

def show_bg_opacity_value(event):
    value = bg_opacity.get()
    opacity_value_label.config(text=f"Прозрачность фона: {value:.2f}")
    opacity_value_label.place(x=5, y=15)
    root.after(2000, lambda: (opacity_value_label.place_forget(), bg_opacity.place_forget()))

def show_text_opacity_value(event):
    value = text_opacity.get()
    opacity_value_label.config(text=f"Прозрачность текста: {value:.2f}")
    opacity_value_label.place(x=5, y=15)
    root.after(2000, lambda: (opacity_value_label.place_forget(), text_opacity.place_forget()))

def show_freq_value(event):
    value = int(update_freq.get())
    freq_value_label.config(text=f"Интервал: {value} сек")
    freq_value_label.place(x=5, y=15)
    root.after(2000, lambda: (freq_value_label.place_forget(), update_freq.place_forget()))

root = tk.Tk()
root.overrideredirect(True)
root.geometry("135x50")
root.attributes("-alpha", 0.8)
root.configure(bg="black")

screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
root.geometry(f"+{(screen_width-135)//2}+{(screen_height-50)//2}")

canvas = tk.Canvas(root, width=135, height=50, bg="black", highlightthickness=0)
canvas.place(x=0, y=0)
text_item = canvas.create_text(5, 25, text="TON: loading...", font=("Arial", 12, "bold"), fill=current_fg_color, anchor="w")

bg_opacity = tk.Scale(root, from_=0.1, to=1.0, resolution=0.01, orient="h", length=130, showvalue=0, command=lambda v: root.attributes("-alpha", float(v)))
bg_opacity.set(0.8)
bg_opacity.place(x=2, y=15)
bg_opacity.place_forget()
bg_opacity.bind("<ButtonRelease-1>", show_bg_opacity_value)

text_opacity = tk.Scale(root, from_=0.1, to=1.0, resolution=0.01, orient="h", length=130, showvalue=0, command=update_text_opacity)
text_opacity.set(1.0)
text_opacity.place(x=2, y=15)
text_opacity.place_forget()
text_opacity.bind("<ButtonRelease-1>", show_text_opacity_value)

update_freq = tk.Scale(root, from_=1, to=60, resolution=1, orient="h", length=130, showvalue=0)
update_freq.set(10)
update_freq.place(x=2, y=15)
update_freq.place_forget()
update_freq.bind("<ButtonRelease-1>", show_freq_value)

opacity_value_label = tk.Label(root, text="", font=("Arial", 8), fg="black", bg="#d9d9d9")
freq_value_label = tk.Label(root, text="", font=("Arial", 8), fg="black", bg="#d9d9d9")

def change_colors():
    global current_fg_color
    bg_color = colorchooser.askcolor(title="Цвет фона")[1]
    if bg_color:
        root.config(bg=bg_color)
        canvas.config(bg=bg_color)
    fg_color = colorchooser.askcolor(title="Цвет текста")[1]
    if fg_color:
        current_fg_color = fg_color
        apply_text_alpha()

button_color = tk.Button(root, text="", command=change_colors)
button_color.place(x=0, y=0, width=10, height=10)

button_close = tk.Button(root, text="", command=root.destroy)
button_close.place(x=125, y=0, width=10, height=10)

def toggle_update_freq():
    update_freq.place(x=2, y=15) if not update_freq.winfo_viewable() else update_freq.place_forget()
button_text = tk.Button(root, text="", command=toggle_update_freq)
button_text.place(x=0, y=40, width=10, height=10)

def toggle_opacity_sliders():
    if bg_opacity.winfo_viewable() or text_opacity.winfo_viewable():
        bg_opacity.place_forget()
        text_opacity.place_forget()
    else:
        bg_opacity.place(x=2, y=15)
button_opacity = tk.Button(root, text="", command=toggle_opacity_sliders)
button_opacity.place(x=125, y=40, width=10, height=10)

root.bind("<ButtonPress-1>", start_drag)
root.bind("<B1-Motion>", drag)
root.bind("<Button-3>", lambda e: root.destroy())

update_label()
root.after(int(update_freq.get() * 1000), periodic_update)

root.mainloop()
