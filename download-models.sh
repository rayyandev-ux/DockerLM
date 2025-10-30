#!/bin/bash

# Script para descargar modelos populares para LM Studio
# Este script se ejecuta dentro del contenedor

echo "=== Script de descarga de modelos para LM Studio ==="
echo "Iniciando descarga de modelos populares..."

# Directorio de modelos
MODELS_DIR="/home/lmstudio/models"
mkdir -p "$MODELS_DIR"

# Función para descargar modelos usando curl
download_model() {
    local model_name="$1"
    local model_url="$2"
    local model_file="$3"
    
    echo "Descargando $model_name..."
    echo "URL: $model_url"
    echo "Archivo: $model_file"
    
    if [ ! -f "$MODELS_DIR/$model_file" ]; then
        curl -L -o "$MODELS_DIR/$model_file" "$model_url"
        if [ $? -eq 0 ]; then
            echo "✅ $model_name descargado exitosamente"
        else
            echo "❌ Error descargando $model_name"
        fi
    else
        echo "ℹ️  $model_name ya existe, saltando descarga"
    fi
    echo "---"
}

# Lista de modelos populares y ligeros para CPU
echo "Descargando modelos optimizados para CPU..."

# Llama 3.2 1B (muy ligero)
download_model "Llama 3.2 1B Instruct" \
    "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf" \
    "Llama-3.2-1B-Instruct-Q4_K_M.gguf"

# Llama 3.2 3B (ligero)
download_model "Llama 3.2 3B Instruct" \
    "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf" \
    "Llama-3.2-3B-Instruct-Q4_K_M.gguf"

# Phi-3 Mini (muy eficiente para CPU)
download_model "Phi-3 Mini 4K Instruct" \
    "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf" \
    "Phi-3-mini-4k-instruct-q4.gguf"

# Gemma 2B (ligero de Google)
download_model "Gemma 2B Instruct" \
    "https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf" \
    "gemma-2-2b-it-Q4_K_M.gguf"

# Qwen 2.5 1.5B (muy eficiente)
download_model "Qwen 2.5 1.5B Instruct" \
    "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf" \
    "qwen2.5-1.5b-instruct-q4_k_m.gguf"

echo ""
echo "=== Descarga completada ==="
echo "Modelos disponibles en: $MODELS_DIR"
ls -lh "$MODELS_DIR"

echo ""
echo "=== Configuración de LM Studio ==="
echo "Los modelos se han descargado y estarán disponibles en LM Studio."
echo "Puedes acceder a la interfaz web en: http://localhost:6080"
echo "API disponible en: http://localhost:1234"

# Configurar permisos
chown -R lmstudio:lmstudio "$MODELS_DIR"
chmod -R 755 "$MODELS_DIR"

echo "✅ Script completado exitosamente"