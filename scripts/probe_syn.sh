#!/usr/bin/env bash
# Verificacion rigurosa de si nmap -sS realiza un escaneo SYN real sin privilegios.
set -u

echo "### [1] Capacidades efectivas de la sesion actual"
echo '$ grep Cap /proc/self/status'
grep -E 'Cap(Inh|Prm|Eff|Bnd|Amb)' /proc/self/status
echo "Referencia: CAP_NET_RAW es el bit 13 (valor 0x2000)."
python3 - <<'PYEOF'
import re
line = open('/proc/self/status').read()
m = re.search(r'CapEff:\s*([0-9a-f]+)', line)
eff = int(m.group(1), 16)
print(f"CapEff = 0x{eff:x}")
print("CAP_NET_RAW (bit 13) activo:", bool(eff & (1 << 13)))
print("CAP_NET_ADMIN (bit 12) activo:", bool(eff & (1 << 12)))
PYEOF

echo
echo "### [2] Binario nmap: tipo, permisos, capacidades de archivo"
ls -l /usr/bin/nmap
file /usr/bin/nmap 2>/dev/null || true
echo "--- getcap -v /usr/bin/nmap ---"
getcap -v /usr/bin/nmap 2>&1 || true

echo
echo "### [3] Conteo de paquetes crudos: -sS frente a -sT (misma condicion)"
echo '$ nmap -sS -p 22,21 127.0.0.1 -oG - '
nmap -sS -p 22,21 127.0.0.1 2>&1 | grep -E 'Raw packets|scan type|Nmap done'
nmap -sS -p 22,21 127.0.0.1 -v 2>&1 | grep -E 'Raw packets' || true
echo '$ nmap -sT -p 22,21 127.0.0.1 -v'
nmap -sT -p 22,21 127.0.0.1 -v 2>&1 | grep -E 'Raw packets' || true

echo
echo "### [4] Debug nmap -sS (-d): apertura de socket / motivo de error"
nmap -sS -p 22 -d 127.0.0.1 2>&1 | head -60

echo
echo "### [5] Resumen nmap done -sS"
nmap -sS -p 1-1024 --min-rate 2000 127.0.0.1 2>&1 | tail -6
