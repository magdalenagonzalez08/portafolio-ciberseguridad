#!/usr/bin/env bash
# ------------------------------------------------------------------
# Entorno de laboratorio (reversible) para el portafolio de ciberseguridad.
# Objetivo autorizado UNICO: 192.168.56.103 (esta propia maquina Kali)
# y su interfaz de loopback 127.0.0.1.
#
# Este script ANADE servicios de prueba en puertos altos para que los
# laboratorios tengan una superficie real que analizar.
# NO toca sshd, NO toca el firewall, NO toca la red.
#
# Reversibilidad: ejecutar teardown_lab_env.sh
# ------------------------------------------------------------------
set -u

LABDIR="$HOME/labenv"
mkdir -p "$LABDIR"
cd "$LABDIR"

echo "=================================================================="
echo " CONFIGURACION DE ENTORNO DE LABORATORIO"
echo " Fecha local: $(date -Is)  (zona: $(cat /etc/timezone 2>/dev/null || echo desconocida))"
echo " Usuario: $(whoami)  Host: $(hostname)"
echo "=================================================================="

echo
echo "### [E0] Estado BASE (servicios que ya existian: 21/ftp y 22/ssh)"
ss -tlnp 2>/dev/null || ss -tln

echo
echo "### [E1] Servicio HTTP de prueba en 0.0.0.0:8080 (python3 http.server)"
echo '$ nohup setsid python3 -m http.server 8080 --bind 0.0.0.0 > http.log 2>&1 &'
if ss -tln | grep -q ':8080 '; then
  echo "  [ya estaba activo, se reutiliza]"
else
  nohup setsid python3 -m http.server 8080 --bind 0.0.0.0 \
    > "$LABDIR/http.log" 2>&1 < /dev/null &
  sleep 1
fi
ss -tln | grep ':8080 ' && echo "  [OK] 8080 escuchando"

echo
echo "### [E2] Servicio HTTPS de prueba en 0.0.0.0:8443 (openssl s_server, certificado autofirmado)"
if [ ! -f "$LABDIR/lab.crt" ]; then
  echo '$ openssl req -x509 -newkey rsa:2048 -nodes -keyout lab.key -out lab.crt -days 30 -subj ...'
  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$LABDIR/lab.key" -out "$LABDIR/lab.crt" -days 30 \
    -subj "/CN=lab.magalena.local/O=Laboratorio academico local/C=PA" 2>/dev/null
fi
if ss -tln | grep -q ':8443 '; then
  echo "  [ya estaba activo, se reutiliza]"
else
  nohup setsid openssl s_server -accept 8443 -cert "$LABDIR/lab.crt" \
    -key "$LABDIR/lab.key" -www \
    > "$LABDIR/tls.log" 2>&1 < /dev/null &
  sleep 1
fi
ss -tln | grep ':8443 ' && echo "  [OK] 8443 escuchando"

echo
echo "### [E3] Estado FINAL de escucha en todas las interfaces"
ss -tln

echo
echo "### [E4] Verificacion: los servicios nuevos responden por la IP del objetivo autorizado"
echo '$ curl -s -o /dev/null -w "HTTP %{http_code}\n" http://192.168.56.103:8080/'
curl -s -m 5 -o /dev/null -w "HTTP 8080 -> %{http_code}\n" http://192.168.56.103:8080/ || echo "  fallo 8080"
echo '$ curl -sk -o /dev/null -w "HTTP %{http_code}\n" https://192.168.56.103:8443/'
curl -sk -m 5 -o /dev/null -w "HTTP 8443 -> %{http_code}\n" https://192.168.56.103:8443/ || echo "  fallo 8443"

echo
echo "### [E5] Comprobacion de reversibilidad (documentada, ejecutar al terminar)"
echo "Para retirar el entorno: bash teardown_lab_env.sh"
