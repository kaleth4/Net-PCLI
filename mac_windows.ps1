# Usamos Get-NetAdapter para obtener las MAC físicas de forma limpia
Write-Host "=== Direcciones MAC del Sistema ===" -ForegroundColor Cyan
Get-NetAdapter | Select-Object Name, InterfaceDescription, MacAddress | Format-Table -AutoSize