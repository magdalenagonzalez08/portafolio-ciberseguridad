#!/usr/bin/env bash
# ==================================================================
# Captura de pantalla real de una evidencia.
# Abre una terminal grafica en la sesion local de Kali con un
# extracto de la transcripcion y fotografía esa ventana.
#
# Uso:
#   capturar.sh <salida.png> <archivo> <desde> <hasta> <titulo>
# ==================================================================
set -u

SALIDA="$1"
ARCHIVO="$2"
DESDE="$3"
HASTA="$4"
TITULO="$5"

export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

CFG="$HOME/.config/qterminal.org/qterminal.ini"
CFG_BAK="$CFG.captura_bak"

if [ ! -f "$ARCHIVO" ]; then
  echo "ERROR no existe el archivo $ARCHIVO"
  exit 1
fi

echo "=== Captura ==="
echo "  archivo  $ARCHIVO"
echo "  rango    $DESDE..$HASTA"
echo "  salida   $SALIDA"
echo "  titulo   $TITULO"

# Fuente legible solo durante la captura
if [ -f "$CFG" ]; then
  cp "$CFG" "$CFG_BAK"
  sed -i 's/^fontSize=.*/fontSize=14/' "$CFG"
fi

qterminal -e "bash $HOME/labenv/scripts/_mostrar.sh $ARCHIVO $DESDE $HASTA '$TITULO'" \
  >/dev/null 2>&1 &
TERMPID=$!

sleep 7

# Elegir la ventana de terminal mas ancha, nunca una ayuda de 1x1
WINID=""
for id in $(xwininfo -root -tree 2>/dev/null \
             | grep -E '^ *0x[0-9a-f]+ "' \
             | grep -iE 'shell no|qterminal|terminal' \
             | awk '{print $1}'); do
  ancho=$(xwininfo -id "$id" 2>/dev/null \
          | sed -n 's/.*-geometry \([0-9]\+\)x.*/\1/p' | head -1)
  if [ -n "$ancho" ] && [ "$ancho" -gt 600 ]; then
    WINID="$id"
    break
  fi
done
echo "  ventana  ${WINID:-no encontrada}"

if [ -n "$WINID" ]; then
  timeout 30 import -window "$WINID" "$SALIDA" 2>/dev/null \
    || timeout 30 import -window root "$SALIDA" 2>&1
else
  timeout 30 import -window root "$SALIDA" 2>&1
fi

kill "$TERMPID" 2>/dev/null
sleep 2
pkill -f '_mostrar.sh' 2>/dev/null
sleep 1

# Restaurar la configuracion original
if [ -f "$CFG_BAK" ]; then
  mv "$CFG_BAK" "$CFG"
fi

if [ -f "$SALIDA" ]; then
  echo "  ok $(ls -l "$SALIDA" | awk '{print $5}') bytes"
else
  echo "  ERROR no se creo la captura"
  exit 1
fi
