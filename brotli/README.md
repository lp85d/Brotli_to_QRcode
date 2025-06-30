Как всё упаковывалось:
1. Наша задача запаковать исходный код ‪`C:\Users\user\Desktop\ZALIVKA.py` в Qrcode
2. Запишем путь до файла в `‪C:\brotli\brotli2txt.py` запустим и получим `C:\brotli\brotli.txt`
3. Сгенерируем base64 запустив `‪C:\brotli\decode_base64.py` получим `‪C:\brotli\base64.txt`
4. Последний этап ‪собираем изображение `C:\brotli\brotli_txt_to_qr.py` вывод `C:\brotli\base64_data_qr.png`
5. Готово!

<img src="https://github.com/user-attachments/assets/025e8732-2cb8-4227-bf57-70542920d83d" alt="base64_data_qr" width="30%"/>  
  
`Python 3.13.2`   
`(tags/v3.13.2:4f8bb39, Feb  4 2025, 15:23:48)`   
`[MSC v.1942 64 bit (AMD64)] on win32`  
`Type "help", "copyright", "credits" or "license()" for more information.`  
`=== RESTART: C:\brotli\brotli_txt_to_qr_no_phone.py ===`  
`Попытка преобразовать файл: C:\brotli\brotli.txt в ОДИН QR-код.`  
`Размер данных (2162 байт) предположительно подходит для одного QR-кода.`  
`Один QR-код успешно создан и сохранен как 'brotli_data_qr.png'.`  
`Нажмите Enter, чтобы закрыть консоль...`

Это отработали `brotli_txt_to_qr_no_phone.py` и `Декодирования QR-кода обратно в бротили архив.py` для большего эффекта компрессии  

<img src="https://github.com/user-attachments/assets/27fc7beb-665e-4b8d-8a9b-019db90b26c9" alt="base64_data_qr" width="30%"/>
