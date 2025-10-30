# Dockerfile simplificado para LM Studio - Solo API/Servidor
FROM ubuntu:24.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Instalar dependencias mínimas
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias GUI por separado (si están disponibles)
RUN apt-get update && apt-get install -y \
    libnss3 \
    libxss1 \
    libxtst6 \
    libxrandr2 \
    libglib2.0-0 \
    libgobject-2.0-0 \
    libdbus-1-3 \
    || true && rm -rf /var/lib/apt/lists/*

# Crear usuario
RUN useradd -m -s /bin/bash lmstudio

# Crear directorios
RUN mkdir -p /home/lmstudio/models \
    /home/lmstudio/.cache/lm-studio \
    /home/lmstudio/logs \
    /opt/lm-studio

# Descargar LM Studio
WORKDIR /opt/lm-studio
RUN wget -O lmstudio.AppImage "https://installers.lmstudio.ai/linux/x64/0.3.15-11/LM-Studio-0.3.15-11-x64.AppImage" && \
    chmod +x lmstudio.AppImage && \
    ./lmstudio.AppImage --appimage-extract && \
    mv squashfs-root lm-studio-extracted && \
    chmod +x /opt/lm-studio/lm-studio-extracted/AppRun

# Script de inicio simple
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Cambiar propietario
RUN chown -R lmstudio:lmstudio /home/lmstudio /opt/lm-studio

# Exponer solo puerto API
EXPOSE 1234

# Variables de entorno
ENV LMSTUDIO_HOST=0.0.0.0
ENV LMSTUDIO_PORT=1234

# Volúmenes
VOLUME ["/home/lmstudio/models", "/home/lmstudio/.cache/lm-studio"]

# Usuario
USER lmstudio
WORKDIR /home/lmstudio

# Comando de inicio
CMD ["/usr/local/bin/start.sh"]