# Guía de Contribución

¡Gracias por tu interés en contribuir a LM Studio Docker EasyPanel! 🎉

## 🤝 Cómo Contribuir

### Reportar Bugs
1. Verifica que el bug no haya sido reportado anteriormente
2. Crea un nuevo issue con:
   - Descripción clara del problema
   - Pasos para reproducir
   - Comportamiento esperado vs actual
   - Información del sistema (OS, Docker version, etc.)
   - Logs relevantes

### Sugerir Mejoras
1. Abre un issue describiendo:
   - La mejora propuesta
   - Justificación y casos de uso
   - Posible implementación

### Contribuir Código

#### Configuración del Entorno de Desarrollo
```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/lmstudio-docker-easypanel.git
cd lmstudio-docker-easypanel

# Crear rama para tu feature
git checkout -b feature/nueva-funcionalidad

# Hacer cambios y commits
git add .
git commit -m "feat: descripción de la nueva funcionalidad"

# Push y crear Pull Request
git push origin feature/nueva-funcionalidad
```

#### Estándares de Código

##### Dockerfile
- Usar imágenes base oficiales
- Minimizar capas de imagen
- Documentar cada sección importante
- Seguir mejores prácticas de seguridad

##### Scripts de Shell
- Usar `#!/bin/bash` como shebang
- Validar variables antes de usar
- Manejar errores apropiadamente
- Documentar funciones complejas

##### Docker Compose
- Usar versión 3.8+
- Documentar servicios y volúmenes
- Configurar healthchecks
- Usar variables de entorno

#### Convenciones de Commits
Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Cambios de formato (no afectan funcionalidad)
- `refactor:` Refactorización de código
- `test:` Agregar o modificar tests
- `chore:` Tareas de mantenimiento

Ejemplos:
```
feat: agregar soporte para modelos Mistral
fix: corregir descarga de modelos en redes lentas
docs: actualizar guía de instalación para EasyPanel v2
```

#### Pull Requests
1. **Título descriptivo**: Usa conventional commits
2. **Descripción detallada**:
   - Qué cambios incluye
   - Por qué son necesarios
   - Cómo probar los cambios
3. **Tests**: Asegúrate de que todo funciona
4. **Documentación**: Actualiza docs si es necesario

### Testing

#### Pruebas Locales
```bash
# Construir imagen
docker build -t lmstudio-test .

# Probar con docker-compose
docker-compose -f docker-compose.yml up --build

# Verificar servicios
curl http://localhost:1234/v1/models
curl http://localhost:6080
```

#### Checklist de Testing
- [ ] Imagen se construye sin errores
- [ ] Contenedor inicia correctamente
- [ ] Servicios responden en puertos esperados
- [ ] Volúmenes se montan correctamente
- [ ] Modelos se descargan automáticamente
- [ ] API funciona correctamente
- [ ] Interfaz web es accesible
- [ ] Logs no muestran errores críticos

## 📋 Áreas de Contribución

### Prioridad Alta
- Optimizaciones de rendimiento para CPU
- Soporte para más modelos populares
- Mejoras en la documentación
- Corrección de bugs reportados

### Prioridad Media
- Soporte para diferentes arquitecturas (ARM64)
- Integración con más plataformas de despliegue
- Mejoras en la interfaz de usuario
- Automatización de tests

### Prioridad Baja
- Temas y personalización de UI
- Integraciones adicionales
- Herramientas de desarrollo

## 🐛 Reportar Problemas

### Información Requerida
```
**Descripción del Problema:**
[Descripción clara y concisa]

**Pasos para Reproducir:**
1. 
2. 
3. 

**Comportamiento Esperado:**
[Qué esperabas que pasara]

**Comportamiento Actual:**
[Qué pasó realmente]

**Información del Sistema:**
- OS: [ej. Ubuntu 24.04]
- Docker Version: [ej. 24.0.7]
- EasyPanel Version: [ej. 1.2.3]
- RAM: [ej. 16GB]
- CPU: [ej. 8 cores]

**Logs:**
```
[Incluir logs relevantes]
```

**Capturas de Pantalla:**
[Si aplica]
```

## 🎯 Roadmap

### v1.1.0
- [ ] Soporte para ARM64
- [ ] Más modelos preconfigurados
- [ ] Mejoras en la documentación

### v1.2.0
- [ ] Interfaz web mejorada
- [ ] Configuración automática de recursos
- [ ] Soporte para GPU (opcional)

### v2.0.0
- [ ] Arquitectura multi-contenedor
- [ ] Dashboard de administración
- [ ] Métricas y monitoreo avanzado

## 📞 Contacto

- **Issues**: [GitHub Issues](https://github.com/tu-usuario/lmstudio-docker-easypanel/issues)
- **Discussions**: [GitHub Discussions](https://github.com/tu-usuario/lmstudio-docker-easypanel/discussions)

## 📄 Licencia

Al contribuir, aceptas que tus contribuciones serán licenciadas bajo la misma licencia MIT del proyecto.

---

¡Gracias por hacer este proyecto mejor! 🚀