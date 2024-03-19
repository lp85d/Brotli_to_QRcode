import qrcode

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

img = qr.make_image(fill_color="black", back_color="white").get_image()
img.save('brotli_to_qr.png')

print("Один QR-код успешно создан для всех данных.")
