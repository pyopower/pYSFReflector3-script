#!/bin/bash

# ============================================================================
# Script de Instalación y Gestión para pYSFReflector3
#
# Autor: Jules (Asistente de IA)
# Versión: 2.0 (con Menú de Gestión)
#
# Este script instala pYSFReflector3 de iu5jae, y si ya está
# instalado, proporciona un menú para gestionarlo.
# ============================================================================

# --- Variables de Color ---
COLOR_ROJO='\033[0;31m'
COLOR_VERDE='\033[0;32m'
COLOR_AMARILLO='\033[1;33m'
COLOR_NC='\033[0m' # Sin Color

# --- Variables Globales ---
INSTALL_DIR="/opt/pysfreflector"
CONFIG_FILE="${INSTALL_DIR}/pysfreflector.ini"

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

# --- Lógica de Instalación ---
run_installation() {
    info "Iniciando la instalación de pYSFReflector3..."

    # --- Preguntar sobre el Dashboard ---
    local INSTALL_DASHBOARD="n"
    read -p "$(echo -e ${COLOR_AMARILLO}'¿Deseas instalar también el dashboard web (Apache2, PHP, SQLite3)? [s/N]: '${COLOR_NC})" choice
    case "$choice" in
      s|S|si|SI ) INSTALL_DASHBOARD="s";;
      * ) INSTALL_DASHBOARD="n";;
    esac

    if [ "$INSTALL_DASHBOARD" == "s" ]; then
        info "Se intentará instalar el reflector principal y el dashboard web."
    else
        info "Se instalará únicamente el reflector principal."
    fi
    echo

    # --- Preparación del Sistema ---
    info "Actualizando la lista de paquetes del sistema (apt update)..."
    if ! apt-get update; then
        warn "------------------------------------------------------------------"
        warn "ATENCIÓN: Falló la actualización de la lista de paquetes."
        warn "El script intentará continuar, pero la instalación de algunos componentes podría fallar."
        warn "------------------------------------------------------------------"
    fi

    info "Instalando dependencias esenciales: 'git', 'python3', 'pip' y 'venv'..."
    if ! apt-get install -y git python3 python3-pip python3-venv; then
        error "No se pudieron instalar las dependencias esenciales. El script no puede continuar."
    fi
    echo

    # --- Instalación del Reflector ---
    info "Creando el directorio de instalación y descargando el software en ${INSTALL_DIR}..."
    if [ -d "${INSTALL_DIR}" ]; then
        warn "El directorio ${INSTALL_DIR} ya existe. Se omitirá la descarga."
    else
        git clone https://github.com/iu5jae/pYSFReflector3.git "${INSTALL_DIR}"
        if [ $? -ne 0 ]; then
            error "Falló la descarga del repositorio desde GitHub."
        fi
    fi

    info "Creando un entorno virtual de Python en ${INSTALL_DIR}/venv..."
    python3 -m venv "${INSTALL_DIR}/venv"
    if [ $? -ne 0 ]; then
        error "No se pudo crear el entorno virtual de Python."
    fi

    info "Instalando librerías de Python en el entorno virtual..."
    "${INSTALL_DIR}/venv/bin/pip" install aprslib tinydb threaded
    if [ $? -ne 0 ]; then
        error "Falló la instalación de las librerías de Python con pip."
    fi

    info "Estableciendo permisos de ejecución para el reflector..."
    chmod +x "${INSTALL_DIR}/YSFReflector"
    if [ ! -f "${INSTALL_DIR}/YSFReflector" ]; then
        error "El archivo YSFReflector no se encontró. La instalación falló."
    fi
    echo
    info "La instalación del componente principal del reflector ha finalizado."
    echo

    # --- Configuración Interactiva del Reflector ---
    if [ ! -f "$CONFIG_FILE" ]; then
        warn "No se encontró el archivo de configuración $CONFIG_FILE. Omitiendo configuración interactiva."
    else
        cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
        info "Se ha creado una copia de seguridad en $CONFIG_FILE.bak"

        echo "------------------------------------------------------------------"
        echo "Por favor, introduce los valores para la configuración básica."
        echo "Puedes presionar [Enter] para aceptar los valores por defecto."
        echo "------------------------------------------------------------------"

        DEFAULT_NAME=$(grep -E "^Name\s*=" "$CONFIG_FILE" | cut -d '=' -f2 | xargs)
        read -p "$(echo -e ${COLOR_AMARILLO}"Nombre del Reflector [${DEFAULT_NAME}]: "${COLOR_NC})" REFL_NAME
        REFL_NAME=${REFL_NAME:-$DEFAULT_NAME}
        sed -i "s/^Name\s*=.*/Name = ${REFL_NAME}/" "$CONFIG_FILE"

        DEFAULT_DESC=$(grep -E "^Description\s*=" "$CONFIG_FILE" | cut -d '=' -f2 | xargs)
        read -p "$(echo -e ${COLOR_AMARILLO}"Descripción del Reflector [${DEFAULT_DESC}]: "${COLOR_NC})" REFL_DESC
        REFL_DESC=${REFL_DESC:-$DEFAULT_DESC}
        sed -i "s/^Description\s*=.*/Description = ${REFL_DESC}/" "$CONFIG_FILE"

        DEFAULT_PORT=$(grep -E "^Port\s*=" "$CONFIG_FILE" | cut -d '=' -f2 | xargs)
        read -p "$(echo -e ${COLOR_AMARILLO}"Puerto de Red [${DEFAULT_PORT}]: "${COLOR_NC})" REFL_PORT
        REFL_PORT=${REFL_PORT:-$DEFAULT_PORT}
        sed -i "s/^Port\s*=.*/Port = ${REFL_PORT}/" "$CONFIG_FILE"

        echo "------------------------------------------------------------------"
        info "El archivo de configuración ha sido actualizado."
        warn "Para configuraciones avanzadas, puedes editar manualmente $CONFIG_FILE"
        echo "------------------------------------------------------------------"
    fi
    echo

    # --- Instalación del Dashboard (Opcional) ---
    local DASHBOARD_INSTALL_SUCCESS="n"
    if [ "$INSTALL_DASHBOARD" == "s" ]; then
        info "Iniciando la instalación del dashboard web..."
        info "Instalando dependencias del servidor web: apache2, php, php-sqlite3..."
        if ! apt-get install -y apache2 php php-sqlite3; then
            warn "ATENCIÓN: No se pudieron instalar las dependencias del dashboard (Apache/PHP)."
            warn "La instalación del dashboard se OMITIRÁ."
        else
            info "Copiando archivos del dashboard a /var/www/html/ysf..."
            mkdir -p /var/www/html/ysf
            if [ -d "${INSTALL_DIR}/dashboard" ]; then
                cp -r "${INSTALL_DIR}/dashboard/"* /var/www/html/ysf/
                chown -R www-data:www-data /var/www/html/ysf
                DASHBOARD_INSTALL_SUCCESS="s"
                info "Instalación del dashboard finalizada con éxito."
            else
                warn "No se encontró el directorio del dashboard. Omitiendo copia."
            fi
        fi
    fi

    # --- Configuración de Servicios (systemd) ---
    info "Instalando los servicios de systemd..."
    if [ -f "${INSTALL_DIR}/ysfreflector.service" ]; then
        cp "${INSTALL_DIR}/ysfreflector.service" /etc/systemd/system/ysfreflector.service
    else
        warn "No se encontró el archivo ysfreflector.service."
    fi

    if [ "$DASHBOARD_INSTALL_SUCCESS" == "s" ]; then
        info "Creando el archivo de servicio para el colector del dashboard..."
        cat << EOF > /etc/systemd/system/collector3.service
