#!/usr/bin/env bash
# ------------------------------------------------------------------
# Revierte setup_lab_env.sh: detiene unicamente los servicios de prueba
# que ESTE PROYECTO lanzo en los puertos 8080 y 8443.
# No toca sshd ni vsftpd (servicios preexistentes del sistema).
# ------------------------------------------------------------------
set -u

LABDIR="$HOME/labenv"
echo "Fecha local: $(date -Is)"

echo
echo "### Deteniendo servicio HTTP de prueba (8080)"
pkill -f "http.server 8080" 2>/dev/null && echo "  detenido" || echo "  no estaba activo"

echo
echo "### Deteniendo servicio HTTPS de prueba (8443)"
pkill -f "s_server -accept 8443" 2>/dev/null && echo "  detenido" || echo "  no estaba activo"

sleep 1

echo
echo "### Estado de escucha tras la reversión"
ss -tln

echo
echo "### Servicios preexistentes que NO deben verse afectados"
ss -tln | grep -E ':21 |:22 ' && echo "  [OK] ftp(21) y ssh(22) siguen activos"

echo
echo "### Verificación de que SSH sigue accesible (gestión)"
ss -tln | grep -q ':22 ' && echo "  [OK] sshd en 22 sigue escuchando" || echo "  [ALERTA] sshd no aparece"
