#!/bin/bash

# ============================================================================
# Script de Instalación para pYSFReflector3
#
# Autor: Jules (Asistente de IA)
# Versión: 1.0
#
# Este script instala pYSFReflector3 de iu5jae, incluyendo sus
# dependencias y la configuración opcional de un dashboard web.
# ============================================================================

# --- Variables de Color ---
COLOR_ROJO='\033[0;31m'
COLOR_VERDE='\033[0;32m'
COLOR_AMARILLO='\033[1;33m'
COLOR_NC='\033[0m' # Sin Color

# --- Funciones de Utilidad ---
info() {
    echo -e "${COLOR_VERDE}[INFO] $1${COLOR_NC}"
}

warn() {
    echo -e "${COLOR_AMARILLO}[AVISO] $1${COLOR_NC}"
}

error() {
    echo -e "${COLOR_ROJO}[ERROR] $1${COLOR_NC}"
    exit 1
}

# --- Verificación de Root ---
if [ "$(id -u)" -ne 0 ]; then
    error "Este script debe ejecutarse como root. Por favor, utiliza 'sudo ./install_pysfreflector.sh'"
fi

# --- Mensaje de Bienvenida ---
echo "======================================================"
echo "Bienvenido al instalador de pYSFReflector3"
echo "======================================================"
echo
info "Este script te guiará a través de la instalación."

# --- Preguntar sobre el Dashboard ---
INSTALL_DASHBOARD="n"
read -p "$(echo -e ${COLOR_AMARILLO}'¿Deseas instalar también el dashboard web (Apache2, PHP, SQLite3)? [s/N]: '${COLOR_NC})" choice
case "$choice" in
  s|S|si|SI ) INSTALL_DASHBOARD="s";;
  * ) INSTALL_DASHBOARD="n";;
esac

if [ "$INSTALL_DASHBOARD" == "s" ]; then
    info "Se instalará el reflector principal y el dashboard web."
else
    info "Se instalará únicamente el reflector principal."
fi
echo

# --- Preparación del Sistema ---
info "Actualizando la lista de paquetes del sistema (apt update)..."
apt-get update
if [ $? -ne 0 ]; then
    error "Falló la actualización de la lista de paquetes. Verifica tu conexión a internet y los repositorios."
fi

info "Instalando 'git' para poder descargar el software..."
apt-get install -y git
if [ $? -ne 0 ]; then
    error "No se pudo instalar 'git'. El script no puede continuar."
fi

echo
info "La preparación del sistema ha finalizado."
echo

# --- Instalación del Reflector ---
info "Instalando dependencias de Python: python3, python3-pip y python3-venv..."
apt-get install -y python3 python3-pip python3-venv
if [ $? -ne 0 ]; then
    error "No se pudieron instalar las dependencias de Python. El script no puede continuar."
fi

# --- Descarga y Configuración de Archivos ---
# Se clona directamente en el directorio de destino para simplificar.
info "Creando el directorio de instalación y descargando el software en /opt/pysfreflector..."
if [ -d "/opt/pysfreflector" ]; then
    warn "El directorio /opt/pysfreflector ya existe. Se omitirá la descarga para no sobrescribir configuraciones existentes."
else
    git clone https://github.com/iu5jae/pYSFReflector3.git /opt/pysfreflector
    if [ $? -ne 0 ]; then
        error "Falló la descarga del repositorio desde GitHub."
    fi
fi

info "Creando un entorno virtual de Python en /opt/pysfreflector/venv..."
python3 -m venv /opt/pysfreflector/venv
if [ $? -ne 0 ]; then
    error "No se pudo crear el entorno virtual de Python."
fi

info "Instalando librerías de Python (aprslib, tinydb, threaded) en el entorno virtual..."
/opt/pysfreflector/venv/bin/pip install aprslib tinydb threaded
if [ $? -ne 0 ]; then
    error "Falló la instalación de las librerías de Python con pip en el entorno virtual."
fi

info "Estableciendo permisos de ejecución para el reflector..."
chmod +x /opt/pysfreflector/YSFReflector
if [ ! -f "/opt/pysfreflector/YSFReflector" ]; then
    error "El archivo YSFReflector no se encontró en /opt/pysfreflector. La instalación falló."
fi

echo
info "La instalación del componente principal del reflector ha finalizado."
echo

