# Portafolio de laboratorios de ciberseguridad

Magdalena Sarit González Bustillo · Licenciatura en Ciberseguridad

Seis laboratorios ejecutados sobre una máquina virtual propia, con evidencias descargadas, capturas de pantalla y una metodología de trabajo declarada. Cada informe separa lo verificado de lo pendiente.

## 1. Problema y objetivo

Un laboratorio de seguridad informática que no deja rastro verificable no sirve como evidencia de competencias. Este portafolio resuelve ese problema con seis prácticas encadenadas, desde la línea base del entorno hasta la mitigación de un servicio expuesto, y con un formato de informe idéntico en las seis.

El objetivo declarado es practicar reconocimiento, enumeración y reducción de superficie de exposición sobre un entorno controlado, y dejar de ello un rastro que cualquier revisor pueda seguir.

## 2. Alcance, autorización y arquitectura

- Máquina virtual Kali Linux 2026.3 dentro de Oracle VirtualBox.
- Único objetivo autorizado, la dirección `192.168.56.103`, que es la propia máquina virtual que ejecuta el escáner.
- Fuera de alcance, la puerta de enlace del host, las redes del hipervisor y cualquier dirección externa.
- No se realizan fuerza bruta, explotación ni denegación de servicio.
- Las credenciales de acceso a la máquina virtual no aparecen en ningún archivo de este repositorio.

## 3. Prerrequisitos y datos de prueba

- VirtualBox instalado en el hipervisor.
- Imagen de Kali Linux con acceso SSH habilitado.
- Nmap `7.99` con los scripts NSE incluidos.
- Cliente SSH con clave de acceso dedicada al laboratorio.
- Servicios de prueba preinstalados en la máquina virtual, servidor HTTP de Python, servidor FTP `vsftpd`, servidor TLS autofirmado y servidor SSH del propio sistema.

## 4. Método y decisiones técnicas

Cada informe sigue la misma estructura de catorce secciones, con un marco de ocho piezas, problema, alcance y entorno, objetivo, método, evidencia, resultado, mitigación y límites.

Las decisiones técnicas recurrentes son estas.

- Escaneo SYN y escaneo de connect usados en paralelo cuando el estado de un puerto es ambiguo.
- Opción `--reason` siempre activa, para poder citar el motivo de cada clasificación.
- Salidas `-oA` guardadas en disco y descargadas al repositorio.
- Controles positivos montados cuando un resultado vacío podría confundirse con un fallo de la herramienta.
- Toda mitigación documentada con su reversibilidad.
- Toda propuesta que requiere privilegios superiores se deja escrita con su código, en lugar de ejecutarse sin autorización.

## 5. Evidencias relevantes

- `evidencias/` contiene los typescripts y las salidas de Nmap de los seis laboratorios.
- `evidencias/capturas/` contiene veinte capturas de pantalla de las sesiones gráficas.
- Cada informe HTML incrusta sus capturas con narrativa, no como archivos sueltos.
- Los archivos en PDF ofrecen la misma información en formato imprimible.

## 6. Resultado y validación

Los seis laboratorios están en estado completado. Los resultados principales son estos.

- Laboratorio 01, tres interfaces de red identificadas y alcance declarado.
- Laboratorio 02, mecanismos de descubrimiento comparados por tiempo de respuesta.
- Laboratorio 03, más de sesenta y cinco mil puertos clasificados en filtered y closed con el motivo documentado.
- Laboratorio 04, versiones de los cuatro servicios identificadas, con un puerto que devuelve datos pero no es reconocido.
- Laboratorio 05, cuatro scripts NSE ejecutados, con la comprobación de que un script sin salida no significa un script que no se ejecutó.
- Laboratorio 06, servidor HTTP delimitado a loopback con comparación antes y después y reversibilidad documentada.

La validación se apoya en dos pilares, las salidas `-oA` guardadas en disco y las capturas de pantalla que muestran la misma información en el entorno gráfico.

## 7. Mitigación o mejora

La mitigación principal del portafolio es la del Laboratorio 06, limitar el servidor HTTP de prueba a la interfaz de loopback. El efecto medido es que el puerto pasa de abierto a filtered y closed desde la red, mientras el uso local se conserva.

Quedan documentadas como pendientes tres propuestas que requieren privilegios de root no autorizados en este laboratorio, revisión de la configuración de autenticación del servidor SSH, volcado de la configuración efectiva del demonio y lectura de la configuración del servidor FTP.

## 8. Limitaciones y próximos pasos

- Las mediciones son de un único instante y no describen el comportamiento bajo carga.
- No se aplicó control a nivel de cortafuegos, la mitigación del Laboratorio 06 depende de la aplicación.
- No se ejecutaron scripts de categorías ofensivas.
- Las propuestas P-1 a P-3 quedan sin ejecutar por falta de autorización.

Los próximos pasos previstos son profundizar en la revisión de configuración de los servicios de red una vez obtenidos los privilegios adecuados, y ampliar el portafolio con prácticas de análisis de registros y de respuesta a incidentes.

## 9. Fuentes y referencias

- Documentación oficial de Nmap. <https://nmap.org/book/>
- Documentación de scripts NSE. <https://nmap.org/nsedoc/>
- Documentación de Python. <https://docs.python.org/3/library/http.server.html>
- Documentación de OpenSSH. <https://www.openssh.com/man.html>
- Documentación de `vsftpd`. <https://security.appspot.com/vsftpd.html>
- Documentación de `curl`. <https://curl.se/docs/manpage.html>
- Documentos RFC del editor de RFC. <https://www.rfc-editor.org/>

## Estructura del repositorio

```
.
├── index.html
├── README.md
├── .gitignore
├── css/
├── js/
├── laboratorios/
│   ├── lab-01.html
│   ├── lab-02.html
│   ├── lab-03.html
│   ├── lab-04.html
│   ├── lab-05.html
│   └── lab-06.html
├── evidencias/
│   ├── capturas/
│   ├── lab01/
│   ├── lab02/
│   ├── lab03/
│   ├── lab04/
│   ├── lab05/
│   └── lab06/
├── pdf/
├── scripts/
└── privado/
```

## Contacto

Correo electrónico. <mailto:magdalenagonzalezcorreo@gmail.com>

LinkedIn de Magdalena Sarit González Bustillo. <https://www.linkedin.com/in/magdalenagonzalezpanama/?locale=es>
