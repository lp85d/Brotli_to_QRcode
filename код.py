//C:\brotli\brotli.exe -Z C:\vosk\voice_control.py -o C:\vosk\voice_control.py.br

import segno

with open(r'C:\vosk\voice_control.py.br', 'rb') as f:
    data = f.read()

# Генерируем QR-код напрямую из байтов (без Base64)
qr = segno.make(data, error='L')  # минимальный уровень коррекции
qr.save(r'C:\vosk\qr_raw_binary.png', scale=5)

