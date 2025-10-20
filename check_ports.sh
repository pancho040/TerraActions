#!/bin/bash
echo "=== Verificación de puertos ==="
echo ""
echo "Puertos abiertos en UFW:"
sudo ufw status numbered
echo ""
echo "Puertos en escucha:"
sudo netstat -tulpn | grep LISTEN
echo ""
echo "Contenedores Docker:"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"