const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 1234;

// Función para detectar automáticamente el puerto de LM Studio
async function detectLMStudioPort() {
    const possiblePorts = [41343, 1234, 8080, 3000, 5000];
    
    for (const port of possiblePorts) {
        try {
            // Intentar verificar la API específicamente con /v1/models
            const response = await fetch(`http://localhost:${port}/v1/models`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' },
                signal: AbortSignal.timeout(5000) // Timeout de 5 segundos
            });
            
            if (response.ok) {
                console.log(`✅ LM Studio API detectada en puerto: ${port}`);
                return port;
            }
            
            // Si /v1/models falla, intentar con la raíz
            const rootResponse = await fetch(`http://localhost:${port}/`, {
                signal: AbortSignal.timeout(3000)
            });
            
            if (rootResponse.ok || rootResponse.status === 404) {
                console.log(`🔍 LM Studio detectado en puerto: ${port} (respuesta raíz)`);
                return port;
            }
        } catch (error) {
            console.log(`⚠️ Puerto ${port} no disponible: ${error.name}`);
            // Puerto no disponible, continuar
        }
    }
    
    console.log(`⚠️ LM Studio no detectado en puertos comunes, usando 41343 por defecto`);
    return 41343; // Puerto por defecto
}

// Variable global para el puerto de LM Studio
let LM_STUDIO_PORT = 41343;
let LM_STUDIO_READY = false;

// Middleware para logs
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Función para verificar si LM Studio está disponible
async function checkLMStudio() {
    try {
        // Intentar primero con /v1/models para verificar la API
        const apiResponse = await fetch(`http://localhost:${LM_STUDIO_PORT}/v1/models`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            signal: AbortSignal.timeout(5000) // Timeout de 5 segundos
        });
        
        if (apiResponse.ok) {
            LM_STUDIO_READY = true;
            console.log(`✅ LM Studio API respondiendo correctamente en puerto ${LM_STUDIO_PORT}`);
            return true;
        }
        
        // Si la API no responde, verificar si al menos el servidor está activo
        const rootResponse = await fetch(`http://localhost:${LM_STUDIO_PORT}/`, {
            signal: AbortSignal.timeout(3000)
        });
        
        if (rootResponse.ok || rootResponse.status === 404) {
            console.log(`⚠️ LM Studio detectado en puerto ${LM_STUDIO_PORT} pero API no responde`);
            return true; // El servidor está activo pero la API podría no estar lista
        }
        
        return false;
    } catch (error) {
        console.log(`❌ Error al verificar LM Studio: ${error.name}`);
        return false;
    }
}

// Proxy dinámico para la API OpenAI
app.use('/v1', createProxyMiddleware({
    target: () => `http://localhost:${LM_STUDIO_PORT}`,
    changeOrigin: true,
    timeout: 30000,
    proxyTimeout: 30000,
    onError: (err, req, res) => {
        console.error(`❌ Proxy error (puerto ${LM_STUDIO_PORT}):`, err.message);
        res.status(502).json({
            error: {
                message: 'LM Studio not available',
                type: 'proxy_error',
                code: 'lm_studio_unavailable',
                details: err.message,
                lm_studio_port: LM_STUDIO_PORT
            }
        });
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`📡 Proxying ${req.method} ${req.url} to LM Studio:${LM_STUDIO_PORT}`);
    },
    onProxyRes: (proxyRes, req, res) => {
        console.log(`✅ Response from LM Studio: ${proxyRes.statusCode}`);
    }
}));

// Función para verificar la API de LM Studio con reintentos
async function verifyLMStudioAPI(maxRetries = 3, retryDelay = 2000) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            console.log(`🔄 Intento ${i+1}/${maxRetries} de verificar API en puerto ${LM_STUDIO_PORT}`);
            
            const response = await fetch(`http://localhost:${LM_STUDIO_PORT}/v1/models`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' },
                signal: AbortSignal.timeout(5000)
            });
            
            if (response.ok) {
                console.log(`✅ API verificada correctamente en intento ${i+1}`);
                return { success: true, data: await response.json() };
            } else {
                console.log(`⚠️ API respondió con estado ${response.status} en intento ${i+1}`);
            }
        } catch (error) {
            console.log(`⚠️ Error en intento ${i+1}: ${error.name}`);
        }
        
        if (i < maxRetries - 1) {
            console.log(`⏳ Esperando ${retryDelay}ms antes del siguiente intento...`);
            await new Promise(resolve => setTimeout(resolve, retryDelay));
        }
    }
    
    return { success: false };
}

