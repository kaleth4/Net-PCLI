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