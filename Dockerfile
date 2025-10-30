# Dockerfile para LM Studio - Optimizado para CPU
FROM ubuntu:24.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    xvfb \
    x11vnc \
    fluxbox \
    novnc \
    websockify \
    supervisor \
    python3 \
    python3-pip \
    git \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    libopenblas-dev \
    liblapack-dev \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root
RUN useradd -m -s /bin/bash lmstudio && \
    echo "lmstudio:lmstudio" | chpasswd && \
    usermod -aG sudo lmstudio

# Crear directorios necesarios
RUN mkdir -p /home/lmstudio/.cache/lm-studio \
    /home/lmstudio/models \
    /home/lmstudio/logs \
    /opt/lm-studio \
    /var/log/supervisor

# Descargar e instalar LM Studio (URL actualizada)
WORKDIR /opt/lm-studio
RUN wget -O lmstudio.AppImage "https://installers.lmstudio.ai/linux/x64/0.3.15-11/LM-Studio-0.3.15-11-x64.AppImage" && \
    chmod +x lmstudio.AppImage && \
    ./lmstudio.AppImage --appimage-extract && \
    mv squashfs-root lm-studio-extracted && \
    ln -sf /opt/lm-studio/lm-studio-extracted/AppRun /usr/local/bin/lmstudio

# Configurar VNC y noVNC
RUN mkdir -p /home/lmstudio/.vnc && \
    echo "lmstudio" | vncpasswd -f > /home/lmstudio/.vnc/passwd && \
    chmod 600 /home/lmstudio/.vnc/passwd

# Configurar supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Script de inicio
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Cambiar propietario de archivos
RUN chown -R lmstudio:lmstudio /home/lmstudio /opt/lm-studio

# Exponer puertos
EXPOSE 1234 6080 5900

# Variables de entorno
ENV DISPLAY=:1
ENV VNC_PORT=5900
ENV NOVNC_PORT=6080
ENV LMSTUDIO_PORT=1234
ENV LMSTUDIO_HOST=0.0.0.0

# Volúmenes
VOLUME ["/home/lmstudio/models", "/home/lmstudio/.cache/lm-studio", "/home/lmstudio/logs"]

# Usuario por defecto
USER lmstudio
WORKDIR /home/lmstudio

# Comando de inicio
CMD ["/usr/local/bin/start.sh"]