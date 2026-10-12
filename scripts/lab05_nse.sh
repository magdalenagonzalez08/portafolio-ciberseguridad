#!/usr/bin/env bash
# ==================================================================
# LABORATORIO 05 - Enumeracion NSE seleccionada
# Objetivo autorizado UNICO: 192.168.56.103
# Regla aplicada: antes de CADA script se imprime su documentacion
# oficial con --script-help y se anota su categoria. No se ejecutan
# categorias completas ni scripts de fuerza bruta, explotacion o DoS.
# ==================================================================
set -u

TARGET="192.168.56.103"
OUT="$HOME/evidencias/lab05"
mkdir -p "$OUT"

echo "=================================================================="
echo " LABORATORIO 05 - ENUMERACION NSE SELECCIONADA"
echo " Fecha: $(date -Is)"
echo " Objetivo autorizado: $TARGET"
echo " Nmap: $(nmap --version | head -1)"
echo "=================================================================="

doc() {
  echo
  echo "################ DOCUMENTACION OFICIAL DEL SCRIPT ################"
  echo "\$ nmap --script-help $1"
  nmap --script-help "$1" 2>&1 | sed -n '1,60p'
  echo "#################################################################"
}

echo
echo "=========================================================="
echo " 5.1  banner  (categoria: discovery)  -> puertos 21 y 22"
echo "      Objetivo obtener el texto que el propio servicio manda"
echo "      al conectarse, sin interpretarlo."
echo "=========================================================="
doc "banner"
echo
echo "\$ nmap --script banner -p 21,22 --script-args-timeout 5 -oA $OUT/banner $TARGET"
nmap --script banner -p 21,22 --script-args-timeout 5 -oA "$OUT/banner" "$TARGET" 2>&1

echo
echo "=========================================================="
echo " 5.2  ftp-anon  (categorias: default, auth, safe)"
echo "      Comprueba si el servidor acepta login anonimo."
echo "      IMPORTANTE: realiza UN intento de autenticacion con las"
echo "      credenciales bien conocidas anonymous/anonymous. No es"
echo "      fuerza bruta ni prueba ninguna otra combinacion."
echo "=========================================================="
doc "ftp-anon"
echo
echo "\$ nmap --script ftp-anon -p 21 -oA $OUT/ftp_anon $TARGET"
nmap --script ftp-anon -p 21 -oA "$OUT/ftp_anon" "$TARGET" 2>&1

echo
echo "=========================================================="
echo " 5.3  ssh2-enum-algos  (categoria: safe)"
echo "      Lista los algoritmos que el servidor SSH declara en el"
echo "      intercambio de version. Solo lectura de la negociacion."
echo "=========================================================="
doc "ssh2-enum-algos"
echo
echo "\$ nmap --script ssh2-enum-algos -p 22 -oA $OUT/ssh_algos $TARGET"
nmap --script ssh2-enum-algos -p 22 -oA "$OUT/ssh_algos" "$TARGET" 2>&1

echo
echo "=========================================================="
echo " 5.4  ssl-cert  (categoria: safe)"
echo "      Lee el certificado X.509 que el servidor presenta."
echo "      Solo lectura del intercambio TLS, no ataca el cifrado."
echo "=========================================================="
doc "ssl-cert"
echo
echo "\$ nmap --script ssl-cert -p 8443 -oA $OUT/ssl_cert $TARGET"
nmap --script ssl-cert -p 8443 -oA "$OUT/ssl_cert" "$TARGET" 2>&1

echo
echo "=========================================================="
echo " 5.5  http-title, http-headers, http-server-header (categoria: safe)"
echo "      Extraen el titulo de la pagina, sus cabeceras y el"
echo "      identificador del servidor. Peticiones HTTP normales."
echo "=========================================================="
doc "http-title"
echo
echo "\$ nmap --script http-title,http-headers,http-server-header -p 8080 -oA $OUT/http $TARGET"
nmap --script http-title,http-headers,http-server-header -p 8080 -oA "$OUT/http" "$TARGET" 2>&1

echo
echo "=========================================================="
echo " 5.6  Prueba negativa consciente"
echo "      Se invoca un script que NO corresponde al servicio para"
echo "      documentar como se comporta Nmap cuando el script no"
echo "      aplica. Esto no es un fallo, es el resultado esperado."
echo "=========================================================="
echo "\$ nmap --script ssl-cert -p 8080 $TARGET"
nmap --script ssl-cert -p 8080 "$TARGET" 2>&1 | tail -6

echo
echo "=========================================================="
echo " 5.7  Listado de scripts instalados disponibles (para mostrar"
echo "       que la seleccion fue deliberada y no una categoria)"
echo "=========================================================="
echo "\$ ls /usr/share/nmap/scripts | wc -l"
ls /usr/share/nmap/scripts/*.nse 2>/dev/null | wc -l
echo "Scripts ejecutados en este laboratorio: 6 de ellos"

echo
echo "--- Ficheros generados -------------------------------------------"
ls -la "$OUT"

echo
echo "=================================================================="
echo " LABORATORIO 05 - FIN  $(date -Is)"
echo "=================================================================="