[Unit]
Description=pYSFReflector3 Collector for Dashboard
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/venv/bin/python ${INSTALL_DIR}/collector3.py
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    fi

    systemctl daemon-reload
    info "La configuración de los servicios ha finalizado."
    echo

    # --- Finalización ---
    echo "======================================================"
    info "¡Instalación completada!"
    echo "======================================================"
    echo "Usa los siguientes comandos para habilitar y arrancar los servicios:"
    echo -e "  ${COLOR_AMARILLO}sudo systemctl enable --now ysfreflector.service${COLOR_NC}"
    if [ "$DASHBOARD_INSTALL_SUCCESS" == "s" ]; then
        echo -e "  ${COLOR_AMARILLO}sudo systemctl enable --now collector3.service${COLOR_NC}"
    fi
    echo
    info "Puedes volver a ejecutar este script en cualquier momento para gestionar la instalación."
}

# --- Lógica de Desinstalación ---
uninstall_reflector() {
    warn "------------------------------------------------------------------"
    warn "Estás a punto de desinstalar pYSFReflector3 por completo."
    warn "Esto eliminará todos los archivos, servicios y configuraciones."
    warn "------------------------------------------------------------------"
    read -p "$(echo -e ${COLOR_AMARILLO}'¿Estás seguro de que deseas continuar? [s/N]: '${COLOR_NC})" choice
    case "$choice" in
      s|S|si|SI ) ;;
      * ) info "Desinstalación cancelada."; return;;
    esac

    info "Deteniendo y deshabilitando servicios..."
    systemctl stop ysfreflector.service >/dev/null 2>&1
    systemctl disable ysfreflector.service >/dev/null 2>&1

    if [ -f "/etc/systemd/system/collector3.service" ]; then
        systemctl stop collector3.service >/dev/null 2>&1
        systemctl disable collector3.service >/dev/null 2>&1
    fi

    info "Eliminando archivos de servicio de systemd..."
    rm -f /etc/systemd/system/ysfreflector.service
    rm -f /etc/systemd/system/collector3.service
    systemctl daemon-reload

    info "Eliminando directorio de instalación: ${INSTALL_DIR}..."
    rm -rf "${INSTALL_DIR}"

    if [ -d "/var/www/html/ysf" ]; then
        info "Eliminando directorio del dashboard: /var/www/html/ysf..."
        rm -rf "/var/www/html/ysf"
    fi

    echo
    info "pYSFReflector3 ha sido desinstalado por completo."
    echo
}

