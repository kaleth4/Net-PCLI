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