# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Agregado
- Configuración inicial de LM Studio para Docker
- Dockerfile optimizado para CPU con Ubuntu 24.04
- Docker Compose con configuración de volúmenes para EasyPanel
- Script de descarga automática de modelos populares
- Interfaz web noVNC para acceso remoto
- API REST compatible con OpenAI
- Documentación completa paso a paso
- Configuración de supervisor para gestión de procesos
- Variables de entorno configurables
- Healthcheck para monitoreo del contenedor
- Soporte para modelos GGUF cuantizados
- Configuración de seguridad básica

### Modelos Incluidos
- Llama 3.2 1B Instruct (Q4_K_M)
- Llama 3.2 3B Instruct (Q4_K_M)
- Phi-3 Mini 4K Instruct (Q4)
- Gemma 2B Instruct (Q4_K_M)
- Qwen 2.5 1.5B Instruct (Q4_K_M)

### Características
- Optimización exclusiva para CPU
- Descarga automática de modelos al iniciar
- Volúmenes persistentes para modelos y cache
- Interfaz web accesible en puerto 6080
- API REST en puerto 1234
- VNC directo en puerto 5900
- Logs centralizados y monitoreables
- Configuración específica para EasyPanel

### Documentación
- README.md con información general
- INSTRUCCIONES-PASO-A-PASO.md con guía completa
- EASYPANEL-SETUP.md con configuración específica
- Ejemplos de uso de API
- Troubleshooting común
- Configuración de recursos recomendados