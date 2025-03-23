# Начнём с ASM 
Переносим файл в папку C:\masm32\crypto_widget.asm  
Откроем в программе C:\masm32\qeditor.exe  
Запускаем сборку Project -> Build All 
Готово C:\masm32\crypto_widget.exe 

<p>Используйте кодировку ANSI, это поможет сжать данные более эффективно</p>
<p>И так что делаем при необходимости хранения исходных кодов на стенке:<br />Запакуем любой файл допустим ps1 методом <a href="https://github.com/lp85d/Brotli_to_QRcode/blob/main/brotli2txt.ps1">Brotli</a>, сгенерируем из него <a href="https://github.com/lp85d/Brotli_to_QRcode/blob/main/BrotliQR.py">QRcode</a></p>

`powershell -ExecutionPolicy Bypass -File C:\user\Downloads\1.ps1 
`
<p>Может потребоваться дать права на выполнение скриптов:<br /><code>Set-ExecutionPolicy RemoteSigned</code><br /><code>Unblock-File -Path C:\Users\user\Desktop\brotli2txt.ps1</code></p>
<p>Так же установите библиотеку если такой не имеется:<br /><code>pip install qrcode
 <br />pip install pillow<br /></code></p>
<p>А теперь считаем <a href="https://github.com/lp85d/Brotli_to_QRcode/blob/main/brotli_to_qr.png">изображение</a>&nbsp;моей <a href="https://github.com/lp85d/Brotli_to_QRcode/blob/main/QRcode2Brotli2txt.cs">программой</a> таким&nbsp;образом легко получить исходный код из распечатанной картинки</p>
