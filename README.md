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

Para una mayor portabilidad y facilidad de gestión, este repositorio también incluye la configuración necesaria para desplegar el reflector como un contenedor de Docker.

### Prerrequisitos

*   **Docker**: [Instrucciones de instalación](https://docs.docker.com/engine/install/)
*   **Docker Compose**: [Instrucciones de instalación](https://docs.docker.com/compose/install/)

### Instrucciones de Despliegue

El despliegue con Docker simplifica enormemente la gestión del reflector.

1.  **Configuración Inicial**: Antes de lanzar el servicio por primera vez, asegúrate de que los ficheros `pysfreflector.ini` y `deny.db` existen en este directorio. Si `deny.db` no existe, puedes crearlo con el comando `touch deny.db`. Una vez verificados los ficheros, edita `pysfreflector.ini` para ajustar la configuración de tu reflector (nombre, descripción, etc.).

2.  **Construir e Iniciar el Servicio**: Abre una terminal en este directorio y ejecuta:
    ```bash
    docker-compose up --build -d
    ```
    *   `--build`: Necesario la primera vez que lo ejecutas o si modificas el `Dockerfile`.
    *   `-d`: Ejecuta el contenedor en segundo plano (modo "detached").

3.  **Gestionar la Configuración**:
    *   **Lista Negra**: Para banear o permitir indicativos, simplemente edita el fichero `deny.db` en este directorio.
    *   **Aplicar Cambios**: Después de modificar `deny.db` o `pysfreflector.ini`, aplica los cambios reiniciando el contenedor:
        ```bash
        docker-compose restart
        ```

4.  **Comandos Útiles**:
    *   **Ver Logs en Tiempo Real**:
        ```bash
        docker-compose logs -f
        ```
    *   **Detener el Servicio**:
        ```bash
        docker-compose down
        ```

### Entendiendo el `docker-compose.yml`

El fichero `docker-compose.yml` orquesta la creación y gestión del contenedor. Aquí se describen sus variables clave:

*   `version: '3.8'`: Define la versión de la sintaxis de Docker Compose que se está utilizando.
*   `services`: Define los diferentes contenedores que gestionará Docker Compose. En este caso, solo uno: `ysfreflector`.
*   `container_name: ysfreflector`: Asigna un nombre predecible al contenedor para identificarlo fácilmente.
*   `build`:
    *   `context: .`: Indica a Docker que construya la imagen desde el directorio actual.
    *   `dockerfile: Dockerfile`: Especifica que debe usar el fichero `Dockerfile` para construirla.
*   `restart: always`: Política de reinicio. Asegura que el contenedor se inicie automáticamente si se detiene o si se reinicia el sistema.
*   `ports`: Mapea los puertos entre el host y el contenedor.
    *   `"42000:42000/udp"`: Conecta el puerto UDP 42000 de tu máquina al puerto 42000 del contenedor, permitiendo que las radios se conecten al reflector.
*   `volumes`: Sincroniza ficheros o carpetas entre el host y el contenedor.
    *   `./pysfreflector.ini:/opt/pysfreflector/pysfreflector.ini`: Permite editar el fichero de configuración principal desde fuera del contenedor.
    *   `./deny.db:/opt/pysfreflector/deny.db`: Permite gestionar la lista de baneados de la misma manera.
