#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 05 (c) - Comprobar si ftp-anon se ejecuto o no
# nmap no escribio elemento <script> en el XML. Con -d se puede ver
# si el script fue lanzado y que devolvio.
# Objetivo autorizado UNICO: 192.168.56.103
# ==================================================================
set -u
TARGET="192.168.56.103"
OUT="$HOME/evidencias/lab05"

echo "=================================================================="
echo " LABORATORIO 05 (c)   $(date -Is)"
echo "=================================================================="

echo
echo "--- Traza de ejecucion del script con -d ----------------------------"
echo "\$ nmap --script ftp-anon -p 21 -d $TARGET 2>&1 | grep -iE 'ftp-anon|script|launch|Lib' "
nmap --script ftp-anon -p 21 -d "$TARGET" 2>&1 | grep -iE 'ftp-anon|Launching|Script already|libraries|denied' | head -25

echo
echo "--- Salida final del escaneo ---------------------------------------"
nmap --script ftp-anon -p 21 -oN - "$TARGET" 2>&1 | tail -8

echo
echo "--- Confirmacion con un ejemplo positivo controlado ----------------"
echo "Se comprueba que la cadena 'ftp-anon' si aparece en el XML cuando"
echo "el script de verdad deja salida. Para eso se invoca el script"
echo "banner, que si produce texto:"
echo "\$ nmap --script banner -p 21 -oA $OUT/banner_check $TARGET"
nmap --script banner -p 21 -oA "$OUT/banner_check" "$TARGET" >/dev/null 2>&1
echo "  elementos <script> con banner:"
grep -oE '<script[^>]*id="[^"]*"' "$OUT/banner_check.xml" | sed 's/^/    /'
echo "  elementos <script> con ftp-anon:"
grep -oE '<script[^>]*id="[^"]*"' "$OUT/ftp_anon_v1.xml" 2>/dev/null | sed 's/^/    /' || echo "    ninguno"

echo
echo "=================================================================="
echo " FIN $(date -Is)"
echo "=================================================================="
