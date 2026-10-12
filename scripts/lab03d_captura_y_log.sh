#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 03 (d) - Ultimas dos comprobaciones
#  (a) Captura real de paquetes durante un -sS hacia la propia IP
#  (b) Comparacion de registro entre nmap -sT, nc y una conexion manual
# Objetivo autorizado UNICO: 192.168.56.103 y 127.0.0.1
# ==================================================================
set -u

TARGET="192.168.56.103"
LOOP="127.0.0.1"
OUT="$HOME/evidencias/lab03"
CAP="/tmp/lab03_cap.pcap"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 03 (d)   $(date -Is)"
echo "=================================================================="

echo
echo "--- [A] ¿Puede capturar paquetes sin root? ---------------------------"
echo '$ command -v tcpdump'
command -v tcpdump || echo "  tcpdump NO instalado"
if command -v tcpdump >/dev/null 2>&1; then
  echo '$ getcap -v /usr/bin/tcpdump'
  getcap -v /usr/bin/tcpdump 2>&1
  echo '$ ls -l $(command -v tcpdump)'
  ls -l "$(command -v tcpdump)"
fi

echo
echo "--- [B] Captura en loopback durante -sS hacia 192.168.56.103 --------"
if command -v tcpdump >/dev/null 2>&1; then
  rm -f "$CAP"
  tcpdump -i lo -n -w "$CAP" "host $TARGET" >/tmp/tcpdump.log 2>&1 &
  TPID=$!
  sleep 1
  echo "\$ nmap -sS -p 1-60 --max-retries 1 -oN /dev/null $TARGET"
  nmap -sS -p 1-60 --max-retries 1 -oN /dev/null "$TARGET" 2>&1 | grep -E 'Not shown|Nmap done'
  sleep 1
  kill "$TPID" 2>/dev/null
  wait "$TPID" 2>/dev/null
  echo "Paquetes capturados hacia/desde $TARGET en lo:"
  tcpdump -nn -r "$CAP" 2>/dev/null | head -25 || echo "  (sin paquetes capturados)"
  N1=$(tcpdump -nn -r "$CAP" 2>/dev/null | wc -l)
  echo "  total de paquetes: $N1"

  echo
  echo "--- [Misma captura sobre 127.0.0.1 como referencia] ----------------"
  rm -f "$CAP"
  tcpdump -i lo -n -w "$CAP" "host $LOOP" >/tmp/tcpdump2.log 2>&1 &
  TPID=$!
  sleep 1
  echo "\$ nmap -sS -p 1-60 --max-retries 1 -oN /dev/null $LOOP"
  nmap -sS -p 1-60 --max-retries 1 -oN /dev/null "$LOOP" 2>&1 | grep -E 'Not shown|Nmap done'
  sleep 1
  kill "$TPID" 2>/dev/null
  wait "$TPID" 2>/dev/null
  echo "Paquetes capturados hacia/desde $LOOP en lo:"
  tcpdump -nn -r "$CAP" 2>/dev/null | head -25 || echo "  (sin paquetes capturados)"
  N2=$(tcpdump -nn -r "$CAP" 2>/dev/null | wc -l)
  echo "  total de paquetes: $N2"
  echo
  echo "Resumen captura:  $TARGET -> $N1 paquetes    $LOOP -> $N2 paquetes"
else
  echo "  No se puede realizar la captura, tcpdump no esta instalado."
  echo "  Esta comprobacion queda PENDIENTE."
fi

echo
echo "--- [C] Registro de sshd con tres metodos, misma ventana ------------"
T0=$(date +%s)
echo "\$ nmap -sT -p 22 --max-retries 1 -oN /dev/null $TARGET"
nmap -sT -p 22 --max-retries 1 -oN /dev/null "$TARGET" 2>&1 | grep 'Nmap done'
sleep 4
echo "Eventos desde la marca (nmap -sT):"
journalctl --since "@$T0" --no-pager -o short-precise 2>/dev/null | grep -E 'sshd' | tail -6
E1=$(journalctl --since "@$T0" --no-pager 2>/dev/null | grep -c sshd || true)
echo "  eventos de sshd: $E1"

T1=$(date +%s)
echo "\$ nc -z -w 2 $TARGET 22"
nc -z -w 2 "$TARGET" 22 2>&1 && echo "  nc ok"
sleep 4
echo "Eventos desde la marca (nc):"
journalctl --since "@$T1" --no-pager -o short-precise 2>/dev/null | grep -E 'sshd' | tail -6
E2=$(journalctl --since "@$T1" --no-pager 2>/dev/null | grep -c sshd || true)
echo "  eventos de sshd: $E2"

T2=$(date +%s)
echo "\$ timeout 3 bash -c 'exec 3<>/dev/tcp/$TARGET/22; sleep 1'"
timeout 3 bash -c "exec 3<>/dev/tcp/$TARGET/22; sleep 1" 2>&1 && echo "  conexion mantenida 1 s"
sleep 4
echo "Eventos desde la marca (conexion mantenida):"
journalctl --since "@$T2" --no-pager -o short-precise 2>/dev/null | grep -E 'sshd' | tail -6
E3=$(journalctl --since "@$T2" --no-pager 2>/dev/null | grep -c sshd || true)
echo "  eventos de sshd: $E3"

echo
echo "Resumen de eventos de sshd:"
echo "  nmap -sT ................. $E1"
echo "  nc -z .................... $E2"
echo "  bash abierta 1 segundo ... $E3"

echo
echo "=================================================================="
echo " FIN $(date -Is)"
echo "=================================================================="
