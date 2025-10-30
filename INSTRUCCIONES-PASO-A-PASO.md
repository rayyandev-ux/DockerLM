# 🚀 Instrucciones Paso a Paso: LM Studio en EasyPanel

## 📋 Requisitos Previos

- ✅ Acceso a EasyPanel
- ✅ Ubuntu 24.04 como sistema base
- ✅ Docker instalado en EasyPanel
- ✅ Al menos 8GB RAM y 4 CPU cores disponibles
- ✅ 100GB de espacio en disco disponible

## 🔧 PASO 1: Preparar los Archivos

### 1.1 Subir archivos a tu servidor
Sube todos los archivos de este proyecto a tu servidor:
- `Dockerfile`
- `docker-compose.yml`
- `supervisord.conf`
- `start.sh`
- `download-models.sh`
- `.env`

### 1.2 Dar permisos de ejecución
```bash
chmod +x start.sh download-models.sh
```

## 🗄️ PASO 2: Crear Volúmenes en EasyPanel

### 2.1 Acceder a EasyPanel
1. Inicia sesión en tu panel de EasyPanel
2. Ve a la sección "Volumes" o "Volúmenes"

### 2.2 Crear volumen para modelos
1. Clic en "Create Volume"
2. **Nombre**: `lmstudio_models`
3. **Tamaño**: 100GB (recomendado)
4. **Descripción**: "Modelos de IA para LM Studio"
5. Clic en "Create"

### 2.3 Crear volumen para cache
1. Clic en "Create Volume"
2. **Nombre**: `lmstudio_cache`
3. **Tamaño**: 20GB
4. **Descripción**: "Cache de LM Studio"
5. Clic en "Create"

### 2.4 Crear volumen para logs
1. Clic en "Create Volume"
2. **Nombre**: `lmstudio_logs`
3. **Tamaño**: 5GB
4. **Descripción**: "Logs de LM Studio"
5. Clic en "Create"

## 🐳 PASO 3: Crear la Aplicación en EasyPanel

### 3.1 Nueva aplicación
1. Ve a "Applications" en EasyPanel
2. Clic en "Create Application"
3. Selecciona "Docker Compose"
4. **Nombre**: `lmstudio`
5. **Descripción**: "LM Studio - Local AI Models"

### 3.2 Configurar Docker Compose
1. En el editor, pega el contenido completo del archivo `docker-compose.yml`
2. Verifica que los nombres de volúmenes coincidan con los creados anteriormente

### 3.3 Configurar variables de entorno
En la sección "Environment Variables", agrega:

```
LMSTUDIO_API_PORT=1234
NOVNC_WEB_PORT=6080
VNC_DIRECT_PORT=5900
MEMORY_LIMIT=8G
MEMORY_RESERVATION=4G
LMSTUDIO_HOST=0.0.0.0
LMSTUDIO_MODELS_PATH=/home/lmstudio/models
LMSTUDIO_CACHE_PATH=/home/lmstudio/.cache/lm-studio
VNC_PASSWORD=lmstudio
DISPLAY=:1
AUTO_DOWNLOAD_MODELS=true
LOG_LEVEL=INFO
```

## 🌐 PASO 4: Configurar Puertos y Dominios

### 4.1 Configurar puertos
En la sección "Ports", agrega:

1. **Puerto 1234**:
   - Protocolo: HTTP
   - Descripción: "API de LM Studio"

2. **Puerto 6080**:
   - Protocolo: HTTP
   - Descripción: "Interfaz Web noVNC"

3. **Puerto 5900**:
   - Protocolo: TCP
   - Descripción: "VNC Directo"

### 4.2 Configurar dominios (opcional)
Si quieres acceso externo:

1. **Para la interfaz web**:
   - Dominio: `lmstudio.tudominio.com`
   - Puerto: 6080
   - SSL: Recomendado

2. **Para la API**:
   - Dominio: `lmstudio-api.tudominio.com`
   - Puerto: 1234
   - SSL: Recomendado

## 🚀 PASO 5: Desplegar la Aplicación

### 5.1 Iniciar despliegue
1. Revisa toda la configuración
2. Clic en "Deploy" o "Desplegar"
3. Espera a que se complete la construcción de la imagen (puede tomar 10-15 minutos)

### 5.2 Monitorear el despliegue
1. Ve a la sección "Logs" de la aplicación
2. Verifica que no hay errores
3. Busca el mensaje "✅ Script completado exitosamente"

## 📥 PASO 6: Descargar Modelos (Automático)

