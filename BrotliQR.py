import qrcode
import subprocess
import os
from PIL import Image

# Путь к файлу и лог-файлу
file_path = r"D:\user\Downloads\hello.br"
log_file_path = os.path.join(os.path.dirname(__file__), 'process_log.txt')

# Запуск brotli.exe и запись лога
try:
    result = subprocess.run(['brotli.exe', file_path], check=True, text=True, capture_output=True)
    success_message = f"Процесс завершился успешно:\n{result.stdout}\n"
except subprocess.CalledProcessError as e:
    success_message = f"Ошибка при выполнении brotli.exe: {e}\nСтандартный вывод: {e.stdout}\nОшибка: {e.stderr}\n"

# Запись лога в файл
with open(log_file_path, 'a') as log_file:
    log_file.write(success_message)

# Проверка, была ли успешно выполнена команда
if 'успешно' in success_message:
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

    # Получаем изображение QR-кода
    img = qr.make_image(fill_color="black", back_color="white")

    # Сохраняем изображение в файл
    img.save('brotli_to_qr.png')

    print("Один QR-код успешно создан для всех данных.")
else:
    print("Ошибка при выполнении brotli.exe, проверьте лог.")

# Ожидание ввода пользователя перед закрытием консоли
input("Нажмите Enter, чтобы закрыть консоль...")
