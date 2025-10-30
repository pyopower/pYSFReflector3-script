# Instalación de pYSFReflector3 en Ubuntu

Este repositorio contiene un script para automatizar la instalación de [pYSFReflector3 de iu5jae](https://github.com/iu5jae/pYSFReflector3) en sistemas Ubuntu y derivados.

## Instalación Automática con Script

Se proporciona un script (`install_pysfreflector.sh`) que instala el software, sus dependencias, y lo configura como un servicio del sistema.

### Requisitos

*   Un sistema con Ubuntu (probado en 22.04, compatible con versiones recientes).
*   Acceso de superusuario (`sudo`).
*   Conexión a internet.

### Instrucciones de Uso

1.  **Descargar el script**: Asegúrate de tener el archivo `install_pysfreflector.sh` en tu sistema.

2.  **Dar permisos de ejecución**: Abre una terminal y navega hasta la ubicación del script. Luego, ejecuta:
    ```bash
    chmod +x install_pysfreflector.sh
    ```

3.  **Ejecutar el script**: Lanza el instalador con privilegios de superusuario:
    ```bash
    sudo ./install_pysfreflector.sh
    ```

### ¿Qué hace el script?

El script es interactivo y te guiará durante el proceso:

1.  **Pregunta por el Dashboard**: Te consultará si deseas instalar solo el reflector principal o también el dashboard web opcional (esto instalará Apache2 y PHP).
2.  **Instala Dependencias**: Actualiza tu sistema e instala `git`, `python3`, `pip` y todas las librerías necesarias.
3.  **Descarga el Software**: Clona la última versión de `pYSFReflector3` en el directorio `/opt/pysfreflector`.
4.  **Pausa para Configuración Manual**: El script se detendrá y te pedirá que edites el archivo de configuración principal (`/opt/pysfreflector/pysfreflector.ini`). Deberás abrir una segunda terminal para hacerlo.
5.  **Configura los Servicios**: Instala y configura los servicios de `systemd` para que tanto el reflector como el colector (si se instaló) se inicien automáticamente con el sistema.
6.  **Instrucciones Finales**: Al terminar, te mostrará los comandos exactos para habilitar e iniciar los servicios.

Una vez finalizado el script, tu sistema pYSFReflector3 estará listo y funcional.

---

## Despliegue con Docker

Para una mayor portabilidad y facilidad de gestión, este repositorio incluye una configuración para desplegar el reflector como un contenedor de Docker. Este método es el recomendado.

### Prerrequisitos

*   **Docker**: [Instrucciones de instalación](https://docs.docker.com/engine/install/)
*   **Docker Compose**: [Instrucciones de instalación](https://docs.docker.com/compose/install/)

### Instrucciones de Despliegue

1.  **Configurar el Reflector**:
    *   Toda la configuración del reflector se gestiona a través de **variables de entorno** en el fichero `docker-compose.yml`.
    *   Abre el fichero `docker-compose.yml` y edita la sección `environment` para ajustar parámetros como el nombre del reflector (`INFO_NAME`), la descripción (`INFO_DESCRIPTION`), el puerto (`NETWORK_PORT`), etc.

2.  **Preparar Fichero de Baneados**:
    *   Asegúrate de que el fichero `deny.db` existe en este directorio. Si no es así, créalo con el comando:
        ```bash
        touch deny.db
        ```

3.  **Construir e Iniciar el Servicio**:
    *   Abre una terminal en este directorio y ejecuta:
        ```bash
        docker-compose up --build -d
        ```
    *   `--build`: Necesario la primera vez que lo ejecutas o si modificas el `Dockerfile`.
    *   `-d`: Ejecuta el contenedor en segundo plano (modo "detached").

4.  **Gestionar la Configuración y Lista Negra**:
    *   **Configuración General**: Para cambiar cualquier parámetro del reflector, modifica las variables de entorno en `docker-compose.yml`.
    *   **Lista Negra**: Para banear o permitir indicativos, edita el fichero `deny.db` localmente.
        *   **Formato del fichero `deny.db`**:
            *   Para **banear** un indicativo: `CS:INDICATIVO` (Ej: `CS:EB1ABC`)
            *   Para añadir a la **lista blanca**: `AL:INDICATIVO` (Ej: `AL:EA1XYZ`)
            *   Para **bloquear por sufijo**: `SB:SUFIJO` (Ej: `SB:RPT`)
    *   **Aplicar Cambios**: Después de modificar `docker-compose.yml` o `deny.db`, aplica los cambios reiniciando el contenedor:
        ```bash
        docker-compose restart
        ```

5.  **Comandos Útiles**:
    *   **Ver Logs en Tiempo Real**:
        ```bash
        docker-compose logs -f
        ```
    *   **Detener el Servicio**:
        ```bash
        docker-compose down
        ```
