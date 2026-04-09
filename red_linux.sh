#!/bin/bash
# Guarda este archivo como red_linux.sh y dale permisos de ejecución: chmod +x red_linux.sh

echo "---------------------------------------------------------------------------------"
printf "%-15s | %-10s | %-18s | %-17s\n" "Interfaz" "Estado" "Dirección IPv4" "MAC Address"
echo "---------------------------------------------------------------------------------"

ifconfig -a | awk -v RS= -v FS="\n" '{
    iface = $1; sub(/:.*/, "", iface);
    estado = (match($0, /UP/) ? "Activa" : "Inactiva");
    ipv4 = "Sin asignar"; mac = "Sin asignar";
    
    # Buscar IPv4
    if (match($0, /inet [0-9.]+/)) { ipv4 = substr($0, RSTART+5, RLENGTH-5); }
    # Buscar MAC Address
    if (match($0, /ether [0-9a-fA-F:]+/)) { mac = substr($0, RSTART+6, RLENGTH-6); }
    
    printf "%-15s | %-10s | %-18s | %-17s\n", iface, estado, ipv4, mac;
}'
echo "---------------------------------------------------------------------------------"