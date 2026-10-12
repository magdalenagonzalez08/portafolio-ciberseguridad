#!/usr/bin/env bash
# Muestra un extracto de una evidencia dentro de una terminal grafica.
# Uso interno, lo invoca capturar.sh
#   $1 archivo  $2 linea desde  $3 linea hasta  $4 titulo
set -u
SRC="$1"; DESDE="$2"; HASTA="$3"; TITULO="$4"

clear
printf ' %s  |  %s  |  lineas %s-%s\n' "$TITULO" "${SRC#/home/mg/}" "$DESDE" "$HASTA"
printf '==========================================================================\n'
sed -n "${DESDE},${HASTA}p" "$SRC" | sed -r 's/\x1B\[[0-9;]*[mK]//g'
printf '==========================================================================\n'
printf ' Fin del extracto. La evidencia completa esta en el repositorio.\n'

sleep 600
