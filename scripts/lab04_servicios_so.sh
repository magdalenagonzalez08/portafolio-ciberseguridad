#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 04 - Servicios y sistema operativo
# Objetivo autorizado UNICO: 192.168.56.103   (bucle: 127.0.0.1)
# Se separan tres cosas:
#   (i)   respuestas observadas  (banners y cabeceras literales)
#   (ii)  identificaciones hechas por la herramienta
#   (iii) inferencias que necesitan validacion
# ==================================================================
set -u

TARGET="192.168.56.103"
LOOP="127.0.0.1"
OUT="$HOME/evidencias/lab04"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 04 - SERVICIOS Y SISTEMA OPERATIVO"
echo " Fecha: $(date -Is)"
echo " Objetivo autorizado: $TARGET"
echo " Nmap: $(nmap --version | head -1)"
echo " Salidas: $OUT (formato -oA)"
echo "=================================================================="

echo
echo "--- [4.1] (i) RESPUESTA OBSERVADA: banner FTP crudo ----------------"
echo "\$ timeout 4 bash -c 'exec 3<>/dev/tcp/$TARGET/21; head -1 <&3'"
timeout 4 bash -c "exec 3<>/dev/tcp/$TARGET/21; head -1 <&3" 2>&1

echo
echo "--- [4.2] (i) RESPUESTA OBSERVADA: banner SSH crudo -----------------"
echo "\$ timeout 4 bash -c 'exec 3<>/dev/tcp/$TARGET/22; head -1 <&3'"
timeout 4 bash -c "exec 3<>/dev/tcp/$TARGET/22; head -1 <&3" 2>&1

echo
echo "--- [4.3] (i) RESPUESTA OBSERVADA: cabeceras HTTP --------------------"
echo "\$ curl -sSI --max-time 5 http://$TARGET:8080/"
curl -sSI --max-time 5 "http://$TARGET:8080/" 2>&1

echo
echo "--- [4.4] (i) RESPUESTA OBSERVADA: certificado TLS -------------------"
echo "\$ timeout 6 openssl s_client -connect $TARGET:8443 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates"
timeout 6 openssl s_client -connect "$TARGET:8443" -showcerts </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>&1

echo
echo "--- [4.5] (ii) IDENTIFICACION DE SERVICIOS POR NMAP (-sV) -----------"
echo "\$ nmap -sV --version-intensity 7 -p 21,22,8080,8443 --reason -oA $OUT/servicios $TARGET"
nmap -sV --version-intensity 7 -p 21,22,8080,8443 --reason -oA "$OUT/servicios" "$TARGET" 2>&1

echo
echo "--- [4.6] (ii) DETECCION DE SISTEMA OPERATIVO (-O) sobre el bucle ---"
echo "\$ nmap -O --reason -p 1-100 -oA $OUT/os_loopback $LOOP"
nmap -O --reason -p 1-100 -oA "$OUT/os_loopback" "$LOOP" 2>&1

echo
echo "--- [4.7] (ii) DETECCION DE SISTEMA OPERATIVO (-O) sobre la IP eth2 --"
echo "\$ nmap -O --reason -p 1-100 -oA $OUT/os_target $TARGET"
nmap -O --reason -p 1-100 -oA "$OUT/os_target" "$TARGET" 2>&1

echo
echo "--- [4.8] (ii) Deteccion de SO y servicios a la vez -----------------"
echo "\$ nmap -sV -O --version-intensity 5 -p 21,22,8080,8443 -oA $OUT/servicios_y_so $TARGET"
nmap -sV -O --version-intensity 5 -p 21,22,8080,8443 -oA "$OUT/servicios_y_so" "$TARGET" 2>&1

echo
echo "--- [4.9] Versiones concretas declaradas por -sV, sin interpretar ---"
grep -E '^[0-9]+/tcp' "$OUT/servicios.nmap" | sed 's/^/  /'

echo
echo "--- [4.10] Archivos de paquete del SO (identidad real, no estimada) --"
echo '$ systemd-detect-virt ; cat /etc/os-release | head -3 ; uname -r'
systemd-detect-virt
head -3 /etc/os-release
uname -r

echo
echo "--- [4.11] Ficheros generados ---------------------------------------"
ls -la "$OUT"

echo
echo "=================================================================="
echo " LABORATORIO 04 - FIN  $(date -Is)"
echo "=================================================================="
