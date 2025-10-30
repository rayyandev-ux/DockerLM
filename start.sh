#!/bin/bash

echo "🚀 Iniciando LM Studio en modo servidor..."

# Crear directorios si no existen
mkdir -p /home/lmstudio/models
mkdir -p /home/lmstudio/.cache/lm-studio
mkdir -p /home/lmstudio/logs

# Variables de entorno para suprimir errores de GUI
export LMSTUDIO_HOST=0.0.0.0
export LMSTUDIO_PORT=1234
export LMSTUDIO_MODELS_PATH=/home/lmstudio/models
export DISPLAY=:99
export DBUS_SESSION_BUS_ADDRESS=""
export XDG_RUNTIME_DIR=/tmp
export ELECTRON_DISABLE_SANDBOX=1
export ELECTRON_DISABLE_GPU=1
export LMS_SERVER_PORT=1234
export LMS_HOST=0.0.0.0

# Usar dominio si está configurado
if [ ! -z "$LMSTUDIO_DOMAIN" ]; then
    echo "🌐 Dominio configurado: https://$LMSTUDIO_DOMAIN"
    export LMS_DOMAIN=$LMSTUDIO_DOMAIN
fi

# Verificar instalación
if [ ! -d "/opt/lm-studio/lm-studio-extracted" ]; then
    echo "❌ Error: LM Studio no encontrado"
    exit 1
fi

echo "✅ LM Studio encontrado"
echo "📂 Modelos: /home/lmstudio/models"
echo "🌐 Servidor: LM Studio iniciándose..."
echo "📋 API: Verificar logs para puerto actual"

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

# Iniciar display virtual para evitar errores de GUI
echo "🖥️ Iniciando display virtual..."
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
export DISPLAY=:99

# Crear archivo de configuración para forzar puerto 1234 y activar API
mkdir -p /home/lmstudio/.config/LM\ Studio
cat > "/home/lmstudio/.config/LM Studio/settings.json" << 'EOF'
{
  "server": {
    "port": 1234,
    "host": "0.0.0.0",
    "autoStart": true,
    "enabled": true
  },
  "api": {
    "enabled": true,
    "port": 1234,
    "host": "0.0.0.0"
  },
  "httpServer": {
    "port": 1234,
    "host": "0.0.0.0",
    "enabled": true
  }
}
EOF

# Crear configuración del servidor HTTP
mkdir -p /home/lmstudio/.cache/lm-studio/.internal
cat > "/home/lmstudio/.cache/lm-studio/.internal/http-server-config.json" << 'EOF'
{
  "port": 1234,
  "host": "0.0.0.0",
  "enabled": true,
  "autoStart": true
}
EOF

# Variables de entorno específicas para forzar puerto
export LMS_SERVER_PORT=1234
export LMS_HOST=0.0.0.0
export LMS_API_PORT=1234
export LMSTUDIO_SERVER_PORT=1234
export LMSTUDIO_API_PORT=1234

# Esperar a que Xvfb se inicie
sleep 2

# Ejecutar LM Studio DIRECTAMENTE en puerto 1234
echo "🔄 Iniciando LM Studio DIRECTAMENTE en puerto 1234..."

# Forzar puerto 1234 con todos los flags posibles
$EXECUTABLE \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --headless \
    --host 0.0.0.0 \
    --port 1234 \
    --server-port 1234 \
    --api-port 1234 \
    --http-port 1234 \
    --server \
    --api \
    --enable-server \
    --enable-api &

LM_PID=$!
echo "🔄 LM Studio iniciado DIRECTAMENTE en puerto 1234 (PID: $LM_PID)"

# Esperar y verificar
echo "⏳ Esperando a que LM Studio inicie en puerto 1234..."
sleep 60

# Verificar que el proceso sigue vivo
if ! kill -0 $LM_PID 2>/dev/null; then
    echo "❌ LM Studio se detuvo inesperadamente"
    echo "🔍 Verificando logs..."
    ps aux | grep lm-studio || echo "❌ Proceso no encontrado"
else
    echo "✅ LM Studio ejecutándose en puerto 1234 (PID: $LM_PID)"
fi

# Verificar conectividad directa
echo "🔍 Verificando conectividad en puerto 1234..."
if curl -s http://localhost:1234/ >/dev/null 2>&1; then
    echo "✅ LM Studio respondiendo en puerto 1234"
else
    echo "⚠️ LM Studio puede estar iniciando aún..."
fi

echo "✅ Sistema listo - LM Studio DIRECTO en puerto 1234"
echo "🌐 API disponible en: http://0.0.0.0:1234/v1/models"

# Mantener el contenedor vivo
while true; do
    sleep 30
    # Verificar que el proceso sigue vivo
    if ! kill -0 $LM_PID 2>/dev/null; then
        echo "❌ LM Studio se detuvo"
        exit 1
    fi
done