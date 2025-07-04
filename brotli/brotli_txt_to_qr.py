import qrcode
import os
from PIL import Image
import base64

# Путь к файлу, который содержит уже закодированные данные Base64
# УБЕДИТЕСЬ, ЧТО ЭТОТ ПУТЬ ВЕРЕН И ФАЙЛ СУЩЕСТВУЕТ
file_path = r"C:\brotli\base64.txt" # Файл, содержащий Base64 строку
output_qr_filename = 'base64_data_qr.png' # Имя файла для одиночного QR-кода

print(f"Попытка преобразовать файл: {file_path} в ОДИН QR-код.")

try:
    # Открываем и читаем содержимое файла как ТЕКСТ.
    # Так как файл уже содержит строку Base64, мы читаем её напрямую.
    with open(file_path, 'r', encoding='utf-8') as file:
        data_to_encode = file.read() # Теперь data_to_encode - это ваша Base64 строка

    # Предупреждение о размере данных
    # Максимальная вместимость одного QR-кода (версия 40, L-коррекция) для текстовых данных составляет около 4296 символов.
    # Для бинарных данных (которые часто интерпретируются из Base64) лимит около 2953 байт.
    if len(data_to_encode) > 2953: # Используем лимит для байтов, так как Base64 представляет бинарные данные
        print(f"Внимание: Размер данных ({len(data_to_encode)} символов Base64) может быть слишком велик для одного QR-кода.")
        print("QR-код будет создан, но может быть нечитаемым или произойдет ошибка, если данные превышают максимальную версию.")
    else:
        print(f"Размер данных ({len(data_to_encode)} символов Base64) предположительно подходит для одного QR-кода.")

    # Генерируем QR-код для всего содержимого файла
    qr = qrcode.QRCode(
        error_correction=qrcode.constants.ERROR_CORRECT_L, # Уровень коррекции ошибок L
        box_size=10,
        border=4,
    )
    qr.add_data(data_to_encode)
    qr.make(fit=True) # Автоматически выбирает лучшую версию QR-кода. Если данных слишком много для версии 40, это вызовет ошибку.

    # Получаем изображение QR-кода
    img = qr.make_image(fill_color="black", back_color="white")

    # Сохраняем изображение в файл
    img.save(output_qr_filename)

    print(f"Один QR-код успешно создан и сохранен как '{output_qr_filename}'.")

except FileNotFoundError:
    print(f"Ошибка: Файл '{file_path}' не найден. Пожалуйста, проверьте путь к файлу.")
except Exception as e:
    print(f"Произошла непредвиденная ошибка: {e}")

# Ожидание ввода пользователя перед закрытием консоли
input("Нажмите Enter, чтобы закрыть консоль...")
