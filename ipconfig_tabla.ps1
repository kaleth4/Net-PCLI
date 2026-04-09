# Guarda este archivo como ipconfig_tabla.ps1 y ejecútalo en PowerShell
$salida_ipconfig = ipconfig
$resultados = @()
$adaptador_actual = ""

foreach ($linea in $salida_ipconfig) {
    # Detectar el nombre del adaptador (líneas que no empiezan con espacio)
    if ($linea -match "^[A-Za-z]") { 
        $adaptador_actual = $linea -replace ":","" 
    }
    # Detectar la dirección IPv4
    if ($linea -match "IPv4.*: ([\d\.]+)") {
        $resultados += [PSCustomObject]@{ 
            Adaptador = $adaptador_actual.Trim()
            IPv4 = $matches[1] 
        }
    }
}

Write-Host "`n=== Tabla basada en ipconfig tradicional ===" -ForegroundColor Cyan
$resultados | Format-Table -AutoSize