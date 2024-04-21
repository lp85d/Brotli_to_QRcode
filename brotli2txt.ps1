# Путь к brotli.exe
$brotliPath = "C:\brotli\brotli.exe"

# Путь к файлу для сжатия
$filePath = "C:\Users\user\Desktop\ANSI_1.ps1"

# Путь к файлу, в который будет записан сжатый результат
$outputPath = "C:\Users\user\Desktop\brotli.txt"

# Вызов brotli.exe для сжатия файла
& $brotliPath $filePath -o $outputPath
