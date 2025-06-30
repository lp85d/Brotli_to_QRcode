import qrcode
import os
from PIL import Image

# Путь к файлу с бротили архивом
file_path = r"C:\brotli\brotli.txt" # Ваш бротили архив
output_qr_filename = 'brotli_data_qr.png' # Имя файла для одиночного QR-кода

print(f"Попытка преобразовать файл: {file_path} в ОДИН QR-код.")

try:
    # Открываем и читаем содержимое файла как БИНАРНЫЕ ДАННЫЕ.
    with open(file_path, 'rb') as file: # Изменение: 'rb' для бинарного чтения
        data_to_encode = file.read() # Теперь data_to_encode - это ваши бинарные данные

    # Предупреждение о размере данных
    # Максимальная вместимость одного QR-кода (версия 40, L-коррекция) для бинарных данных составляет около 2953 байт.
    if len(data_to_encode) > 2953:
        print(f"Внимание: Размер данных ({len(data_to_encode)} байт) может быть слишком велик для одного QR-кода.")
        print("QR-код будет создан, но может быть нечитаемым или произойдет ошибка, если данные превышают максимальную версию.")
    else:
        print(f"Размер данных ({len(data_to_encode)} байт) предположительно подходит для одного QR-кода.")

    # Генерируем QR-код для всего содержимого файла
    qr = qrcode.QRCode(
        error_correction=qrcode.constants.ERROR_CORRECT_L, # Уровень коррекции ошибок L
        box_size=10,
        border=4,
    )
    # Здесь qrcode библиотека должна автоматически определить, что это бинарные данные
    qr.add_data(data_to_encode)
    qr.make(fit=True)

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