# Путь к brotli.exe
$brotliPath = "C:\brotli\brotli.exe"

# Путь к файлу для сжатия
$filePath = "C:\Users\user\Desktop\ZALIVKA.py"

# Путь к файлу, в который будет записан сжатый результат
$outputPath = "C:\brotli\brotli.txt"

# Вызов brotli.exe для сжатия файла
& $brotliPath $filePath -o $outputPath