### 6.1 Verificar descarga automática
Los modelos se descargan automáticamente al iniciar. Puedes verificar:

1. Ve a los logs de la aplicación
2. Busca mensajes como "Descargando Llama 3.2 1B..."
3. La descarga puede tomar 30-60 minutos dependiendo de tu conexión

### 6.2 Modelos incluidos automáticamente
- **Llama 3.2 1B Instruct** (~1GB) - Muy rápido
- **Llama 3.2 3B Instruct** (~2GB) - Equilibrado
- **Phi-3 Mini 4K** (~2.5GB) - Eficiente
- **Gemma 2B Instruct** (~1.5GB) - Ligero
- **Qwen 2.5 1.5B** (~1GB) - Muy eficiente

## 🔍 PASO 7: Verificar la Instalación

### 7.1 Acceder a la interfaz web
1. Ve a `http://tu-servidor:6080` (o tu dominio configurado)
2. Deberías ver la interfaz de noVNC
3. Clic en "Connect"
4. Contraseña: `lmstudio`

### 7.2 Verificar LM Studio
1. Dentro de la interfaz, deberías ver LM Studio ejecutándose
2. Ve a la pestaña "Models" para ver los modelos descargados
3. Prueba cargar un modelo pequeño como Llama 3.2 1B

### 7.3 Probar la API
```bash
# Verificar modelos disponibles
curl http://tu-servidor:1234/v1/models

# Probar chat (después de cargar un modelo)
curl -X POST http://tu-servidor:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.2-1b-instruct",
    "messages": [{"role": "user", "content": "Hola, ¿cómo estás?"}],
    "temperature": 0.7
  }'
```

## 🔧 PASO 8: Configuración Adicional

### 8.1 Optimizar para CPU
En LM Studio (interfaz web):
1. Ve a Settings → Performance
2. Configura "CPU Threads" al número de cores disponibles
3. Desactiva "GPU Acceleration"
4. Ajusta "Context Length" según tu RAM

### 8.2 Configurar modelos
1. En la pestaña "Models", carga un modelo pequeño primero
2. Ajusta los parámetros según tu hardware:
   - **4GB RAM**: Usa modelos 1B
   - **8GB RAM**: Usa modelos 1B-3B
   - **16GB+ RAM**: Usa modelos 3B-7B

## 📊 PASO 9: Monitoreo y Mantenimiento

### 9.1 Verificar recursos
En EasyPanel:
1. Monitorea uso de CPU y RAM
2. Verifica espacio en volúmenes
3. Revisa logs regularmente

### 9.2 Backup de modelos
Los modelos están en el volumen `lmstudio_models`. Considera:
1. Backup regular del volumen
2. Documentar qué modelos tienes instalados
3. Mantener espacio libre para nuevos modelos

## 🆘 Troubleshooting Común

### Problema: Contenedor no inicia
```bash
# Verificar logs
docker logs lmstudio-app

# Verificar volúmenes
docker volume ls | grep lmstudio
```

### Problema: No se puede acceder a la interfaz
1. Verifica que el puerto 6080 esté abierto
2. Comprueba firewall del servidor
3. Revisa logs de noVNC

### Problema: Modelos no se descargan
1. Verifica conexión a internet
2. Comprueba espacio en disco
3. Revisa permisos de volúmenes

### Problema: Rendimiento lento
1. Aumenta CPU cores en EasyPanel
2. Incrementa RAM asignada
3. Usa modelos más pequeños
4. Verifica que no hay otros procesos pesados

## ✅ Verificación Final

Después de completar todos los pasos:

- [ ] Contenedor ejecutándose sin errores
- [ ] Interfaz web accesible en puerto 6080
- [ ] API respondiendo en puerto 1234
- [ ] Al menos un modelo descargado y funcional
- [ ] Logs sin errores críticos
- [ ] Recursos del sistema estables

## 🎉 ¡Listo!

Tu instalación de LM Studio está completa. Ahora puedes:

1. **Usar la interfaz web**: `http://tu-servidor:6080`
2. **Usar la API**: `http://tu-servidor:1234`
3. **Descargar más modelos** desde la interfaz
4. **Integrar con aplicaciones** usando la API REST

## 📚 Recursos Adicionales

- **Documentación de LM Studio**: https://lmstudio.ai/docs
- **Modelos recomendados**: Hugging Face GGUF models
- **API Reference**: `http://tu-servidor:1234/docs`

¡Disfruta usando LM Studio en tu servidor! 🚀