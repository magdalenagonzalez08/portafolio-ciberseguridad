#!/usr/bin/env bash
# Diagnostico de capturas de pantalla en el laboratorio.
echo "=== sesiones ==="
loginctl list-sessions --no-legend 2>&1
echo
echo "=== sesion de escritorio ==="
loginctl show-session 2 -p Type -p Class -p Display -p Active -p Name 2>&1 || true
echo
echo "=== quien esta conectado ==="
who 2>&1
echo
echo "=== variables de entorno de la sesion grafica ==="
for p in /proc/[0-9]*; do
  if [ -r "$p/environ" ]; then
    tr '\0' '\n' < "$p/environ" 2>/dev/null | grep -E '^(DISPLAY|XAUTHORITY)=' | sed "s|^|${p##*/} |"
  fi
done | head -10
echo
echo "=== herramientas de captura disponibles ==="
for t in gnome-screenshot scrot import maim xwd xfce4-screenshooter xterm konsole; do
  c=$(command -v "$t" 2>/dev/null || echo NO)
  printf '  %-22s %s\n' "$t" "$c"
done
echo
echo "=== escritorio activo ==="
echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-no definido}"
echo "DISPLAY=${DISPLAY:-no definido}"
echo
echo "=== python PIL ==="
python3 -c "import PIL; print('Pillow', PIL.__version__)" 2>&1
echo
echo "=== fuentes monoespaciadas ==="
fc-list 2>/dev/null | grep -iE 'dejavu sans mono|liberation mono' | head -5 || echo "(fc-list no disponible)"
