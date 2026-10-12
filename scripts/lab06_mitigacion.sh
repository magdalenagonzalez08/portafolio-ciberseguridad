#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 06 - Mitigacion y verificacion
# Objetivo autorizado UNICO: 192.168.56.103   (bucle: 127.0.0.1)
#
# EXPOSICION ESCOGIDA
#   El servicio HTTP de prueba estaba enlazado a 0.0.0.0, es decir
#   escuchaba en TODAS las interfaces incluida la de gestion.
#
# MITIGACION APLICADA (reversible y dentro del control del proyecto)
#   Se reinicia el servicio enlazado solo a 127.0.0.1.
#   No se toca sshd, no se toca vsftpd, no se toca el firewall ni la red.
#
# Se comparan pruebas equivalentes antes y despues.
# ==================================================================
set -u

TARGET="192.168.56.103"
LOOP="127.0.0.1"
OUT="$HOME/evidencias/lab06"
LABDIR="$HOME/labenv"
mkdir -p "$OUT"

linea() { echo "------------------------------------------------------------"; }

# Clasifica la salida de un escaneo sobre el puerto 8080.
estado_nmap() {
  if printf '%s' "$1" | grep -q "8080/tcp open"; then echo "open"
  elif printf '%s' "$1" | grep -qi "closed"; then echo "closed"
  elif printf '%s' "$1" | grep -qi "filtered"; then echo "filtered"
  else echo "sin dato"; fi
}

# Devuelve un texto legible a partir del codigo http de curl.
# 000 significa que no hubo respuesta HTTP.
http_resultado() {
  if [ "$1" = "000" ] || [ -z "$1" ]; then echo "rechazado"
  else echo "HTTP $1"; fi
}

echo "=================================================================="
echo " LABORATORIO 06 - MITIGACION Y VERIFICACION"
echo " Fecha: $(date -Is)"
echo " Objetivo autorizado: $TARGET"
echo "=================================================================="

# ------------------------------------------------------------------
# ANTES
# ------------------------------------------------------------------
echo
echo "################# ESTADO ANTES DE LA MITIGACION #################"
linea
echo "[A1] Interfaces en escucha del puerto 8080"
echo '$ ss -tln | grep 8080'
ss -tln | grep 8080
IF_ANTES=$(ss -tln | grep 8080 | awk '{print $4}' | tr '\n' ' ')

echo
echo "[A2] Escaneo SYN sobre la IP del objetivo autorizado"
echo "\$ nmap -sS -p 8080 --reason $TARGET"
SS_ANTES=$(nmap -sS -p 8080 --reason -oA "$OUT/antes_syn" "$TARGET" 2>&1)
printf '%s\n' "$SS_ANTES" | grep -E 'PORT|8080|Not shown|Nmap done'
ST_ANTES=$(estado_nmap "$SS_ANTES")

echo
echo "[A3] Escaneo TCP connect sobre la IP del objetivo autorizado"
echo "\$ nmap -sT -p 8080 --reason $TARGET"
CT_OUT_ANTES=$(nmap -sT -p 8080 --reason -oA "$OUT/antes_ct" "$TARGET" 2>&1)
printf '%s\n' "$CT_OUT_ANTES" | grep -E 'PORT|8080|Not shown|Nmap done'
CT_ANTES=$(estado_nmap "$CT_OUT_ANTES")

echo
echo "[A4] Peticion HTTP por la IP del objetivo autorizado"
echo "\$ curl -s -o /dev/null -w 'HTTP %{http_code}' --max-time 5 http://$TARGET:8080/"
C_ANTES=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$TARGET:8080/" 2>/dev/null)
CURL_ANTES=$(http_resultado "$C_ANTES")
echo "  ${CURL_ANTES}"

echo
echo "[A5] Peticion HTTP por el bucle de trabajo"
echo "\$ curl -s -o /dev/null -w 'HTTP %{http_code}' --max-time 5 http://$LOOP:8080/"
CL_ANTES=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$LOOP:8080/" 2>/dev/null)
CURLL_ANTES=$(http_resultado "$CL_ANTES")
echo "  ${CURLL_ANTES}"

