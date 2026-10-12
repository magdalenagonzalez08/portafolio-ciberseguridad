#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 05 (b) - Correccion de dos ejecuciones sin resultado
#  (1) banner: se uso una opcion inexistente y el comando no corrio
#  (2) ftp-anon: corrio pero no devolvio texto, hay que saber por que
# Objetivo autorizado UNICO: 192.168.56.103
# ==================================================================
set -u

TARGET="192.168.56.103"
OUT="$HOME/evidencias/lab05"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 05 (b)   $(date -Is)"
echo "=================================================================="

echo
echo "--- [1] banner, sintaxis corregida ---------------------------------"
echo "El error original fue:"
echo "  /usr/lib/nmap/nmap: unrecognized option '--script-args-timeout'"
echo "Esa opcion no existe en nmap 7.99. El tiempo de espera se configura"
echo "con los argumentos del propio script o simplemente no se limita."
echo
echo "\$ nmap --script banner -p 21,22 -oA $OUT/banner $TARGET"
nmap --script banner -p 21,22 -oA "$OUT/banner" "$TARGET" 2>&1

echo
echo "--- [2] ftp-anon, con deteccion de servicio (-sV) -------------------"
echo "Primero se comprueba si el script corre o no aparece en el XML."
echo "\$ nmap --script ftp-anon -p 21 -oA $OUT/ftp_anon_v1 $TARGET"
nmap --script ftp-anon -p 21 -oA "$OUT/ftp_anon_v1" "$TARGET" 2>&1 | tail -8
echo "Elementos <script> en el XML:"
grep -c '<script' "$OUT/ftp_anon_v1.xml" 2>/dev/null || echo "  0 (el script no dejo salida)"
grep -oE '<script[^>]*id="[^"]*"' "$OUT/ftp_anon_v1.xml" 2>/dev/null || echo "  ninguno"

echo
echo "\$ nmap -sV --script ftp-anon -p 21 -oA $OUT/ftp_anon_v2 $TARGET"
nmap -sV --script ftp-anon -p 21 -oA "$OUT/ftp_anon_v2" "$TARGET" 2>&1 | tail -12
echo "Elementos <script> en el XML:"
grep -oE '<script[^>]*id="[^"]*"' "$OUT/ftp_anon_v2.xml" 2>/dev/null || echo "  ninguno"

echo
echo "--- [3] Comprobacion directa del login anonimo con curl --------------"
echo "Prueba independiente para saber si el dato del script es fiable."
echo "\$ curl --max-time 6 --user 'anonymous:anonymous' ftp://$TARGET:21/"
curl --max-time 6 --user 'anonymous:anonymous' "ftp://$TARGET:21/" 2>&1 | head -15
echo "  codigo de salida de curl: ${PIPESTATUS[0]}"

echo
echo "--- [4] Mismo intento con un usuario inexistente (control) -----------"
echo "\$ curl --max-time 6 --user 'noexiste:invalida' ftp://$TARGET:21/"
curl --max-time 6 --user 'noexiste:invalida' "ftp://$TARGET:21/" 2>&1 | head -8
echo "  codigo de salida de curl: ${PIPESTATUS[0]}"

echo
echo "=================================================================="
echo " FIN $(date -Is)"
echo "=================================================================="
