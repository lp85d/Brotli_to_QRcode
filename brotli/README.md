Как всё упаковывалось:
1. Наша задача запаковать исходный код ‪C:\Users\user\Desktop\ZALIVKA.py в Qrcode
2. Запишем путь до файла в ‪C:\brotli\brotli2txt.ps1 запустим и получим C:\brotli\brotli.txt  
`C:\Windows\system32>powershell.exe -ExecutionPolicy Bypass -File "C:\brotli\brotli2txt.ps1"
failed to open output file [C:\brotli\brotli.txt]: File exists`
3. Сгенерируем base64 запустив ‪C:\brotli\decode_base64.py получим ‪C:\brotli\base64.txt
4. Последний этап ‪собираем изображение C:\brotli\brotli_txt_to_qr.py вывод C:\brotli\base64_data_qr.png
5. Готово!
![base64_data_qr](https://github.com/user-attachments/assets/025e8732-2cb8-4227-bf57-70542920d83d)
