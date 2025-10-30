#!/bin/bash

echo "🚀 Iniciando LM Studio en modo servidor..."

# Crear directorios si no existen
mkdir -p /home/lmstudio/models
mkdir -p /home/lmstudio/.cache/lm-studio
mkdir -p /home/lmstudio/logs

# Variables de entorno
export LMSTUDIO_HOST=0.0.0.0
export LMSTUDIO_PORT=1234
export LMSTUDIO_MODELS_PATH=/home/lmstudio/models

# Verificar instalación
if [ ! -f "/opt/lm-studio/lm-studio-extracted/AppRun" ]; then
    echo "❌ Error: LM Studio no encontrado"
    exit 1
fi

echo "✅ LM Studio encontrado"
echo "📂 Modelos: /home/lmstudio/models"
echo "🌐 Servidor: http://0.0.0.0:1234"
echo "📋 API: http://0.0.0.0:1234/v1/models"

# Cambiar al directorio de LM Studio
cd /opt/lm-studio/lm-studio-extracted

# Ejecutar LM Studio en modo servidor
echo "🔄 Iniciando servidor LM Studio..."
exec ./AppRun \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --headless \
    --host 0.0.0.0 \
    --port 1234