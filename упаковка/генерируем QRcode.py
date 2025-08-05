import segno

with open(r'C:\vosk\1voice_control.py.br', 'rb') as f:
    data = f.read(100)  # первые 100 байт

qr = segno.make_qr(data, mode='byte')
qr.save(r'C:\vosk\1partial_qr.png', scale=5)
