#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 03 (c) - Confirmacion de dos mecanismos
#  (a) ¿En qué interfaz captura nmap cuando el destino es la propia IP?
#  (b) ¿Deja rastro una conexion TCP real en los registros del sistema?
# Objetivo autorizado UNICO: 192.168.56.103 y 127.0.0.1
# ==================================================================
set -u

TARGET="192.168.56.103"
OUT="$HOME/evidencias/lab03"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 03 (c)   $(date -Is)"
echo "=================================================================="

echo
echo "--- [A] Interfaz de captura declarada por nmap (-d) -----------------"
echo "\$ nmap -sS -p 22 -d $TARGET 2>&1 | grep -i 'capture filter'"
nmap -sS -p 22 -d "$TARGET" 2>&1 | grep -i 'capture filter'
echo
echo "\$ nmap -sS -p 22 -d 127.0.0.1 2>&1 | grep -i 'capture filter'"
nmap -sS -p 22 -d 127.0.0.1 2>&1 | grep -i 'capture filter'

echo
echo "--- [B] Resolucion de ruta y direcciones implicadas -----------------"
echo '$ ip route get 192.168.56.103'
ip route get "$TARGET"
echo '$ ip route get 127.0.0.1'
ip route get 127.0.0.1

echo
echo "--- [C] Registro completo del sistema durante cada prueba -----------"
echo "Metodo: marca de tiempo, ejecucion, despues se leen SOLO los eventos"
echo "        posteriores a la marca."
echo

T0=$(date +%s)
echo "\$ nmap -sS -p 22 --max-retries 1 -oN /dev/null $TARGET"
nmap -sS -p 22 --max-retries 1 -oN /dev/null "$TARGET" 2>&1 | grep 'Nmap done'
sleep 2
echo "Eventos del sistema posteriores a la marca (SYN):"
journalctl --since "@$T0" --no-pager -n 30 2>&1 | tail -20 || echo "  (journalctl no disponible)"
CONT_SYN=$(journalctl --since "@$T0" --no-pager 2>/dev/null | wc -l)
echo "  total de eventos desde la marca tras SYN: $CONT_SYN"

echo
T1=$(date +%s)
echo "\$ nmap -sT -p 22 --max-retries 1 -oN /dev/null $TARGET"
nmap -sT -p 22 --max-retries 1 -oN /dev/null "$TARGET" 2>&1 | grep 'Nmap done'
sleep 2
echo "Eventos del sistema posteriores a la marca (connect):"
journalctl --since "@$T1" --no-pager -n 30 2>&1 | tail -20 || echo "  (journalctl no disponible)"
CONT_CT=$(journalctl --since "@$T1" --no-pager 2>/dev/null | wc -l)
echo "  total de eventos desde la marca tras connect: $CONT_CT"

echo
echo "--- [D] Prueba de referencia con una conexion hecha a mano ----------"
echo "Si una conexion TCP normal deja registro y el escaneo -sT no,"
echo "entonces el metodo de lectura esta mal y hay que corregirlo."
T2=$(date +%s)
echo "\$ timeout 2 bash -c 'exec 3<>/dev/tcp/$TARGET/22'  (conexion real)"
timeout 2 bash -c "exec 3<>/dev/tcp/$TARGET/22" 2>&1 && echo "  conexion abierta y cerrada" || echo "  (fallo al conectar)"
sleep 2
journalctl --since "@$T2" --no-pager -n 20 2>&1 | tail -15 || true
CONT_MAN=$(journalctl --since "@$T2" --no-pager 2>/dev/null | wc -l)
echo "  total de eventos desde la marca tras conexion manual: $CONT_MAN"

echo
echo "--- [E] Resumen de eventos por prueba --------------------------------"
echo "  SYN   (nmap -sS) ............ $CONT_SYN eventos nuevos"
echo "  connect (nmap -sT) .......... $CONT_CT eventos nuevos"
echo "  conexion manual (bash) ...... $CONT_MAN eventos nuevos"

echo
echo "=================================================================="
echo " FIN $(date -Is)"
echo "=================================================================="
