#!/bin/sh

# ============================================================================
# Entrypoint para pYSFReflector3 en Docker
#
# Autor: Jules (Asistente de IA)
#
# Este script genera dinámicamente el fichero de configuración
# 'pysfreflector.ini' a partir de variables de entorno y luego
# ejecuta la aplicación principal del reflector.
# ============================================================================

set -e

# --- Ruta del Fichero de Configuración ---
CONFIG_FILE="/opt/pysfreflector/pysfreflector.ini"

# --- Generación del Fichero de Configuración ---
# Se utiliza 'cat << EOF' (heredoc) para escribir el contenido.
# La sintaxis '${VAR:-default}' permite usar el valor de una variable de
# entorno (VAR) o, si no está definida, usar un valor por defecto.

echo "Generando el fichero de configuración en ${CONFIG_FILE}..."

cat << EOF > ${CONFIG_FILE}
[General]
Daemon=0

[Info]
Name=${INFO_NAME:-YSF Reflector by Docker}
Description=${INFO_DESCRIPTION:-Dockerized pYSFReflector}
Contact=${INFO_CONTACT:-}
Web=${INFO_WEB:-}

[Log]
# Para Docker, los logs se envían a la salida estándar para ser gestionados con 'docker logs'.
DisplayLevel=${LOG_DISPLAY_LEVEL:-1}
FileLevel=${LOG_FILE_LEVEL:-0}
FilePath=/dev/stdout
FileRoot=YSFReflector
FileRotate=0

[Network]
# El IP se fija en 0.0.0.0 para escuchar en todas las interfaces dentro del contenedor.
IP=0.0.0.0
Port=${NETWORK_PORT:-42000}
Json_IP=${NETWORK_JSON_IP:-127.0.0.1}
Json_Port=${NETWORK_JSON_PORT:-42001}
Debug=${NETWORK_DEBUG:-0}

[Block List]
# deny.db se gestiona con un volumen desde docker-compose.
File=/opt/pysfreflector/deny.db
Time=${BLOCKLIST_TIME:-0.5}
CheckRE=${BLOCKLIST_CHECK_RE:-1}

[Protections]
Timeout=${PROTECTIONS_TIMEOUT:-190}
WildPTTTime=${PROTECTIONS_WILD_PTT_TIME:-5}
WildPTTCount=${PROTECTIONS_WILD_PTT_COUNT:-4}
Treactivate=${PROTECTIONS_TREACTIVATE:-900}

[APRS]
enable=${APRS_ENABLE:-0}
server=${APRS_SERVER:-aprs.grupporadiofirenze.net}
port=${APRS_PORT:-14580}
ssid=${APRS_SSID:--10}

[DGID]
list=${DGID_LIST:-1,9,50}
default=${DGID_DEFAULT:-50}
local=${DGID_LOCAL:-1}
database=/opt/pysfreflector/dgid.json
home=/opt/pysfreflector/home.db
aux_port=${DGID_AUX_PORT:-}
prefix=${DGID_PREFIX:-1}
bth_time=${DGID_BTH_TIME:-900.0}

[REFL_ALIAS]
refl_01=${REFL_ALIAS_01:-}

EOF

echo "Configuración generada con éxito."

# --- Ejecución de la Aplicación ---
# 'exec "$@"' ejecuta el comando que se le pasa como argumento al script.
# En el Dockerfile, esto será el CMD ["python3", "/opt/pysfreflector/YSFReflector"].
# 'exec' reemplaza el proceso actual, lo que es una buena práctica en contenedores.
echo "Iniciando YSFReflector..."
exec "$@"
