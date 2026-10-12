#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 03 (b) - Aislamiento de dos observaciones
#  (a) ¿Por qué -sS dice "filtered/no-response" y -sT "closed/conn-refused"?
#      Comparación controlada: mismas opciones, distinto destino.
#  (b) Verificación observacional en registros del sistema: ¿el escaneo
#      connect deja rastro en sshd y el SYN no?
# Objetivo autorizado UNICO: 192.168.56.103 y 127.0.0.1
# ==================================================================
set -u

TARGET="192.168.56.103"
LOOP="127.0.0.1"
OUT="$HOME/evidencias/lab03"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 03 (b)"
echo " Fecha: $(date -Is)"
echo "=================================================================="

echo
echo "--- [A] Registros disponibles en este equipo -----------------------"
echo '$ ls -la /var/log/ | head -20'
ls -la /var/log/ 2>/dev/null | head -20
echo '$ ls -la /var/log/auth.log /var/log/secure /var/log/syslog 2>&1'
ls -la /var/log/auth.log /var/log/secure /var/log/syslog 2>&1
echo '$ journalctl --no-pager -n 3 2>&1 | head -5'
journalctl --no-pager -n 3 2>&1 | head -5
echo '$ groups'
groups

echo
echo "--- [B] Comparacion controlada: mismas opciones, distinto destino ---"
RANG="-p 1-200"
echo "\$ nmap -sS $RANG --reason $LOOP"
nmap -sS $RANG --reason "$LOOP" 2>&1 | grep -E 'Not shown|Nmap done|PORT'
echo
echo "\$ nmap -sS $RANG --reason $TARGET"
nmap -sS $RANG --reason "$TARGET" 2>&1 | grep -E 'Not shown|Nmap done|PORT'
echo
echo "\$ nmap -sT $RANG --reason $TARGET"
nmap -sT $RANG --reason "$TARGET" 2>&1 | grep -E 'Not shown|Nmap done|PORT'

echo
echo "--- [C] Misma prueba con salida XML para leer los 'extraports' ------"
nmap -sS $RANG --reason -oX "$OUT/cmp_syn_loop.xml" "$LOOP" >/dev/null 2>&1
nmap -sS $RANG --reason -oX "$OUT/cmp_syn_target.xml" "$TARGET" >/dev/null 2>&1
nmap -sT $RANG --reason -oX "$OUT/cmp_ct_target.xml" "$TARGET" >/dev/null 2>&1
for f in cmp_syn_loop cmp_syn_target cmp_ct_target; do
  echo "  $f:"
  grep -oE '<extraports state="[a-z|]+" count="[0-9]+">|<reason qmethod="[a-z-]+">' "$OUT/$f.xml" | sed 's/^/    /'
  grep -oE '<state state="[a-z|]+"' "$OUT/$f.xml" | sort | uniq -c | sed 's/^/    /'
done

echo
echo "--- [D] ¿Se ve el escaneo en los registros de sshd? ----------------"
NLOG=0
if command -v journalctl >/dev/null 2>&1; then
  NLOG=$(journalctl -u ssh --no-pager 2>/dev/null | wc -l)
  echo "  lineas en journalctl -u ssh antes: $NLOG"
else
  echo "  journalctl no disponible"
fi

echo
echo "\$ nmap -sS -p 22 --max-retries 1 $TARGET   (solo SYN)"
nmap -sS -p 22 --max-retries 1 "$TARGET" 2>&1 | grep -E 'Nmap done'
sleep 1
if command -v journalctl >/dev/null 2>&1; then
  N1=$(journalctl -u ssh --no-pager 2>/dev/null | wc -l)
  echo "  lineas tras SYN: $N1  (delta $((N1-NLOG)))"
fi

echo
echo "\$ nmap -sT -p 22 --max-retries 1 $TARGET   (connect real)"
nmap -sT -p 22 --max-retries 1 "$TARGET" 2>&1 | grep -E 'Nmap done'
sleep 1
if command -v journalctl >/dev/null 2>&1; then
  N2=$(journalctl -u ssh --no-pager 2>/dev/null | wc -l)
  echo "  lineas tras connect: $N2  (delta $((N2-N1)))"
  echo '  ---- ultimas 12 lineas del registro de ssh ----'
  journalctl -u ssh --no-pager -n 12 2>/dev/null | sed 's/^/  /'
fi

echo
echo '  ---- tambien con -oN explicito sobre vsftpd (puerto 21) ----'
echo "\$ nmap -sT -p 21 --max-retries 1 $TARGET"
nmap -sT -p 21 --max-retries 1 "$TARGET" 2>&1 | grep -E 'Nmap done'
journalctl -u vsftpd --no-pager -n 6 2>/dev/null | sed 's/^/  /' || echo "  (sin registro de vsftpd legible)"

echo
echo "=================================================================="
echo " FIN $(date -Is)"
echo "=================================================================="
