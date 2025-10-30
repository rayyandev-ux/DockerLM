#!/bin/bash

# Script para iniciar LM Studio en modo headless
echo "Iniciando LM Studio..."

# Configurar variables de entorno
export DISPLAY=:1
export ELECTRON_DISABLE_SANDBOX=1
export ELECTRON_DISABLE_GPU=1

# Verificar que LM Studio existe
if [ ! -f "/opt/lm-studio/lm-studio-extracted/AppRun" ]; then
    echo "Error: LM Studio AppRun no encontrado"
    exit 1
fi

# Cambiar al directorio de LM Studio
cd /opt/lm-studio/lm-studio-extracted

# Verificar permisos
chmod +x AppRun

# Iniciar LM Studio con configuración para contenedor
echo "Ejecutando LM Studio con configuración de contenedor..."
exec ./AppRun \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection