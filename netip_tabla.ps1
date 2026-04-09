# Guarda este archivo como netip_tabla.ps1 y ejecútalo en PowerShell
Write-Host "`n=== Tabla usando Get-NetIPConfiguration ===" -ForegroundColor Cyan

Get-NetIPConfiguration | Select-Object `
    InterfaceAlias, 
    InterfaceDescription, 
    @{Name="IPv4"; Expression={$_.IPv4Address.IPAddress}},
    @{Name="Gateway"; Expression={$_.IPv4DefaultGateway.NextHop}} | 
Format-Table -AutoSize