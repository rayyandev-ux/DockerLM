# 🤖 LM Studio Docker para EasyPanel

Configuración completa de LM Studio en Docker optimizada para CPU y EasyPanel.

## 📋 Descripción

Este proyecto proporciona una configuración completa para ejecutar LM Studio en un contenedor Docker, optimizado para funcionar solo con CPU en Ubuntu 24.04 y desplegado a través de EasyPanel.

## 🚀 Características

- ✅ **Optimizado para CPU**: Sin dependencias de GPU
- ✅ **Interfaz Web**: Acceso a través de noVNC en el navegador
- ✅ **API REST**: Compatible con OpenAI API
- ✅ **Descarga automática**: Modelos populares se descargan automáticamente
- ✅ **EasyPanel Ready**: Configuración específica para EasyPanel
- ✅ **Volúmenes persistentes**: Modelos y configuración se mantienen
- ✅ **Monitoreo**: Logs y healthchecks incluidos

## 📁 Archivos Incluidos

- `Dockerfile` - Imagen Docker optimizada para CPU
- `docker-compose.yml` - Configuración de servicios y volúmenes
- `supervisord.conf` - Gestión de procesos internos
- `start.sh` - Script de inicio del contenedor
- `download-models.sh` - Descarga automática de modelos
- `.env` - Variables de entorno configurables
- `EASYPANEL-SETUP.md` - Configuración específica de EasyPanel
- `INSTRUCCIONES-PASO-A-PASO.md` - Guía completa de instalación

## 🔧 Requisitos del Sistema

### Mínimos
- **CPU**: 4 cores
- **RAM**: 8GB
- **Almacenamiento**: 100GB
- **OS**: Ubuntu 24.04

### Recomendados
- **CPU**: 8+ cores
- **RAM**: 16GB+
- **Almacenamiento**: 200GB+
- **Red**: Conexión estable para descarga de modelos

## 🚀 Inicio Rápido

### 1. Preparar archivos
```bash
git clone <este-repositorio>
cd DockerLM
chmod +x start.sh download-models.sh
```

### 2. Crear volúmenes en EasyPanel
- `lmstudio_models` (100GB)
- `lmstudio_cache` (20GB)  
- `lmstudio_logs` (5GB)

### 3. Desplegar en EasyPanel
1. Crear nueva aplicación Docker Compose
2. Copiar contenido de `docker-compose.yml`
3. Configurar variables de entorno desde `.env`
4. Configurar puertos: 1234, 6080, 5900
5. Desplegar

### 4. Acceder
- **Interfaz Web**: `http://tu-servidor:6080`
- **API**: `http://tu-servidor:1234`
- **Contraseña VNC**: `lmstudio`

## 📊 Puertos Expuestos

| Puerto | Servicio | Descripción |
|--------|----------|-------------|
| 1234 | LM Studio API | API REST compatible con OpenAI |
| 6080 | noVNC Web | Interfaz web para acceso remoto |
| 5900 | VNC Directo | Conexión VNC directa |

## 🗂️ Volúmenes

| Volumen | Ruta | Propósito |
|---------|------|-----------|
| `lmstudio_models` | `/home/lmstudio/models` | Modelos de IA descargados |
| `lmstudio_cache` | `/home/lmstudio/.cache/lm-studio` | Cache de LM Studio |
| `lmstudio_logs` | `/home/lmstudio/logs` | Archivos de log |

## 🤖 Modelos Incluidos

Se descargan automáticamente al iniciar:

- **Llama 3.2 1B Instruct** (~1GB) - Muy rápido
- **Llama 3.2 3B Instruct** (~2GB) - Equilibrado  
- **Phi-3 Mini 4K** (~2.5GB) - Eficiente para CPU
- **Gemma 2B Instruct** (~1.5GB) - Ligero de Google
- **Qwen 2.5 1.5B** (~1GB) - Muy eficiente

## 🔧 Configuración

### Variables de Entorno Principales
```env
LMSTUDIO_API_PORT=1234
NOVNC_WEB_PORT=6080
VNC_DIRECT_PORT=5900
MEMORY_LIMIT=8G
LMSTUDIO_HOST=0.0.0.0
AUTO_DOWNLOAD_MODELS=true
```

### Optimización para CPU
- Configuración automática para uso exclusivo de CPU
- Sin dependencias de CUDA o GPU
- Optimizado para modelos cuantizados (GGUF)

## 📖 Documentación Detallada

- **[Configuración EasyPanel](EASYPANEL-SETUP.md)** - Configuración específica de volúmenes y aplicación
- **[Instrucciones Paso a Paso](INSTRUCCIONES-PASO-A-PASO.md)** - Guía completa de instalación
- **[Variables de Entorno](.env)** - Configuración personalizable

## 🔍 API Usage

### Listar modelos disponibles
```bash
curl http://localhost:1234/v1/models
```

### Chat completion
```bash
curl -X POST http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.2-1b-instruct",
    "messages": [{"role": "user", "content": "Hola"}],
    "temperature": 0.7
  }'
```

## 🆘 Troubleshooting

### Contenedor no inicia
```bash
docker logs lmstudio-app
```

### Verificar volúmenes
```bash
docker volume ls | grep lmstudio
```

### Verificar recursos
- Monitorea CPU y RAM en EasyPanel
- Verifica espacio en disco disponible
- Revisa logs de la aplicación

## 🔒 Seguridad

- Cambia la contraseña VNC por defecto
- Configura firewall apropiadamente
- Usa HTTPS para acceso externo
- Considera autenticación adicional para producción

## 📝 Notas Importantes

- ⚠️ **Solo CPU**: Esta configuración NO usa GPU
- ⚠️ **Descarga automática**: Los modelos se descargan al iniciar (puede tomar tiempo)
- ⚠️ **Recursos**: Asegúrate de tener suficiente RAM y CPU
- ⚠️ **Volúmenes**: DEBEN crearse manualmente en EasyPanel antes del despliegue

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 🙏 Agradecimientos

- [LM Studio](https://lmstudio.ai/) por la excelente aplicación
- [EasyPanel](https://easypanel.io/) por la plataforma de despliegue
- Comunidad de modelos de Hugging Face

---

**¿Necesitas ayuda?** Revisa las [Instrucciones Paso a Paso](INSTRUCCIONES-PASO-A-PASO.md) o abre un issue.