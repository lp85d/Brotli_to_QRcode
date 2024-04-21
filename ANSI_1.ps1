Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class U {
        [DllImport("user32.dll")] public static extern bool ReleaseCapture();
        [DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
    }
"@

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Net.Http

function GetCryptoPrice { return (Invoke-WebRequest -Uri "https://min-api.cryptocompare.com/data/price?fsym=toncoin&tsyms=USD" | ConvertFrom-Json).USD }

function UpdateLabel { $label.Text = "TON: $(GetCryptoPrice) USD" }

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.BackColor = [System.Drawing.Color]::Black
$form.ForeColor = [System.Drawing.Color]::Green
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(100, 50)
$form.Opacity = 0.8

$trackBar = New-Object System.Windows.Forms.TrackBar
$trackBar.Size = New-Object System.Drawing.Size(130, 45)
$trackBar.Minimum = 10
$trackBar.Maximum = 100
$trackBar.Value = 80
$trackBar.TickFrequency = 10
$trackBar.Visible = $false
$trackBar.Add_ValueChanged({ $form.Opacity = [double]($trackBar.Value / 100) })
$trackBar.Add_MouseUp({ $trackBar.Visible = $false })
$form.Controls.Add($trackBar)

$label = New-Object System.Windows.Forms.Label
$label.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(5, 15)
$form.Controls.Add($label)

$buttonColor, $buttonClose, $buttonText, $buttonOpacity = 1..4 | ForEach-Object {
    $button = New-Object System.Windows.Forms.Button
    $button.Size = New-Object System.Drawing.Size(10, 10)
    $button.Location = if ($_ -eq 1) { New-Object System.Drawing.Point(0, 0) } elseif ($_ -eq 2) { New-Object System.Drawing.Point(125, 0) } elseif ($_ -eq 3) { New-Object System.Drawing.Point(0, 40) } else { New-Object System.Drawing.Point(125, 40) }
    $button.Text = if ($_ -eq 1) { "Color" } elseif ($_ -eq 2) { "X" } elseif ($_ -eq 3) { "Text" } else { "Opacity" }
    if ($_ -eq 1) {
        $button.Add_Click({
            $colorDialog = New-Object System.Windows.Forms.ColorDialog
            $colorDialog.AllowFullOpen = $true
            if ($colorDialog.ShowDialog() -eq "OK") {
                $form.BackColor = $colorDialog.Color
            }
        })
    } elseif ($_ -eq 2) {
        $button.Add_Click({ $form.Close() })
    } elseif ($_ -eq 3) {
        $button.Add_Click({
            $colorDialog = New-Object System.Windows.Forms.ColorDialog
            $colorDialog.AllowFullOpen = $true
            if ($colorDialog.ShowDialog() -eq "OK") {
                $label.ForeColor = $colorDialog.Color
            }
        })
    } else {
        $button.Add_Click({
            $trackBar.Location = New-Object System.Drawing.Point([int](($form.ClientSize.Width - $trackBar.Width) / 2), [int]($form.ClientSize.Height - $trackBar.Height + 10))
            $trackBar.Visible = !$trackBar.Visible
        })
    }
    $form.Controls.Add($button)
}

$form.Add_MouseDown({ [U]::ReleaseCapture(); [U]::SendMessage($form.Handle, 0xA1, 0x2, 0) })
$form.Add_MouseClick({ if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Right) { $form.Close() } })

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 10000
$timer.Add_Tick({ UpdateLabel })
$timer.Start()

UpdateLabel

$form.ShowDialog()