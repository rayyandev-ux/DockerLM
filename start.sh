#!/bin/bash

echo "🚀 Iniciando LM Studio en modo servidor..."
echo "✅ LM Studio encontrado"
echo "📂 Modelos: /home/lmstudio/models"

# Crear directorio de modelos si no existe
mkdir -p /home/lmstudio/models

# Descargar un modelo pequeño automáticamente si no hay modelos
if [ ! "$(ls -A /home/lmstudio/models)" ]; then
    echo "📥 Descargando modelo pequeño para pruebas..."
    cd /home/lmstudio/models
    
    # Descargar un modelo pequeño (TinyLlama 1.1B)
    wget -q --show-progress "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf" -O "tinyllama-1.1b-chat.gguf" || {
        echo "⚠️ No se pudo descargar el modelo, continuando sin modelo..."
    }
fi

echo "🌐 Servidor: LM Studio iniciándose..."
echo "📋 API: Verificar logs para puerto actual"
echo "🔄 Usando ejecutable: ./lm-studio"

# Iniciar LM Studio en modo servidor con configuración específica
cd /opt/lm-studio/lm-studio-extracted

# Configurar variables de entorno para evitar crashes
export DISPLAY=:99
export ELECTRON_DISABLE_SANDBOX=1
export ELECTRON_NO_ATTACH_CONSOLE=1
export LMS_SERVER_PORT=41343
export LMS_HOST=0.0.0.0

echo "🖥️ Iniciando display virtual..."
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &

echo "🔄 Iniciando LM Studio con configuración optimizada..."

# Iniciar LM Studio con configuraciones específicas para servidor
./lm-studio \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --headless \
    --server \
    --host 0.0.0.0 \
    --port 41343 \
    --cors \
    --verbose &

LM_STUDIO_PID=$!
echo "🔄 LM Studio iniciado con PID: $LM_STUDIO_PID"

echo "⏳ Esperando a que LM Studio inicie completamente..."
echo "⏳ Esto puede tomar hasta 3 minutos..."

# Esperar más tiempo para que LM Studio se estabilice
sleep 120

# Verificar si LM Studio sigue ejecutándose
if kill -0 $LM_STUDIO_PID 2>/dev/null; then
    echo "✅ LM Studio ejecutándose correctamente"
else
    echo "⚠️ LM Studio se detuvo, reintentando..."
    ./lm-studio --no-sandbox --disable-dev-shm-usage --server --host 0.0.0.0 --port 41343 &
    LM_STUDIO_PID=$!
    sleep 60
fi

echo "🚀 Iniciando proxy en puerto 1234..."
cd /opt
node proxy-server.js &
PROXY_PID=$!

echo "✅ Sistema iniciado:"
echo "   - LM Studio PID: $LM_STUDIO_PID"
echo "   - Proxy PID: $PROXY_PID"
echo "   - Puerto API: 41343"
echo "   - Puerto Proxy: 1234"

# Mantener el contenedor vivo y monitorear procesos
while true; do
    # Verificar si LM Studio sigue ejecutándose
    if ! kill -0 $LM_STUDIO_PID 2>/dev/null; then
        echo "⚠️ LM Studio se detuvo, reiniciando..."
        cd /opt/lm-studio/lm-studio-extracted
        ./lm-studio --no-sandbox --disable-dev-shm-usage --server --host 0.0.0.0 --port 41343 &
        LM_STUDIO_PID=$!
    fi
    
    # Verificar si el proxy sigue ejecutándose
    if ! kill -0 $PROXY_PID 2>/dev/null; then
        echo "⚠️ Proxy se detuvo, reiniciando..."
        cd /opt
        node proxy-server.js &
        PROXY_PID=$!
    fi
    
    sleep 30
done