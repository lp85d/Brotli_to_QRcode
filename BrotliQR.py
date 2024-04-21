import qrcode
from PIL import Image

# Читаем данные из файла
file_path = "C:\\Users\\user\\Desktop\\brotli.txt"
with open(file_path, 'rb') as file:
    data = file.read()

# Генерируем QR-код для всех данных
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)
qr.add_data(data)
qr.make(fit=True)

# Получаем объект изображения из qrcode и преобразуем его в объект изображения из Pillow
img = qr.make_image(fill_color="black", back_color="white")
img_pillow = img.get_image()

# Сохраняем изображение в файл
img_pillow.save('brotli_to_qr.png')

print("Один QR-код успешно создан для всех данных.")
