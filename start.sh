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
if [ ! -d "/opt/lm-studio/lm-studio-extracted" ]; then
    echo "❌ Error: LM Studio no encontrado"
    exit 1
fi

echo "✅ LM Studio encontrado"
echo "📂 Modelos: /home/lmstudio/models"
echo "🌐 Servidor: http://0.0.0.0:1234"
echo "📋 API: http://0.0.0.0:1234/v1/models"

# Cambiar al directorio de LM Studio
cd /opt/lm-studio/lm-studio-extracted

# Buscar el ejecutable correcto
if [ -f "lm-studio" ]; then
    EXECUTABLE="./lm-studio"
elif [ -f "lmstudio" ]; then
    EXECUTABLE="./lmstudio"
elif [ -f "LM Studio" ]; then
    EXECUTABLE="./LM Studio"
else
    echo "🔍 Buscando ejecutable..."
    ls -la
    # Usar el primer ejecutable encontrado
    EXECUTABLE=$(find . -type f -executable | head -1)
    if [ -z "$EXECUTABLE" ]; then
        echo "❌ No se encontró ejecutable"
        exit 1
    fi
fi

echo "🔄 Usando ejecutable: $EXECUTABLE"

# Ejecutar LM Studio en modo servidor
echo "🔄 Iniciando servidor LM Studio..."
exec $EXECUTABLE \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --headless \
    --host 0.0.0.0 \
    --port 1234