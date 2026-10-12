#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 02 - Descubrimiento de hosts
# Objetivo autorizado UNICO: 192.168.56.103  (bucle: 127.0.0.1)
# No se envia ningun paquete a otra direccion.
# ==================================================================
set -u

TARGET="192.168.56.103"
OUT="$HOME/evidencias/lab02"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 02 - DESCUBRIMIENTO DE HOSTS"
echo " Fecha UTC-04:00 : $(date -Is)"
echo " Objetivo        : $TARGET (autorizado)"
echo " Nmap            : $(nmap --version | head -1)"
echo " Salidas         : $OUT/<nombre>.{nmap,xml,gnmap}  (-oA)"
echo "=================================================================="

echo
echo "--- [2.0] Estado inicial del vecindario y de la interfaz ----------"
echo '$ ip neigh'
ip neigh
echo '$ ip -br addr'
ip -br addr
echo '$ ip route get 192.168.56.103   (¿por dónde sale el paquete?)'
ip route get "$TARGET"

echo
echo "--- [2.1] Ping ICMP clasico (referencia humana) -------------------"
echo "\$ ping -c 4 -W 2 $TARGET"
ping -c 4 -W 2 "$TARGET" 2>&1

echo
echo "--- [2.2] Descubrimiento por eco ICMP (-PE) ------------------------"
echo "\$ nmap -sn -PE -oA $OUT/icmp_echo $TARGET"
nmap -sn -PE -oA "$OUT/icmp_echo" "$TARGET" 2>&1

echo
echo "--- [2.3] Descubrimiento por marca de tiempo ICMP (-PP) ------------"
echo "\$ nmap -sn -PP -oA $OUT/icmp_ts $TARGET"
nmap -sn -PP -oA "$OUT/icmp_ts" "$TARGET" 2>&1

echo
echo "--- [2.4] Descubrimiento por SYN TCP sobre puertos comunes (-PS) ---"
echo "\$ nmap -sn -PS22,80,443,21 -oA $OUT/tcp_syn $TARGET"
nmap -sn -PS22,80,443,21 -oA "$OUT/tcp_syn" "$TARGET" 2>&1

echo
echo "--- [2.5] Descubrimiento por ACK TCP (-PA) -------------------------"
echo "\$ nmap -sn -PA22,80,443 -oA $OUT/tcp_ack $TARGET"
nmap -sn -PA22,80,443 -oA "$OUT/tcp_ack" "$TARGET" 2>&1

echo
echo "--- [2.6] Descubrimiento por UDP (-PU) -----------------------------"
echo "\$ nmap -sn -PU53,161,123 -oA $OUT/udp_ping $TARGET"
nmap -sn -PU53,161,123 -oA "$OUT/udp_ping" "$TARGET" 2>&1

echo
echo "--- [2.7] Descubrimiento por ARP (-PR) -----------------------------"
echo "\$ nmap -sn -PR -oA $OUT/arp_ping $TARGET"
nmap -sn -PR -oA "$OUT/arp_ping" "$TARGET" 2>&1

echo
echo "--- [2.8] Combinacion por defecto de nmap (varios mecanismos) ------"
echo "\$ nmap -sn -PS22,80,443 -PE -PP -oA $OUT/mixto $TARGET"
nmap -sn -PS22,80,443 -PE -PP -oA "$OUT/mixto" "$TARGET" 2>&1

echo
echo "--- [2.9] Mismo conjunto de pruebas sobre el bucle de trabajo ------"
echo "\$ nmap -sn -PE -PS22 -oA $OUT/loopback 127.0.0.1"
nmap -sn -PE -PS22 -oA "$OUT/loopback" 127.0.0.1 2>&1

echo
echo "--- [2.10] Resumen comparado de respuestas -------------------------"
echo "| Mecanismo        | ¿Respuesta del objetivo? |"
echo "|------------------|---------------------------|"
for f in icmp_echo icmp_ts tcp_syn tcp_ack udp_ping arp_ping mixto; do
  if [ -f "$OUT/$f.xml" ]; then
    if grep -q 'status state="up"' "$OUT/$f.xml"; then
      echo "| $f | si |"
    else
      echo "| $f | NO -> host NO considerado activo |"
    fi
  else
    echo "| $f | (sin salida / comando no soportado) |"
  fi
done

echo
echo "### Ficheros generados (-oA):"
ls -la "$OUT"

echo
echo "=================================================================="
echo " LABORATORIO 02 - FIN  $(date -Is)"
echo "=================================================================="
