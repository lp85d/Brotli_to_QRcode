using System;
using System.Drawing;
using ZXing;
using System.IO;
using System.Text;

namespace WebApplication1
{
    class Program
    {
        static void Main()
        {
            // Путь к brotli.exe
            string brotliPath = @"C:\brotli\brotli.exe";

            // Путь к файлу с QR кодом
            string qrImagePath = @"C:\Users\user\Desktop\brotli_to_qr.png";

            // Путь к файлу, в который будет записан распакованный текст
            string outputTextFilePath = @"C:\Users\user\Desktop\brotli_to_text.txt";

            // Чтение данных из QR кода
            BarcodeReader reader = new BarcodeReader();
            Bitmap bitmap = (Bitmap)Image.FromFile(qrImagePath);
            ZXing.Result result = reader.Decode(bitmap);

            // Распаковка данных из QR кода и запись в файл
            if (result != null)
            {
                string decodedData = result.Text;
                File.WriteAllText(outputTextFilePath, decodedData, Encoding.GetEncoding(1251)); // Используем кодировку Windows-1251 (ANSI)

                // Вызов brotli.exe для распаковки файла
                System.Diagnostics.Process process = new System.Diagnostics.Process();
                process.StartInfo.FileName = brotliPath;
                process.StartInfo.Arguments = $"-d {outputTextFilePath} -o {outputTextFilePath.Replace(".txt", "_uncompressed.txt")}";
                process.Start();
                process.WaitForExit();

                if (process.ExitCode == 0)
                {
                    Console.WriteLine("Распаковка данных завершена успешно.");
                }
                else
                {
                    Console.WriteLine("Ошибка при распаковке данных.");
                }
            }
            else
            {
                Console.WriteLine("QR код не распознан или не содержит данных.");
            }
        }
    }
}