echo
echo "[A6] Servicios que NO deben cambiar"
echo '$ ss -tln | grep -E ":21 |:22 |:8443 "'
ss -tln | grep -E ':21 |:22 |:8443 '
if ss -tln | grep -q ':22 '; then SSH_ANTES="activo"; else SSH_ANTES="NO aparece"; fi

# ------------------------------------------------------------------
# MITIGACION
# ------------------------------------------------------------------
echo
echo "################# APLICACION DE LA MITIGACION ###################"
linea
echo "Accion: reiniciar el servicio HTTP enlazado SOLO a 127.0.0.1"
echo "Justificacion: el servicio es una utilidad local de pruebas y no"
echo "necesita ser visible en la interfaz de gestion ni en la NAT."
echo
echo '$ pkill -f "http.server 8080"'
pkill -f "http.server 8080" 2>/dev/null && echo "  servicio anterior detenido" || echo "  el servicio no estaba activo"
sleep 1

echo '$ nohup setsid python3 -m http.server 8080 --bind 127.0.0.1 > ~/labenv/http.log 2>&1 &'
nohup setsid python3 -m http.server 8080 --bind 127.0.0.1 \
  > "$LABDIR/http.log" 2>&1 < /dev/null &
sleep 1
echo '$ ss -tln | grep 8080'
ss -tln | grep 8080

# ------------------------------------------------------------------
# DESPUES
# ------------------------------------------------------------------
echo
echo "################# ESTADO DESPUES DE LA MITIGACION ###############"
linea
echo "[D1] Interfaces en escucha del puerto 8080"
echo '$ ss -tln | grep 8080'
ss -tln | grep 8080
IF_DESPUES=$(ss -tln | grep 8080 | awk '{print $4}' | tr '\n' ' ')
[ -z "$IF_DESPUES" ] && IF_DESPUES="ninguna"

echo
echo "[D2] Escaneo SYN sobre la IP del objetivo autorizado"
echo "\$ nmap -sS -p 8080 --reason $TARGET"
SS_DESPUES=$(nmap -sS -p 8080 --reason -oA "$OUT/despues_syn" "$TARGET" 2>&1)
printf '%s\n' "$SS_DESPUES" | grep -E 'PORT|8080|Not shown|Nmap done'
ST_DESPUES=$(estado_nmap "$SS_DESPUES")

echo
echo "[D3] Escaneo TCP connect sobre la IP del objetivo autorizado"
echo "\$ nmap -sT -p 8080 --reason $TARGET"
CT_OUT_DESPUES=$(nmap -sT -p 8080 --reason -oA "$OUT/despues_ct" "$TARGET" 2>&1)
printf '%s\n' "$CT_OUT_DESPUES" | grep -E 'PORT|8080|Not shown|Nmap done'
CT_DESPUES=$(estado_nmap "$CT_OUT_DESPUES")

echo
echo "[D4] Peticion HTTP por la IP del objetivo autorizado (debe fallar)"
echo "\$ curl -s -o /dev/null -w 'HTTP %{http_code}' --max-time 5 http://$TARGET:8080/"
C_DESPUES=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$TARGET:8080/" 2>/dev/null)
CURL_DESPUES=$(http_resultado "$C_DESPUES")
echo "  ${CURL_DESPUES}"

echo
echo "[D5] Peticion HTTP por el bucle de trabajo (debe seguir funcionando)"
echo "\$ curl -s -o /dev/null -w 'HTTP %{http_code}' --max-time 5 http://$LOOP:8080/"
CL_DESPUES=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$LOOP:8080/" 2>/dev/null)
CURLL_DESPUES=$(http_resultado "$CL_DESPUES")
echo "  ${CURLL_DESPUES}"

echo
echo "[D6] El servicio de gestion SSH no se ha visto afectado"
echo '$ ss -tln | grep ":22 "'
ss -tln | grep ':22 '
if ss -tln | grep -q ':22 '; then SSH_DESPUES="activo"; else SSH_DESPUES="NO aparece"; fi

echo
echo "[D7] Comprobacion de que la ruta sigue siendo local"
echo '$ ip route get 192.168.56.103'
ip route get "$TARGET"

