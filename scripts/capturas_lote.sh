#!/usr/bin/env bash
# ==================================================================
# Lote de capturas de pantalla para todo el portafolio.
# Cada captura abre la terminal grafica de la sesion local de Kali,
# pinta un extracto de una evidencia y fotografia la ventana.
# No se envia ningun paquete de red.
# ==================================================================
set -u

EV="$HOME/evidencias"
CAP="$EV/capturas"
SH="$HOME/labenv/scripts/capturar.sh"
mkdir -p "$CAP"

#  nombre                        archivo                              desde hasta
EJECUTAR() {
  local nombre="$1" archivo="$2" desde="$3" hasta="$4" titulo="$5"
  echo
  echo "---------------------------------------------------------------"
  bash "$SH" "$CAP/$nombre.png" "$EV/$archivo" "$desde" "$hasta" "$titulo"
}

# ---------------- Laboratorio 01 ----------------
EJECUTAR lab01-interfaces  lab01/e01_entorno_y_alcance.typescript 57 90  "LAB 01 - Interfaces de red y rutas"
EJECUTAR lab01-alcance     lab01/e01_entorno_y_alcance.typescript 95 128 "LAB 01 - Alcance autorizado y herramientas"
EJECUTAR lab01-servicios   lab01/e01_entorno_y_alcance.typescript 139 172 "LAB 01 - Servicios escuchando y conectividad"

# ---------------- Laboratorio 02 ----------------
EJECUTAR lab02-mecanismos  lab02/e02_descubrimiento.typescript 37 70  "LAB 02 - Descubrimiento ICMP, TCP y UDP"
EJECUTAR lab02-motivos     lab02/e02b_motivos_xml.typescript   1 34   "LAB 02 - Motivo declarado en el XML"
EJECUTAR lab02-dns         lab02/e02c_dns_y_probe.typescript   8 41   "LAB 02 - Coste DNS y verificacion con -vv"

# ---------------- Laboratorio 03 ----------------
EJECUTAR lab03-capacidades lab03/e03_puertos_tcp.typescript    9 37   "LAB 03 - Por que -sS funciona sin root"
EJECUTAR lab03-barrido     lab03/e03_puertos_tcp.typescript    45 72  "LAB 03 - Barrido de los 65535 puertos"
EJECUTAR lab03-aislamiento lab03/e03b_aislamiento.typescript   40 73  "LAB 03 - Comparacion controlada"
EJECUTAR lab03-registro    lab03/e03d_captura_y_log.typescript 30 51  "LAB 03 - Eventos de sshd por metodo"

# ---------------- Laboratorio 04 ----------------
EJECUTAR lab04-banners     lab04/e04_servicios_so.typescript   10 43  "LAB 04 - Respuestas observadas de cada servicio"
EJECUTAR lab04-versiones   lab04/e04_servicios_so.typescript   45 78  "LAB 04 - Identificacion de servicios con -sV"
EJECUTAR lab04-so          lab04/e04_servicios_so.typescript   121 154 "LAB 04 - Deteccion de sistema operativo"

# ---------------- Laboratorio 05 ----------------
EJECUTAR lab05-ssh         lab05/e05_nse.typescript            87 120 "LAB 05 - Algoritmos SSH declarados"
EJECUTAR lab05-cert        lab05/e05_nse.typescript            205 224 "LAB 05 - Certificado TLS con ssl-cert"
EJECUTAR lab05-http        lab05/e05_nse.typescript            225 258 "LAB 05 - Cabeceras HTTP con NSE"
EJECUTAR lab05-ftpanon     lab05/e05c_ejecucion_script.typescript 1 34 "LAB 05 - Ejecucion verificada de ftp-anon"

# ---------------- Laboratorio 06 ----------------
EJECUTAR lab06-antes       lab06/e06_mitigacion.typescript     8 41   "LAB 06 - Estado antes de la mitigacion"
EJECUTAR lab06-despues     lab06/e06_mitigacion.typescript     53 86  "LAB 06 - Estado despues de la mitigacion"
EJECUTAR lab06-comparativa lab06/e06_mitigacion.typescript     89 122 "LAB 06 - Cuadro comparativo generado"

echo
echo "==============================================================="
echo " Capturas generadas"
ls -l "$CAP" | tail -n +2
echo "==============================================================="
