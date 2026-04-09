<div align="center">

```
 _   _ _____ _____   ____   ____    ___  _     ___ 
| \ | | ____|_   _| |  _ \ / ___|  / _ \| |   |_ _|
|  \| |  _|   | |   | |_) | |     | | | | |    | | 
| |\  | |___  | |   |  __/| |___  | |_| | |___ | | 
|_| \_|_____| |_|   |_|    \____|  \___/|_____|___|

  ____   ____  ____  ___ ____ _____ ____  
 / ___| / ___||  _ \|_ _|  _ \_   _/ ___| 
 \___ \| |    | |_) || || |_) || | \___ \ 
  ___) | |___ |  _ < | ||  __/ | |  ___) |
 |____/ \____||_| \_\___|_|    |_| |____/ 
```

# Net-PCLI — Scripts de Análisis de Red

**ifconfig · ipconfig · MAC · Wi-Fi Scanner — Cross-Platform**

[![Shell](https://img.shields.io/badge/Bash-5.x-4eaa25?style=flat-square&logo=gnubash&logoColor=white)]()
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391fe?style=flat-square&logo=powershell&logoColor=white)]()
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-4a4a4a?style=flat-square)]()
[![Purpose](https://img.shields.io/badge/Purpose-Recon%20%7C%20CTF%20%7C%20Admin-2e7d32?style=flat-square)]()

> Scripts cross-platform para enumeración de red: tablas organizadas de interfaces IP, detección de MAC addresses y escaneo de redes Wi-Fi con sus BSSID.

</div>

---

## Índice

- [Scripts incluidos](#-scripts-incluidos)
- [Misión 1: Tablas de IP / Interfaces](#-misión-1-tablas-de-ip--interfaces)
- [Misión 2: Detección de MAC Address](#-misión-2-detección-de-mac-address)
- [Misión 3: Wi-Fi Scanner (SSID + BSSID)](#-misión-3-wi-fi-scanner-ssid--bssid)
- [Instalación y uso rápido](#-instalación-y-uso-rápido)
- [Casos de uso en pentesting](#-casos-de-uso-en-pentesting)

---

## 📁 Scripts Incluidos

```
net-pcli/
├── linux/
│   ├── red_linux.sh          # ifconfig → tabla organizada
│   ├── mac_linux.sh          # Detección de MAC addresses
│   └── wifi_scan.sh          # Escaneo SSID + BSSID
│
└── windows/
    ├── ipconfig_tabla.ps1    # ipconfig tradicional → tabla PowerShell
    ├── netip_tabla.ps1       # Get-NetIPConfiguration → tabla
    ├── mac_windows.ps1       # Detección de MAC addresses
    └── wifi_scan.ps1         # Escaneo SSID + BSSID
```

---

## 🖥️ Misión 1: Tablas de IP / Interfaces

### Linux — `red_linux.sh`

Convierte la salida en bloque de `ifconfig` a una tabla organizada con interfaz, estado, IP y MAC.

```bash
#!/bin/bash
echo "---------------------------------------------------------------------------------"
printf "%-15s | %-10s | %-18s | %-17s\n" "Interfaz" "Estado" "Dirección IPv4" "MAC Address"
echo "---------------------------------------------------------------------------------"

ifconfig -a | awk -v RS= -v FS="\n" '{
    iface = $1; sub(/:.*/, "", iface);
    estado = (match($0, /UP/) ? "Activa" : "Inactiva");
    ipv4 = "Sin asignar"; mac = "Sin asignar";
    if (match($0, /inet [0-9.]+/)) { ipv4 = substr($0, RSTART+5, RLENGTH-5); }
    if (match($0, /ether [0-9a-fA-F:]+/)) { mac = substr($0, RSTART+6, RLENGTH-6); }
    printf "%-15s | %-10s | %-18s | %-17s\n", iface, estado, ipv4, mac;
}'
echo "---------------------------------------------------------------------------------"
```

**Output:**
```
---------------------------------------------------------------------------------
Interfaz        | Estado     | Dirección IPv4     | MAC Address     
---------------------------------------------------------------------------------
eth0            | Activa     | 192.168.1.50       | 00:0c:29:ab:cd:ef
lo              | Activa     | 127.0.0.1          | 00:00:00:00:00:00
tun0            | Activa     | 10.10.14.5         | Sin asignar     
wlan0           | Inactiva   | Sin asignar        | 48:2a:e3:11:22:33
---------------------------------------------------------------------------------
```

**Uso:**
```bash
chmod +x red_linux.sh && ./red_linux.sh
```

---

### Windows — `ipconfig_tabla.ps1`

Parsea la salida de `ipconfig` y la convierte en objeto PowerShell con tabla formateada.

```powershell
$salida_ipconfig = ipconfig
$resultados = @()
$adaptador_actual = ""

foreach ($linea in $salida_ipconfig) {
    if ($linea -match "^[A-Za-z]") { 
        $adaptador_actual = $linea -replace ":","" 
    }
    if ($linea -match "IPv4.*: ([\d\.]+)") {
        $resultados += [PSCustomObject]@{ 
            Adaptador = $adaptador_actual.Trim()
            IPv4      = $matches[1] 
        }
    }
}

Write-Host "`n=== Tabla basada en ipconfig ===" -ForegroundColor Cyan
$resultados | Format-Table -AutoSize
```

**Output:**
```
=== Tabla basada en ipconfig ===

Adaptador                        IPv4
---------                        ----
Ethernet adapter Ethernet        192.168.1.100
VPN Adapter                      10.10.14.5
```

---

### Windows — `netip_tabla.ps1`

Usa `Get-NetIPConfiguration` (más robusto que `ipconfig`) para extraer datos nativos.

```powershell
Write-Host "`n=== Tabla usando Get-NetIPConfiguration ===" -ForegroundColor Cyan

Get-NetIPConfiguration | Select-Object `
    InterfaceAlias, 
    InterfaceDescription, 
    @{Name="IPv4";    Expression={$_.IPv4Address.IPAddress}},
    @{Name="Gateway"; Expression={$_.IPv4DefaultGateway.NextHop}} | 
Format-Table -AutoSize
```

**Output:**
```
=== Tabla usando Get-NetIPConfiguration ===

InterfaceAlias  InterfaceDescription           IPv4           Gateway
--------------  --------------------           ----           -------
Ethernet        Intel(R) Ethernet Connection   192.168.1.100  192.168.1.1
Wi-Fi           Intel(R) Wireless-AC 9260      192.168.1.101  192.168.1.1
```

---

## 🔌 Misión 2: Detección de MAC Address

### Linux — `mac_linux.sh`

Lee directamente desde `/sys/class/net/` — el método más fiable en Linux moderno.

```bash
#!/bin/bash
echo "=== Direcciones MAC del Sistema ==="
echo "-----------------------------------"
printf "%-15s | %-17s\n" "Interfaz" "MAC Address"
echo "-----------------------------------"

for iface in /sys/class/net/*; do
    interfaz=$(basename "$iface")
    mac=$(cat "$iface/address" 2>/dev/null)
    printf "%-15s | %-17s\n" "$interfaz" "$mac"
done

echo "-----------------------------------"
```

**Output:**
```
=== Direcciones MAC del Sistema ===
-----------------------------------
Interfaz        | MAC Address     
-----------------------------------
eth0            | 00:0c:29:ab:cd:ef
lo              | 00:00:00:00:00:00
tun0            | (vacío - interfaz virtual)
wlan0           | 48:2a:e3:11:22:33
-----------------------------------
```

**Uso:**
```bash
chmod +x mac_linux.sh && ./mac_linux.sh
```

---

### Windows — `mac_windows.ps1`

```powershell
Write-Host "=== Direcciones MAC del Sistema ===" -ForegroundColor Cyan
Get-NetAdapter | Select-Object Name, InterfaceDescription, MacAddress | Format-Table -AutoSize

# Alternativa nativa CMD (sin PowerShell):
# getmac /v /fo table
```

**Output:**
```
=== Direcciones MAC del Sistema ===

Name      InterfaceDescription                     MacAddress
----      --------------------                     ----------
Ethernet  Intel(R) Ethernet Connection (4) I219-LM 00-1A-2B-3C-4D-5E
Wi-Fi     Intel(R) Wireless-AC 9260                A4-C3-F0-85-AC-B5
```

---

## 📡 Misión 3: Wi-Fi Scanner (SSID + BSSID)

### Linux — `wifi_scan.sh`

Usa `nmcli` (NetworkManager) — estándar en distribuciones modernas.

```bash
#!/bin/bash
echo "Buscando redes Wi-Fi cercanas..."
echo "--------------------------------------------------------"
printf "%-25s | %-17s\n" "SSID (Nombre de Red)" "BSSID (MAC del Router)"
echo "--------------------------------------------------------"

nmcli -t -f SSID,BSSID dev wifi | while IFS=: read -r ssid bssid; do
    if [ -z "$ssid" ]; then
        ssid="<Red Oculta>"
    fi
    printf "%-25s | %-17s\n" "$ssid" "$bssid"
done

echo "--------------------------------------------------------"
```

**Output:**
```
Buscando redes Wi-Fi cercanas...
--------------------------------------------------------
SSID (Nombre de Red)      | BSSID (MAC del Router)
--------------------------------------------------------
MiRed-5G                  | A4:C3:F0:85:AC:B5
Vecinos_2.4G              | 00:1A:2B:3C:4D:5E
<Red Oculta>              | 78:DA:07:12:34:56
TP-Link_EXT               | B8:27:EB:AA:BB:CC
--------------------------------------------------------
```

**Uso:**
```bash
chmod +x wifi_scan.sh && ./wifi_scan.sh
# Nota: requiere sudo en algunos sistemas o modo monitor activo
```

---

### Windows — `wifi_scan.ps1`

Parsea la salida de `netsh wlan show networks mode=bssid`.

```powershell
Write-Host "Buscando redes Wi-Fi cercanas..." -ForegroundColor Yellow
$redes_wifi = netsh wlan show networks mode=bssid
$ssid_actual = ""

Write-Host "`n$("-".PadRight(25, "-")) | $("-".PadRight(17, "-"))"
Write-Host "$("SSID (Nombre de Red)".PadRight(25)) | BSSID (MAC del Router)"
Write-Host "$("-".PadRight(25, "-")) | $("-".PadRight(17, "-"))"

foreach ($linea in $redes_wifi) {
    if ($linea -match "^SSID \d+ : (.*)$") {
        $ssid_actual = $matches[1].Trim()
        if ($ssid_actual -eq "") { $ssid_actual = "<Red Oculta>" }
    }
    if ($linea -match "BSSID \d+ *: (.*)$") {
        Write-Host "$($ssid_actual.PadRight(25)) | $($matches[1].Trim())"
    }
}
Write-Host "$("-".PadRight(25, "-")) | $("-".PadRight(17, "-"))"
```

---

## 🚀 Instalación y Uso Rápido

### Linux

```bash
# Clonar y dar permisos
git clone https://github.com/tuusuario/net-pcli.git
cd net-pcli/linux
chmod +x *.sh

# Ejecutar
./red_linux.sh        # Tabla de interfaces IP
./mac_linux.sh        # MACs del sistema
./wifi_scan.sh        # Redes Wi-Fi + BSSID
```

### Windows (PowerShell)

```powershell
# Clonar y ejecutar
git clone https://github.com/tuusuario/net-pcli.git
cd net-pcli\windows

# Si hay restricciones de ejecución:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ejecutar
.\ipconfig_tabla.ps1   # Tabla desde ipconfig
.\netip_tabla.ps1      # Tabla desde Get-NetIPConfiguration
.\mac_windows.ps1      # MACs del sistema
.\wifi_scan.ps1        # Redes Wi-Fi + BSSID
```

---

## 🎯 Casos de Uso en Pentesting

```bash
# Identificar interfaces VPN activas (tun0) para HTB/THM
./red_linux.sh | grep tun

# Obtener la MAC para spoofing
./mac_linux.sh | grep eth0

# Mapear redes vecinas en un engagement de red inalámbrica
sudo ./wifi_scan.sh | tee wifi_recon.txt

# Windows: Enumerar adaptadores en post-explotación
.\netip_tabla.ps1 | Out-File -FilePath C:\Windows\Temp\net_enum.txt
```

---

<div align="center">

**Scripts simples. Output limpio. Información lista para usar.**

`ifconfig | awk magic → tabla → pentest`

</div>
