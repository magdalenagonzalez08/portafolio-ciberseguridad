#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 03 (e) - Dos medidas que fallaron o quedaron sin explicar
#  (a) tcpdump capturo 0 paquetes incluso donde nmap si ve respuestas
#  (b) -sT tarda ~4,5 s mas que -sS en un unico puerto abierto
# Objetivo autorizado UNICO: 192.168.56.103
# ==================================================================
set -u

TARGET="192.168.56.103"
OUT="$HOME/evidencias/lab03"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 03 (e)   $(date -Is)"
echo "=================================================================="

echo
echo "--- [A] Por que tcpdump no capturo nada ----------------------------"
echo '$ cat /tmp/tcpdump.log'
cat /tmp/tcpdump.log 2>&1 || echo "  (sin archivo de log)"
echo '$ cat /tmp/tcpdump2.log'
cat /tmp/tcpdump2.log 2>&1 || echo "  (sin archivo de log)"
echo '$ ls -l /tmp/lab03_cap.pcap'
ls -l /tmp/lab03_cap.pcap 2>&1 || echo "  (el fichero pcap no se creo)"
echo
echo "Intento manual para ver el error real:"
echo '$ timeout 3 tcpdump -i lo -n -c 3 2>&1 | head -5'
timeout 3 tcpdump -i lo -n -c 3 2>&1 | head -5

echo
echo "--- [B] Coste del DNS en -sT, con y sin -n --------------------------"
for P in 22 21; do
  S=$(date +%s.%N)
  nmap -sT -p $P --max-retries 1 -oN /dev/null "$TARGET" >/dev/null 2>&1
  E=$(date +%s.%N)
  echo "  -sT -p $P SIN -n -> $(awk -v a="$S" -v b="$E" 'BEGIN{printf "%.2f", b-a}') s"
  S=$(date +%s.%N)
  nmap -sT -p $P -n --max-retries 1 -oN /dev/null "$TARGET" >/dev/null 2>&1
  E=$(date +%s.%N)
  echo "  -sT -p $P CON  -n -> $(awk -v a="$S" -v b="$E" 'BEGIN{printf "%.2f", b-a}') s"
  S=$(date +%s.%N)
  nmap -sS -p $P -n --max-retries 1 -oN /dev/null "$TARGET" >/dev/null 2>&1
  E=$(date +%s.%N)
  echo "  -sS -p $P CON  -n -> $(awk -v a="$S" -v b="$E" 'BEGIN{printf "%.2f", b-a}') s"
  echo
done

echo "--- [C] Repeticion de la prueba de registro, ahora con -n -----------"
T0=$(date +%s)
nmap -sT -p 22 -n --max-retries 1 -oN /dev/null "$TARGET" 2>&1 | grep 'Nmap done'
sleep 4
E1=$(journalctl --since "@$T0" --no-pager 2>/dev/null | grep -c sshd || true)
echo "  eventos de sshd tras -sT con -n: $E1"
journalctl --since "@$T0" --no-pager -o short-precise 2>/dev/null | grep sshd | tail -4

echo
echo "=================================================================="
echo " FIN $(date -Is)"
echo "=================================================================="