# --- Configuración del Reflector ---
warn "ATENCIÓN: Se requiere configuración manual."
echo "------------------------------------------------------------------"
echo "Ahora necesitas editar el archivo de configuración para ajustar"
echo "el reflector a tus necesidades."
echo
echo -e "Archivo a editar: ${COLOR_AMARILLO}/opt/pysfreflector/pysfreflector.ini${COLOR_NC}"
echo
echo "Puedes hacerlo abriendo OTRA TERMINAL y ejecutando:"
echo -e "${COLOR_AMARILLO}sudo nano /opt/pysfreflector/pysfreflector.ini${COLOR_NC}"
echo
echo "Asegúrate de configurar, como mínimo, las secciones:"
echo "  - [REFL] -> Name, Description"
echo "  - [NETWORK] -> Port, Json_port"
echo "  - [LOG] -> Path"
echo "------------------------------------------------------------------"
echo
read -p "$(echo -e ${COLOR_AMARILLO}'Presiona [Enter] cuando hayas guardado tus cambios para continuar... '${COLOR_NC})"

info "Configuración manual completada. Continuando con la instalación."
echo

# --- Instalación del Dashboard (Opcional) ---
if [ "$INSTALL_DASHBOARD" == "s" ]; then
    info "Iniciando la instalación del dashboard web..."

    info "Instalando dependencias del servidor web: apache2, php, php-sqlite3..."
    apt-get install -y apache2 php php-sqlite3
    if [ $? -ne 0 ]; then
        error "No se pudieron instalar las dependencias del servidor web."
    fi

    info "Creando directorio web en /var/www/html/ysf..."
    mkdir -p /var/www/html/ysf

    info "Copiando archivos del dashboard..."
    if [ -d "/opt/pysfreflector/dashboard" ]; then
        cp -r /opt/pysfreflector/dashboard/* /var/www/html/ysf/
        # Asignar permisos adecuados para que el servidor web pueda leer los archivos
        chown -R www-data:www-data /var/www/html/ysf
        find /var/www/html/ysf -type d -exec chmod 755 {} \;
        find /var/www/html/ysf -type f -exec chmod 644 {} \;
    else
        warn "No se encontró el directorio del dashboard en /opt/pysfreflector/dashboard. Omitiendo copia."
    fi

    warn "El dashboard requiere una configuración manual adicional."
    echo "Debes editar los archivos PHP en '/var/www/html/ysf' para establecer la ruta correcta a la base de datos."
    echo "Busca la línea: \$db = new SQLite3('/opt/pysfreflector/collector3.db');"
    echo "Y asegúrate de que la ruta sea correcta."
    echo
    info "Instalación del dashboard finalizada."
fi

# --- Configuración de Servicios (systemd) ---
info "Instalando los servicios de systemd..."

# 1. Servicio del Reflector
if [ -f "/opt/pysfreflector/ysfreflector.service" ]; then
    info "Copiando el archivo de servicio del reflector..."
    cp /opt/pysfreflector/ysfreflector.service /etc/systemd/system/ysfreflector.service
else
    warn "No se encontró el archivo ysfreflector.service. No se puede instalar el servicio."
fi

# 2. Servicio del Colector (si se instaló el dashboard)
if [ "$INSTALL_DASHBOARD" == "s" ]; then
    info "Creando el archivo de servicio para el colector del dashboard..."
    cat << EOF > /etc/systemd/system/collector3.service
[Unit]
Description=pYSFReflector3 Collector for Dashboard
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/pysfreflector
ExecStart=/opt/pysfreflector/venv/bin/python /opt/pysfreflector/collector3.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    info "Archivo de servicio collector3.service creado."
fi

info "Recargando el demonio de systemd para aplicar los cambios..."
systemctl daemon-reload

echo
info "La configuración de los servicios ha finalizado."
echo

# --- Finalización ---
echo "======================================================"
info "¡Instalación completada!"
echo "======================================================"
echo
warn "Recuerda que debes haber configurado tus archivos .ini y .php manualmente."
echo
echo "Una vez que hayas verificado tu configuración, puedes iniciar los servicios."
echo "Usa los siguientes comandos para habilitarlos (para que inicien con el sistema) y arrancarlos ahora:"
echo
echo -e "Para el Reflector:"
echo -e "  ${COLOR_AMARILLO}sudo systemctl enable --now ysfreflector.service${COLOR_NC}"
echo

if [ "$INSTALL_DASHBOARD" == "s" ]; then
    echo -e "Para el Colector del Dashboard:"
    echo -e "  ${COLOR_AMARILLO}sudo systemctl enable --now collector3.service${COLOR_NC}"
    echo
fi

echo "Puedes verificar el estado de los servicios en cualquier momento con:"
echo -e "  ${COLOR_VERDE}sudo systemctl status ysfreflector.service${COLOR_NC}"
if [ "$INSTALL_DASHBOARD" == "s" ]; then
    echo -e "  ${COLOR_VERDE}sudo systemctl status collector3.service${COLOR_NC}"
fi
echo

info "Gracias por usar este script. ¡Disfruta de pYSFReflector3!"
