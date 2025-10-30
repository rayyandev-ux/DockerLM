#!/bin/bash

# Script de inicio para LM Studio en Docker
echo "Iniciando LM Studio en Docker..."

# Crear directorios si no existen
mkdir -p /home/lmstudio/.cache/lm-studio
mkdir -p /home/lmstudio/models
mkdir -p /home/lmstudio/logs

# Configurar permisos
chmod 755 /home/lmstudio/.cache/lm-studio
chmod 755 /home/lmstudio/models
chmod 755 /home/lmstudio/logs

# Configurar variables de entorno
export DISPLAY=:1
export LMSTUDIO_MODELS_PATH=/home/lmstudio/models
export LMSTUDIO_CACHE_PATH=/home/lmstudio/.cache/lm-studio

# Esperar un momento para que el sistema se estabilice
sleep 2

# Verificar si LM Studio está disponible
if [ ! -f "/opt/lm-studio/lm-studio-extracted/AppRun" ]; then
    echo "Error: LM Studio no encontrado. Verificando instalación..."
    ls -la /opt/lm-studio/
fi

# Configurar VNC password si no existe
if [ ! -f "/home/lmstudio/.vnc/passwd" ]; then
    mkdir -p /home/lmstudio/.vnc
    echo "lmstudio" > /home/lmstudio/.vnc/passwd
    chmod 600 /home/lmstudio/.vnc/passwd
fi

# Limpiar archivos de bloqueo previos
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

echo "Configuración completada. Iniciando servicios..."

# Iniciar supervisor con configuración específica para usuario no-root
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf