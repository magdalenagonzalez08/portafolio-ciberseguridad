#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 03 - Puertos TCP y estados
# Objetivo autorizado UNICO: 192.168.56.103   (bucle: 127.0.0.1)
# Comparacion SYN (-sS) frente a TCP connect (-sT), con verificacion
# observacional en los registros del propio equipo.
# ==================================================================
set -u

TARGET="192.168.56.103"
LOOP="127.0.0.1"
OUT="$HOME/evidencias/lab03"
AUTHLOG="/var/log/auth.log"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 03 - PUERTOS TCP Y ESTADOS"
echo " Fecha: $(date -Is)"
echo " Objetivo autorizado: $TARGET"
echo " Nmap: $(nmap --version | head -1)"
echo "=================================================================="

echo
echo "--- [3.1] Por que -sS funciona sin root en este equipo --------------"
echo '$ cat /usr/bin/nmap'
cat /usr/bin/nmap
echo '$ getcap -v /usr/lib/nmap/nmap'
getcap -v /usr/lib/nmap/nmap
echo '$ id'
id
echo
echo "Sesion actual:"
echo '$ grep CapEff /proc/self/status'
grep CapEff /proc/self/status
python3 - <<'PYEOF'
import re
eff = int(re.search(r'CapEff:\s*([0-9a-f]+)', open('/proc/self/status').read()).group(1), 16)
print(f"CapEff = 0x{eff:x}  -> CAP_NET_RAW activo: {bool(eff & (1 << 13))}")
PYEOF

echo
echo "--- [3.2] Prueba de sintesis: paquetes crudos, -sS frente a -sT -----"
echo "\$ nmap -sS -p 22,21 -v $TARGET   (grep 'Raw packets')"
nmap -sS -p 22,21 -v "$TARGET" 2>&1 | grep -E 'Raw packets|Nmap done'
echo "\$ nmap -sT -p 22,21 -v $TARGET   (grep 'Raw packets')"
nmap -sT -p 22,21 -v "$TARGET" 2>&1 | grep -E 'Raw packets|Nmap done'

echo
echo "--- [3.3] Registro de sshd ANTES de los escaneos -------------------"
echo "\$ wc -l $AUTHLOG 2>/dev/null || echo '(no legible)'"
BEFORE=$(wc -l < "$AUTHLOG" 2>/dev/null || echo "nolegible")
echo "  lineas antes: $BEFORE"
echo "\$ tail -5 $AUTHLOG"
tail -5 "$AUTHLOG" 2>/dev/null || echo "  (no legible para este usuario)"

echo
echo "--- [3.4] Escaneo SYN (-sS), todos los puertos ---------------------"
echo "\$ nmap -sS -p- --reason -oA $OUT/syn_full $TARGET"
date +%s > "$OUT/t0"
nmap -sS -p- --reason -oA "$OUT/syn_full" "$TARGET" 2>&1
T_SYN=$(date +%s)

echo
echo "--- [3.5] Escaneo TCP connect (-sT), todos los puertos -------------"
echo "\$ nmap -sT -p- --reason -oA $OUT/connect_full $TARGET"
nmap -sT -p- --reason -oA "$OUT/connect_full" "$TARGET" 2>&1
T_CT=$(date +%s)
echo "  duracion aproximada: SYN=$((T_SYN-$(cat "$OUT/t0"))) s   connect=$((T_CT-T_SYN)) s"

echo
echo "--- [3.6] Registro de sshd DESPUES de ambos escaneos ---------------"
echo "\$ wc -l $AUTHLOG"
AFTER=$(wc -l < "$AUTHLOG" 2>/dev/null || echo "nolegible")
echo "  lineas despues: $AFTER"
if [ "$BEFORE" != "nolegible" ] && [ "$AFTER" != "nolegible" ]; then
  echo "  nuevas lineas: $((AFTER-BEFORE))"
fi
echo "\$ tail -20 $AUTHLOG (recientes)"
tail -20 "$AUTHLOG" 2>/dev/null || echo "  (no legible)"

echo
echo "--- [3.7] Resumen de estados: -sS ----------------------------------"
echo '$ grep Ports <syn_full.nmap> / recuento desde gnmap'
grep -E 'Not shown|^[0-9]+/tcp' "$OUT/syn_full.nmap" | sed 's/^/  /'
echo "Conteo SYN:"
grep -oE '/tcp/[a-z|]+' "$OUT/syn_full.gnmap" | sed 's|/tcp/||' | sort | uniq -c | sed 's/^/  /'

echo
echo "--- [3.8] Resumen de estados: -sT ----------------------------------"
grep -E 'Not shown|^[0-9]+/tcp' "$OUT/connect_full.nmap" | sed 's/^/  /'
echo "Conteo connect:"
grep -oE '/tcp/[a-z|]+' "$OUT/connect_full.gnmap" | sed 's|/tcp/||' | sort | uniq -c | sed 's/^/  /'

echo
echo "--- [3.9] Diferencia entre ambas salidas ---------------------------"
if diff -q "$OUT/syn_full.gnmap" "$OUT/connect_full.gnmap" >/dev/null 2>&1; then
  echo "  Los ficheros .gnmap son IDENTICOS (mismos puertos, mismos estados)."
else
  echo "  Los ficheros .gnmap DIFIEREN:"
  diff "$OUT/syn_full.gnmap" "$OUT/connect_full.gnmap" | sed 's/^/    /' | head -30
fi

echo
echo "--- [3.10] Motivos declarados por nmap (--reason) ------------------"
echo "Motivos distintos de 'reset' (es decir, puertos NO cerrados):"
grep -oE '[0-9]+/tcp open[^|]*' "$OUT/syn_full.nmap" | sed 's/^/  SYN     /'
grep -oE 'reason="[a-z-]+"' "$OUT/syn_full.xml" | sort | uniq -c | sed 's/^/  SYN     /'
grep -oE 'reason="[a-z-]+"' "$OUT/connect_full.xml" | sort | uniq -c | sed 's/^/  connect /'

echo
echo "--- [3.11] Escaneo top 1000 para comparar tiempos -------------------"
echo "\$ time nmap -sS --top-ports 1000 -oA $OUT/syn_top1000 $TARGET"
S=$(date +%s.%N)
nmap -sS --top-ports 1000 -oA "$OUT/syn_top1000" "$TARGET" 2>&1 | tail -4
E=$(date +%s.%N)
echo "  SYN top1000: $(awk -v a="$S" -v b="$E" 'BEGIN{printf "%.2f", b-a}') s"
echo "\$ time nmap -sT --top-ports 1000 -oA $OUT/ct_top1000 $TARGET"
S=$(date +%s.%N)
nmap -sT --top-ports 1000 -oA "$OUT/ct_top1000" "$TARGET" 2>&1 | tail -4
E=$(date +%s.%N)
echo "  connect top1000: $(awk -v a="$S" -v b="$E" 'BEGIN{printf "%.2f", b-a}') s"

echo
echo "--- [3.12] Ficheros generados --------------------------------------"
ls -la "$OUT"

echo
echo "=================================================================="
echo " LABORATORIO 03 - FIN  $(date -Is)"
echo "=================================================================="
