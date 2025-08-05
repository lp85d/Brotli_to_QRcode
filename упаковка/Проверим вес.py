import hashlib

with open(r'C:\vosk\1voice_control.py.br', 'rb') as f:
    data = f.read()

print("SHA256:", hashlib.sha256(data).hexdigest())
print("Length:", len(data))
