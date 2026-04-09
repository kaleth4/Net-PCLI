# Escáner de SSID y BSSID para Windows
Write-Host "Buscando redes Wi-Fi cercanas..." -ForegroundColor Yellow

# Ejecutamos netsh para mostrar redes y sus BSSID
$redes_wifi = netsh wlan show networks mode=bssid
$ssid_actual = ""

Write-Host "`n$("-".PadRight(25, "-")) | $("-".PadRight(17, "-"))"
Write-Host "$("SSID (Nombre de Red)".PadRight(25)) | BSSID (MAC del Router)"
Write-Host "$("-".PadRight(25, "-")) | $("-".PadRight(17, "-"))"

foreach ($linea in $redes_wifi) {
    # Capturar el SSID
    if ($linea -match "^SSID \d+ : (.*)$") {
        $ssid_actual = $matches[1].Trim()
        if ($ssid_actual -eq "") { $ssid_actual = "<Red Oculta>" }
    }
    # Capturar los BSSID asociados a ese SSID
    if ($linea -match "BSSID \d+ *: (.*)$") {
        $bssid = $matches[1].Trim()
        Write-Host "$($ssid_actual.PadRight(25)) | $bssid"
    }
}
Write-Host "$("-".PadRight(25, "-")) | $("-".PadRight(17, "-"))"