# --- Menú de Gestión ---
management_menu() {
    while true; do
        echo "======================================================"
        echo "Menú de Gestión de pYSFReflector3"
        echo "======================================================"
        echo -e "${COLOR_AMARILLO}1.${COLOR_NC} Ver estado de los servicios"
        echo -e "${COLOR_AMARILLO}2.${COLOR_NC} Iniciar los servicios"
        echo -e "${COLOR_AMARILLO}3.${COLOR_NC} Detener los servicios"
        echo -e "${COLOR_AMARILLO}4.${COLOR_NC} Editar archivo de configuración"
        echo -e "${COLOR_AMARILLO}5.${COLOR_NC} ${COLOR_ROJO}Reinstalar reflector${COLOR_NC}"
        echo -e "${COLOR_AMARILLO}6.${COLOR_NC} ${COLOR_ROJO}Desinstalar reflector${COLOR_NC}"
        echo -e "${COLOR_AMARILLO}7.${COLOR_NC} Salir"
        echo "------------------------------------------------------"
        read -p "Por favor, selecciona una opción [1-7]: " choice

        case $choice in
            1)
                info "--- Estado del servicio ysfreflector ---"
                systemctl status ysfreflector.service
                if [ -f "/etc/systemd/system/collector3.service" ]; then
                    info "--- Estado del servicio collector3 ---"
                    systemctl status collector3.service
                fi
                ;;
            2)
                info "Iniciando servicios..."
                systemctl start ysfreflector.service
                if [ -f "/etc/systemd/system/collector3.service" ]; then
                    systemctl start collector3.service
                fi
                info "Servicios iniciados."
                ;;
            3)
                info "Deteniendo servicios..."
                systemctl stop ysfreflector.service
                if [ -f "/etc/systemd/system/collector3.service" ]; then
                    systemctl stop collector3.service
                fi
                info "Servicios detenidos."
                ;;
            4)
                if command -v nano &> /dev/null; then
                    info "Abriendo editor de texto nano..."
                    nano "${CONFIG_FILE}"
                else
                    warn "El editor 'nano' no está instalado. Por favor, edita el archivo manualmente:"
                    echo "${CONFIG_FILE}"
                fi
                ;;
            5)
                warn "Procediendo a reinstalar..."
                uninstall_reflector
                run_installation
                info "Reinstalación completada."
                break
                ;;
            6)
                uninstall_reflector
                break
                ;;
            7)
                info "Saliendo del menú de gestión."
                break
                ;;
            *)
                warn "Opción no válida. Por favor, elige un número del 1 al 7."
                ;;
        esac
        echo
        read -p "Presiona [Enter] para continuar..."
        clear
    done
}

# --- Flujo Principal ---
main() {
    # --- Verificación de Root ---
    if [ "$(id -u)" -ne 0 ]; then
        error "Este script debe ejecutarse como root. Por favor, utiliza 'sudo $0'"
    fi

    if [ -d "${INSTALL_DIR}" ]; then
        management_menu
    else
        run_installation
    fi
}

main "$@"