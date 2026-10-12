#!/usr/bin/env bash
# Sonda de capacidades: determina si nmap -sS / -O pueden ejecutarse sin privilegios.
set -u

echo "### [1] Identidad y grupos"
id

echo
echo "### [2] Capacidades de archivo en /usr/bin/nmap"
if command -v getcap >/dev/null 2>&1; then
  echo "\$ getcap -v /usr/bin/nmap"
  getcap -v /usr/bin/nmap 2>&1 || true
  echo "(sin salida = sin capacidades de archivo asignadas)"
else
  echo "getcap no instalado"
fi

echo
echo "### [3] Test directo de socket raw desde Python"
echo '$ python3 -c ... SOCK_RAW ...'
python3 - <<'PYEOF' 2>&1
import socket
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP)
    print("RAW SOCKET: OK (el usuario puede abrir sockets crudos)")
    s.close()
except PermissionError as e:
    print("RAW SOCKET: DENEGADO ->", e)
PYEOF

echo
echo "### [4] Test de socket AF_PACKET"
python3 - <<'PYEOF' 2>&1
import socket
try:
    s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
    print("AF_PACKET: OK")
    s.close()
except (PermissionError, OSError) as e:
    print("AF_PACKET: DENEGADO ->", e)
PYEOF

echo
echo "### [5] Ejecucion nmap -sS (SYN) hacia el objetivo autorizado 127.0.0.1"
echo '$ nmap -sS -p 22,21 127.0.0.1'
nmap -sS -p 22,21 127.0.0.1 2>&1

echo
echo "### [6] Ejecucion nmap -sT (connect) mismo objetivo"
echo '$ nmap -sT -p 22,21 127.0.0.1'
nmap -sT -p 22,21 127.0.0.1 2>&1
