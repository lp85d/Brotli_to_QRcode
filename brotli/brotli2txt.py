import subprocess

# Пути к файлам
brotli_path = r"C:\brotli\brotli.exe"
file_path = r"C:\brotli\index.php"
output_path = r"C:\brotli\brotli.txt"

# Команда для запуска
command = [brotli_path, file_path, '-o', output_path]

try:
    result = subprocess.run(command, check=True, capture_output=True, text=True)
    print("Файл успешно сжат.")
except subprocess.CalledProcessError as e:
    print(f"Ошибка при сжатии: {e.stderr}")
except FileNotFoundError:
    print("brotli.exe не найден. Проверьте путь.")
