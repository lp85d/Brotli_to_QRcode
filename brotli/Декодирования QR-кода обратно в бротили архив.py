from pyzbar.pyzbar import decode
from PIL import Image

# Путь к изображению с QR-кодом
qr_image_path = r"C:\brotli\qr.png"

# Путь для сохранения brotli-архива
output_path = r"C:\brotli\result.br"

# Открываем изображение и декодируем
image = Image.open(qr_image_path)
decoded = decode(image)

if decoded:
    # Сохраняем бинарные данные как файл
    with open(output_path, 'wb') as f:
        f.write(decoded[0].data)
    print(f"Готово: сохранено в {output_path}")
else:
    print("❌ QR-код не найден на изображении.")