# ------------------------------------------------------------------
# RESUMEN
# ------------------------------------------------------------------
echo
echo "################# CUADRO COMPARATIVO ############################"
linea
echo "Tabla generada a partir de las pruebas A y D de esta misma ejecucion,"
echo "no de valores escritos a mano."

printf "  %-44s | %-12s | %-12s\n" "PRUEBA" "ANTES" "DESPUES"
printf "  %-44s | %-12s | %-12s\n" "--------------------------------------------" "------------" "------------"
printf "  %-44s | %-12s | %-12s\n" "ss -tln, interfaz de escucha 8080" "$IF_ANTES" "$IF_DESPUES"
printf "  %-44s | %-12s | %-12s\n" "nmap -sS 8080 sobre $TARGET" "$ST_ANTES" "$ST_DESPUES"
printf "  %-44s | %-12s | %-12s\n" "nmap -sT 8080 sobre $TARGET" "$CT_ANTES" "$CT_DESPUES"
printf "  %-44s | %-12s | %-12s\n" "curl http://$TARGET:8080" "$CURL_ANTES" "$CURL_DESPUES"
printf "  %-44s | %-12s | %-12s\n" "curl http://$LOOP:8080" "$CURLL_ANTES" "$CURLL_DESPUES"
printf "  %-44s | %-12s | %-12s\n" "sshd en el puerto 22" "$SSH_ANTES" "$SSH_DESPUES"

# ------------------------------------------------------------------
# PROPUESTA NO EJECUTADA
# ------------------------------------------------------------------
echo
echo "################# PROPUESTA NO EJECUTADA #########################"
linea
echo "Las siguientes medidas NO se han aplicado en este laboratorio."
echo "Se dejan escritas con su procedimiento de verificacion para que"
echo "puedan ejecutarse cuando haya autorizacion y acceso con privilegios."
echo
echo "P-1  Endurecer el acceso SSH"
echo "     Motivo observable, se ha comprobado que el servidor acepta"
echo "     password y publickey:"
echo "       mg@192.168.56.103: Permission denied (publickey,password)"
echo "     Propuesta, requiere sudo y modifica sshd:"
echo "       sudoedit /etc/ssh/sshd_config      # PasswordAuthentication no"
echo "       sudo sshd -t                        # validar sintaxis"
echo "       sudo systemctl reload ssh"
echo "     Verificacion equivalente y no destructiva:"
echo "       ssh -o PreferredAuthentications=password -o BatchMode=yes mg@192.168.56.103 exit"
echo "       (antes acepta password, despues debe decir 'Permission denied (publickey)')"
echo "     ESTADO: NO EJECUTADO. Requiere autorizacion explicita porque"
echo "     un error de configuracion dejaria fuera el acceso de gestion."
echo
echo "P-2  Revisar la configuracion efectiva de sshd"
echo "     Motivo, en el Laboratorio 01 no se pudo leer:"
echo "       sudo sshd -T   -> sudo: a password is required"
echo "     Procedimiento pendiente, solo lectura:"
echo "       sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication'"
echo "     ESTADO: NO EJECUTADO. Es una comprobacion de solo lectura."
echo
echo "P-3  Confirmar el estado del login anonimo en FTP"
echo "     Se observo con una prueba unica:"
echo "       curl --user anonymous:anonymous ftp://$TARGET:21/  ->  530 Access denied"
echo "     El script ftp-anon no dejo salida en el XML, por lo que no se"
echo "     uso como fuente. Verificacion propuesta:"
echo "       sudo grep -E '^\s*anonymous_enable' /etc/vsftpd.conf"
echo "     ESTADO: NO EJECUTADO. Solo lectura, requiere privilegios."

echo
echo "################# REVERSIBILIDAD #################################"
linea
echo "Esta mitigacion se revierte con:"
echo "  pkill -f 'http.server 8080'"
echo "  nohup setsid python3 -m http.server 8080 --bind 0.0.0.0 > ~/labenv/http.log 2>&1 &"
echo "O directamente retirando todo el entorno de pruebas:"
echo "  bash ~/labenv/scripts/teardown_lab_env.sh"

echo
echo "=================================================================="
echo " LABORATORIO 06 - FIN  $(date -Is)"
echo "=================================================================="
