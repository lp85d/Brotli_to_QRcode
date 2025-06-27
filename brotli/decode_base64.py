import base64

# Чтение данных из файла в кодировке ANSI
with open("C:\\brotli\\brotli.txt", "rb") as f:
    text_bytes = f.read()

# Кодирование данных в формат base64
base64_data = base64.b64encode(text_bytes)

# Запись данных в файл 1base64.txt
with open("C:\\brotli\\base64.txt", "wb") as f:
    f.write(base64_data)

print("Данные успешно закодированы и записаны в файл base64.txt.")