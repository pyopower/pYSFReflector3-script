# Instalación de pYSFReflector3 en Ubuntu

Este repositorio contiene un script para automatizar la instalación de [pYSFReflector3 de iu5jae](https://github.com/iu5jae/pYSFReflector3) en sistemas Ubuntu y derivados.

## Instalación Rápida (Recomendado)

Puedes descargar y ejecutar el script directamente con un solo comando. Abre una terminal y pega lo siguiente:

```bash
wget -O install_pysfreflector.sh https://raw.githubusercontent.com/pyopower/pYSFReflector3-script/feat/install-script-improvements/install_pysfreflector.sh && chmod +x install_pysfreflector.sh && sudo ./install_pysfreflector.sh
```

Esto descargará el script, le dará permisos de ejecución y lo lanzará.

## Instalación Manual (Paso a Paso)

Si prefieres hacerlo manualmente, sigue estos pasos.

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