// Fallback inteligente para /v1/models
app.get('/v1/models', async (req, res) => {
    console.log('🔄 Fallback: Verificando LM Studio directamente...');
    
    // Verificar con reintentos
    const apiCheck = await verifyLMStudioAPI(3, 2000);
    
    if (apiCheck.success) {
        // Si tenemos datos reales de la API, devolverlos
        console.log('✅ Usando datos reales de modelos de LM Studio');
        return res.json(apiCheck.data);
    }
    
    // Si no hay respuesta, intentar re-detectar el puerto
    console.log('🔍 Re-detectando puerto de LM Studio...');
    const newPort = await detectLMStudioPort();
    
    if (newPort !== LM_STUDIO_PORT) {
        LM_STUDIO_PORT = newPort;
        console.log(`🔄 Puerto actualizado a: ${LM_STUDIO_PORT}`);
        
        // Verificar nuevamente con el nuevo puerto
        const retryCheck = await verifyLMStudioAPI(2, 1000);
        if (retryCheck.success) {
            console.log('✅ Usando datos reales de modelos después de re-detección');
            return res.json(retryCheck.data);
        }
    }
    
    // Si todo falla, devolver respuesta mock
    console.log('⚠️ Usando respuesta mock para /v1/models');
    res.json({
        object: "list",
        data: [
            {
                id: "lmstudio-local-model",
                object: "model",
                created: Math.floor(Date.now() / 1000),
                owned_by: "lmstudio",
                description: "Local model running on LM Studio"
            }
        ],
        proxy_info: {
            message: "Fallback response - LM Studio API not fully available",
            port_attempted: LM_STUDIO_PORT
        }
    });
});

// Health check mejorado con detección automática
app.get('/health', async (req, res) => {
    // Verificar estado actual
    const lmStudioStatus = await checkLMStudio();
    let apiStatus = false;
    
    if (lmStudioStatus) {
        // Verificar específicamente la API
        const apiCheck = await verifyLMStudioAPI(1, 0);
        apiStatus = apiCheck.success;
    }
    
    if (!lmStudioStatus) {
        // Intentar re-detectar puerto
        console.log('🔍 Re-detectando puerto en health check...');
        const newPort = await detectLMStudioPort();
        if (newPort !== LM_STUDIO_PORT) {
            LM_STUDIO_PORT = newPort;
            console.log(`🔄 Puerto actualizado a: ${LM_STUDIO_PORT}`);
        }
    }
    
    // Verificación final
    const finalStatus = await checkLMStudio();
    
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        lm_studio_port: LM_STUDIO_PORT,
        lm_studio_available: finalStatus,
        lm_studio_api_ready: apiStatus,
        proxy_version: '3.0.0',
        last_detection_time: new Date().toISOString()
    });
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        message: 'LM Studio API Proxy',
        version: '2.0.0',
        features: ['auto-port-detection', 'intelligent-fallback', 'health-monitoring'],
        endpoints: ['/v1/models', '/v1/chat/completions', '/health'],
        lm_studio_port: LM_STUDIO_PORT
    });
});

// Inicializar servidor
async function startServer() {
    // Detectar puerto de LM Studio al iniciar
    console.log('🔍 Detectando puerto de LM Studio...');
    LM_STUDIO_PORT = await detectLMStudioPort();
    
    // Verificar API inmediatamente
    const initialApiCheck = await verifyLMStudioAPI(2, 3000);
    if (initialApiCheck.success) {
        LM_STUDIO_READY = true;
        console.log('✅ API de LM Studio verificada correctamente al inicio');
    } else {
        console.log('⚠️ API de LM Studio no disponible al inicio, continuando con monitoreo');
    }
    
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`🚀 LM Studio API Proxy v3.0 running on port ${PORT}`);
        console.log(`📡 Auto-detected LM Studio on port ${LM_STUDIO_PORT}`);
        console.log(`🌐 Available at: http://0.0.0.0:${PORT}`);
        console.log(`🔍 Health check: http://0.0.0.0:${PORT}/health`);
        
        // Verificar LM Studio periódicamente con intervalo más corto
        setInterval(async () => {
            const isAvailable = await checkLMStudio();
            if (!isAvailable) {
                console.log(`⚠️ LM Studio no disponible en puerto ${LM_STUDIO_PORT}, re-detectando...`);
                const newPort = await detectLMStudioPort();
                if (newPort !== LM_STUDIO_PORT) {
                    LM_STUDIO_PORT = newPort;
                    console.log(`🔄 Puerto actualizado a: ${LM_STUDIO_PORT}`);
                }
            } else {
                // Si está disponible pero la API no estaba lista, verificar API
                if (!LM_STUDIO_READY) {
                    const apiCheck = await verifyLMStudioAPI(1, 0);
                    if (apiCheck.success) {
                        LM_STUDIO_READY = true;
                        console.log('✅ API de LM Studio ahora está disponible');
                    }
                }
            }
        }, 15000); // Verificar cada 15 segundos
    });
}

startServer();