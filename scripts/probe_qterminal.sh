#!/usr/bin/env bash
# Lee la configuracion actual de qterminal para poder reproducirla.
CFG_DIR="$HOME/.config/qterminal.org"
echo "=== directorio ==="
ls -la "$CFG_DIR" 2>/dev/null || echo "(no existe)"
echo
echo "=== qterminal.ini ==="
if [ -f "$CFG_DIR/qterminal.ini" ]; then
  cat "$CFG_DIR/qterminal.ini"
else
  echo "(no existe todavia, qterminal no se ha lanzado nunca)"
fi
