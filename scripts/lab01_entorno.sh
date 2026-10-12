#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 01 - Entorno y alcance
# Objetivo autorizado unico: 192.168.56.103 (esta maquina) y 127.0.0.1
# Este script SOLO consulta el propio equipo. No escanea terceros.
# ==================================================================
set -u

echo "=================================================================="
echo " LABORATORIO 01 - ENTORNO Y ALCANCE"
echo " Comienzo: $(date -Is)"
echo "=================================================================="

echo
echo "--- [1.1] FECHA, HORA Y ZONA HORARIA --------------------------------"
echo '$ date -Is'; date -Is
echo '$ timedatectl show -p Timezone -p NTPSynchronized'; timedatectl show -p Timezone -p NTPSynchronized 2>&1
echo '$ cat /etc/timezone'; cat /etc/timezone 2>&1 || echo "(archivo /etc/timezone no existe)"

echo
echo "--- [1.2] IDENTIDAD Y HOST -----------------------------------------"
echo '$ whoami'; whoami
echo '$ hostname'; hostname
echo '$ id'; id
echo '$ hostnamectl | head -8'; hostnamectl 2>&1 | head -8

echo
echo "--- [1.3] SISTEMA OPERATIVO ----------------------------------------"
echo '$ cat /etc/os-release'; cat /etc/os-release
echo '$ uname -a'; uname -a

echo
echo "--- [1.4] HIPERVISOR (confirmado, NO deducido por la IP) -----------"
echo '$ systemd-detect-virt'; systemd-detect-virt 2>&1
echo '$ lsmod | grep -E "vboxguest|vboxsf"'; lsmod 2>/dev/null | grep -E 'vboxguest|vboxsf' || echo "(sin modulos vbox)"

echo
echo "--- [1.5] INTERFACES DE RED ----------------------------------------"
echo '$ ip -brief addr'; ip -brief addr
echo '$ ip -o -4 addr show'; ip -o -4 addr show
echo '$ ip -o link show  (direcciones MAC para cruzar con el hipervisor)'; ip -o link show
echo '$ ip -brief link'; ip -brief link

echo
echo "--- [1.6] TABLA DE RUTAS -------------------------------------------"
echo '$ ip route'; ip route
echo '$ ip -6 route | head'; ip -6 route 2>/dev/null | head -6
echo '$ ip route get 192.168.56.103'; ip route get 192.168.56.103 2>&1
echo '$ ip route get 127.0.0.1'; ip route get 127.0.0.1 2>&1

echo
echo "--- [1.7] ALCANCE AUTORIZADO ---------------------------------------"
echo "Objetivo autorizado UNICO .......: 192.168.56.103 (eth2, esta maquina)"
echo "Bucle de trabajo ...............: 127.0.0.1 / ::1"
echo "FUERA de alcance (no se prueba) : 192.168.56.1 (anfitrion Windows),"
echo "                                  10.0.2.2 (pasarela NAT),"
echo "                                  192.168.56.0/24 (resto de la subred),"
echo "                                  10.0.2.0/24 y cualquier red externa."
echo "Acciones prohibidas ............: denegacion de servicio, fuerza bruta,"
echo "                                  explotacion, cambios en firewall/red."

echo
echo "--- [1.8] HERRAMIENTAS Y VERSIONES ---------------------------------"
echo '$ nmap --version'; nmap --version
echo '$ cat /usr/bin/nmap  (wrapper de privilegios)'; cat /usr/bin/nmap 2>&1
echo '$ getcap -v /usr/lib/nmap/nmap  (capacidades del binario real)'; getcap -v /usr/lib/nmap/nmap 2>&1
echo '$ python3 --version'; python3 --version
echo '$ curl --version | head -1'; curl --version 2>&1 | head -1
echo '$ openssl version'; openssl version
echo '$ ssh -V'; ssh -V 2>&1
echo '$ dpkg -l nmap vsftpd openssh-server nginx'; dpkg -l 2>/dev/null | grep -E '^ii\s+(nmap|vsftpd|openssh-server|nginx|python3)\s'

echo
echo "--- [1.9] SERVICIOS ESCUCHANDO EN EL EQUIPO ------------------------"
echo '$ ss -tln  (sin -p: ver procesos requiere privilegios)'
ss -tln
echo
echo '$ ps -eo pid,user,comm | grep -E "sshd|vsftpd|python3|openssl|nginx"'
ps -eo pid,user,comm | grep -E 'sshd|vsftpd|python3|openssl|nginx' | grep -v grep || true
echo
echo '$ lsof -nP -iTCP -sTCP:LISTEN  (solo procesos del usuario actual)'
lsof -nP -iTCP -sTCP:LISTEN 2>&1 | head -15 || true
echo "NOTA: lsof sin privilegios no ve los procesos de otros usuarios;"
echo "      por eso vsftpd/sshd se identificaron con ps y con systemctl."
echo '$ systemctl is-active ssh vsftpd'; systemctl is-active ssh vsftpd 2>&1

echo
echo "--- [1.10] COMPROBACIONES DE CONECTIVIDAD (solo dentro del alcance) -"
echo '$ ping -c 3 -W 2 127.0.0.1'
ping -c 3 -W 2 127.0.0.1 2>&1 | tail -3
echo '$ ping -c 3 -W 2 192.168.56.103'
ping -c 3 -W 2 192.168.56.103 2>&1 | tail -4
echo
echo "NO se prueban 192.168.56.1 ni 10.0.2.2 ni ninguna otra direccion:"
echo "no forman parte del alcance autorizado."

echo
echo "--- [1.11] ESTADO DEL ACCESO DE GESTION (SSH) -----------------------"
echo '$ ss -tln | grep ":22 "'
ss -tln | grep ':22 ' || echo "(ssh no escuchando)"
echo '$ sshd: configuracion efectiva activa'
sshd -T 2>/dev/null | grep -E '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication)' || \
  grep -iE '^\s*(Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)' /etc/ssh/sshd_config || \
  echo "(no legible sin privilegios: se documenta como pendiente de validacion)"

echo
echo "=================================================================="
echo " LABORATORIO 01 - FIN"
echo " Fin: $(date -Is)"
echo "=================================================================="
