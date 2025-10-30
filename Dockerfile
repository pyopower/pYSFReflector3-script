# Dockerfile para pYSFReflector3
# Autor: Jules (Asistente de IA)

# 1. Imagen Base
# Se utiliza una imagen ligera de Python 3.9 para mantener el tamaño final reducido.
FROM python:3.9-slim

# 2. Metadatos de la Imagen
LABEL maintainer="Jules"
LABEL description="Imagen Docker para ejecutar pYSFReflector3 de iu5jae."

# 3. Instalación de Dependencias del Sistema
# Se actualiza la lista de paquetes y se instala 'git', necesario para clonar el repositorio.
# Se limpia la caché de apt para reducir el tamaño de la imagen.
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# 4. Clonación del Repositorio
# Se clona el código fuente del reflector directamente en el directorio de destino.
RUN git clone https://github.com/iu5jae/pYSFReflector3.git /opt/pysfreflector

# 5. Establecer el Directorio de Trabajo
# Todas las operaciones posteriores (como la instalación de pip y la ejecución)
# se realizarán desde este directorio.
WORKDIR /opt/pysfreflector

# 6. Instalación de Dependencias de Python
# Se instalan las librerías de Python requeridas por la aplicación.
# --no-cache-dir evita que pip guarde paquetes en caché, reduciendo el tamaño de la imagen.
RUN pip install --no-cache-dir aprslib tinydb

# 7. Copiar y Preparar el Entrypoint
# Se copia el script que genera la configuración y se le dan permisos de ejecución.
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# 8. Permisos de Ejecución para la Aplicación
# Se asegura de que el script principal del reflector tenga permisos para ser ejecutado.
RUN chmod +x YSFReflector

# 9. Exponer el Puerto
# Se informa a Docker que el contenedor escuchará en el puerto 42000 en tiempo de ejecución.
EXPOSE 42000

# 10. Entrypoint y Comando por Defecto
# El ENTRYPOINT es el script que se ejecutará al iniciar el contenedor.
# El CMD son los argumentos que se le pasarán a ese script.
ENTRYPOINT ["./entrypoint.sh"]
CMD ["python3", "/opt/pysfreflector/YSFReflector"]
