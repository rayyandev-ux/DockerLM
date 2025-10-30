# Dockerfile simplificado para LM Studio - Solo API/Servidor
FROM ubuntu:24.04

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Instalar dependencias mínimas (incluyendo curl para healthcheck)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    xvfb \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias GUI esenciales (paso a paso para evitar errores)
RUN apt-get update

# Dependencias básicas de sistema
RUN apt-get install -y \
    libnss3 \
    libxss1 \
    libxtst6 \
    libxrandr2 \
    libglib2.0-0 \
    libgobject-2.0-0 \
    libdbus-1-3

# Dependencias GTK y Cairo
RUN apt-get install -y \
    libatk1.0-0 \
    libcairo2 \
    libgdk-pixbuf-2.0-0 \
    libgtk-3-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0

# Dependencias X11
RUN apt-get install -y \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3

# Audio y utilidades
RUN apt-get install -y \
    libasound2t64 \
    libfontconfig1 \
    libfreetype6 \
    xdg-utils

# Limpiar cache
RUN rm -rf /var/lib/apt/lists/*

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

# Copiar archivos de configuración
COPY start.sh /opt/start.sh
COPY package.json /opt/package.json
COPY proxy-server.js /opt/proxy-server.js

# Instalar dependencias de Node.js
RUN cd /opt && npm install

# Hacer ejecutable el script de inicio
RUN chmod +x /opt/start.sh

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
CMD ["/opt/start.sh"]