#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 02 (b) - Dos comprobaciones adicionales, dentro de alcance:
#  (a) ¿Se resuelve DNS antes de escanear? coste en tiempo con y sin -n
#  (b) Confirmar con -vv qué probe usa nmap cuando el destino es local
# Objetivo autorizado UNICO: 192.168.56.103
# ==================================================================
set -u

TARGET="192.168.56.103"
OUT="$HOME/evidencias/lab02"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 02 (b)"
echo " Fecha: $(date -Is)"
echo "=================================================================="

echo
echo "--- [A] Configuracion DNS declarada por el sistema (sin consultarla) -"
echo '$ cat /etc/resolv.conf'
cat /etc/resolv.conf 2>/dev/null || echo "(no legible)"

echo
echo "--- [B] Coste del DNS: misma prueba, con y sin resolucion ----------"
echo "\$ time nmap -sn -PE -oA $OUT/pe_con_dns  $TARGET"
START=$(date +%s.%N)
nmap -sn -PE -oA "$OUT/pe_con_dns" "$TARGET" 2>&1
END=$(date +%s.%N)
echo "  -> wall clock con DNS: $(awk -v a="$START" -v b="$END" 'BEGIN{printf "%.2f", b-a}') s"

echo
echo "\$ time nmap -sn -n -PE -oA $OUT/pe_sin_dns $TARGET"
START=$(date +%s.%N)
nmap -sn -n -PE -oA "$OUT/pe_sin_dns" "$TARGET" 2>&1
END=$(date +%s.%N)
echo "  -> wall clock sin DNS: $(awk -v a="$START" -v b="$END" 'BEGIN{printf "%.2f", b-a}') s"

echo
echo "--- [C] Motivo real declarado en cada XML -------------------------"
for f in pe_con_dns pe_sin_dns; do
  echo "  $f:"
  grep -E '<status ' "$OUT/$f.xml" | sed 's/^ *//' | head -1
done

echo
echo "--- [D] -vv: ¿qué probe se emite hacia un destino local? ----------"
echo "\$ nmap -sn -n -PE -vv $TARGET"
nmap -sn -n -PE -vv "$TARGET" 2>&1 | grep -iE 'localhost|probe|sent|reason|ICMP|Respond|parallel' | head -20

echo
echo "--- [E] Mismo -vv con descubrimiento TCP SYN ----------------------"
echo "\$ nmap -sn -n -PS22,80 -vv $TARGET"
nmap -sn -n -PS22,80 -vv "$TARGET" 2>&1 | grep -iE 'localhost|probe|sent|reason|SYN|Respond|parallel' | head -20

echo
echo "=================================================================="
echo " FIN $(date -Is)"
echo "=================================================================="
