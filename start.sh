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

# Ejecutar LM Studio en modo servidor con display virtual
echo "🔄 Iniciando servidor LM Studio con display virtual..."

# Iniciar LM Studio de forma simple (deja que use su puerto preferido)
$EXECUTABLE \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --headless &

LM_PID=$!
echo "🔄 LM Studio iniciado con PID: $LM_PID"

# Esperar a que LM Studio esté completamente listo
echo "⏳ Esperando a que LM Studio inicie completamente..."
sleep 45

# Verificar que el proceso sigue vivo
if ! kill -0 $LM_PID 2>/dev/null; then
    echo "❌ LM Studio se detuvo inesperadamente"
    echo "🔍 Verificando logs..."
    ps aux | grep lm-studio || echo "❌ Proceso no encontrado"
else
    echo "✅ LM Studio ejecutándose (PID: $LM_PID)"
fi

# Iniciar el servidor proxy mejorado
echo "🚀 Iniciando servidor proxy mejorado en puerto 1234..."
cd /opt

# Verificar que Node.js está disponible
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no encontrado"
    exit 1
fi

# Verificar que el archivo proxy existe
if [ ! -f "proxy-server.js" ]; then
    echo "❌ proxy-server.js no encontrado"
    exit 1
fi

echo "📋 Iniciando proxy inteligente con Node.js..."
node proxy-server.js &

PROXY_PID=$!
echo "🔄 Proxy iniciado con PID: $PROXY_PID"

# Verificar que ambos procesos están vivos
sleep 10
echo "🔍 Verificando estado de los servicios..."

if kill -0 $LM_PID 2>/dev/null; then
    echo "✅ LM Studio activo (PID: $LM_PID)"
else
    echo "❌ LM Studio no está ejecutándose"
fi

if kill -0 $PROXY_PID 2>/dev/null; then
    echo "✅ Proxy activo (PID: $PROXY_PID)"
else
    echo "❌ Proxy no está ejecutándose"
fi

# Verificar conectividad del proxy
echo "🔍 Verificando conectividad del proxy..."
if curl -s http://localhost:1234/ >/dev/null 2>&1; then
    echo "✅ Proxy respondiendo en puerto 1234"
else
    echo "⚠️ Proxy puede estar iniciando aún..."
fi

echo "✅ Sistema listo - LM Studio + Proxy Inteligente"
echo "🌐 API disponible en: http://0.0.0.0:1234/v1/models"
echo "🔍 Health check: http://0.0.0.0:1234/health"

# Mantener el contenedor vivo
while true; do
    sleep 30
    # Verificar que al menos uno de los procesos sigue vivo
    if ! kill -0 $LM_PID 2>/dev/null && ! kill -0 $PROXY_PID 2>/dev/null; then
        echo "❌ Todos los procesos se detuvieron"
        exit 1
    fi
done