# Configuración de LM Studio en EasyPanel

## 📋 Volúmenes que DEBES crear manualmente en EasyPanel

Antes de desplegar la aplicación, debes crear estos volúmenes en EasyPanel:

### 1. Volumen para Modelos
- **Nombre**: `lmstudio_models`
- **Tipo**: Volume
- **Descripción**: Almacena los modelos de IA descargados
- **Tamaño recomendado**: 50GB - 100GB (dependiendo de los modelos)

### 2. Volumen para Cache
- **Nombre**: `lmstudio_cache`
- **Tipo**: Volume  
- **Descripción**: Cache de LM Studio para mejor rendimiento
- **Tamaño recomendado**: 10GB - 20GB

### 3. Volumen para Logs
- **Nombre**: `lmstudio_logs`
- **Tipo**: Volume
- **Descripción**: Archivos de log de la aplicación
- **Tamaño recomendado**: 5GB

## 🔧 Configuración de la Aplicación en EasyPanel

### Paso 1: Crear Nueva Aplicación
1. Ve a EasyPanel Dashboard
2. Clic en "Create Application"
3. Selecciona "Docker Compose"
4. Nombre: `lmstudio`

### Paso 2: Configurar Docker Compose
Copia y pega el contenido del archivo `docker-compose.yml` en el editor de EasyPanel.

### Paso 3: Configurar Variables de Entorno
En la sección de Environment Variables, agrega:

```
LMSTUDIO_API_PORT=1234
NOVNC_WEB_PORT=6080
VNC_DIRECT_PORT=5900
MEMORY_LIMIT=8G
MEMORY_RESERVATION=4G
LMSTUDIO_HOST=0.0.0.0
VNC_PASSWORD=lmstudio
DISPLAY=:1
AUTO_DOWNLOAD_MODELS=true
LOG_LEVEL=INFO
```

### Paso 4: Configurar Puertos
En la sección de Ports, configura:

- **Puerto 1234**: API de LM Studio (HTTP)
- **Puerto 6080**: Interfaz Web noVNC (HTTP)
- **Puerto 5900**: VNC Directo (TCP)

### Paso 5: Configurar Dominios (Opcional)
Si quieres acceso externo:

1. **Para la API (Puerto 1234)**:
   - Dominio: `lmstudio-api.tudominio.com`
   - Puerto: 1234

2. **Para la Interfaz Web (Puerto 6080)**:
   - Dominio: `lmstudio.tudominio.com`
   - Puerto: 6080

## 🚀 Recursos Recomendados

### CPU
- **Mínimo**: 4 cores
- **Recomendado**: 8+ cores
- **Óptimo**: 16+ cores

### RAM
- **Mínimo**: 8GB
- **Recomendado**: 16GB
- **Óptimo**: 32GB+

### Almacenamiento
- **Sistema**: 20GB
- **Modelos**: 50-100GB
- **Cache**: 10-20GB
- **Logs**: 5GB

## 🔒 Configuración de Seguridad

### Variables de Entorno Sensibles
- Cambia `VNC_PASSWORD` por una contraseña segura
- Considera usar secrets de EasyPanel para datos sensibles

### Acceso de Red
- Configura firewall si es necesario
- Usa HTTPS para acceso externo
- Considera autenticación adicional para producción

## 📊 Monitoreo y Logs

### Acceso a Logs
Los logs se almacenan en el volumen `lmstudio_logs`:
- `/home/lmstudio/logs/lmstudio.log` - Logs de LM Studio
- `/home/lmstudio/logs/xvfb.log` - Logs del servidor X
- `/home/lmstudio/logs/novnc.log` - Logs de noVNC

### Healthcheck
La aplicación incluye un healthcheck que verifica:
- API de LM Studio responde en puerto 1234
- Intervalo: cada 30 segundos
- Timeout: 10 segundos

## 🔧 Troubleshooting

### Problema: Contenedor no inicia
1. Verifica que los volúmenes estén creados
2. Revisa los logs en EasyPanel
3. Verifica recursos disponibles (CPU/RAM)

### Problema: No se puede acceder a la interfaz web
1. Verifica que el puerto 6080 esté expuesto
2. Comprueba el estado del servicio noVNC en los logs
3. Verifica configuración de firewall

### Problema: Modelos no se descargan
1. Verifica conexión a internet del contenedor
2. Revisa permisos del volumen de modelos
3. Comprueba espacio disponible en el volumen

### Problema: Rendimiento lento
1. Aumenta recursos de CPU
2. Incrementa memoria RAM
3. Verifica que no hay otros procesos consumiendo recursos
4. Considera usar modelos más pequeños (1B-3B parámetros)

## 📱 Acceso a la Aplicación

Una vez desplegada:

### Interfaz Web (noVNC)
- URL: `http://tu-servidor:6080`
- Usuario: No requerido
- Contraseña VNC: `lmstudio` (o la que configuraste)

### API REST
- URL: `http://tu-servidor:1234`
- Documentación: `http://tu-servidor:1234/docs`
- Modelos disponibles: `http://tu-servidor:1234/v1/models`

### VNC Directo
- Host: `tu-servidor`
- Puerto: `5900`
- Contraseña: `lmstudio` (o la que configuraste)