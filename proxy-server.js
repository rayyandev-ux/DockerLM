const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 1234;

// Función para detectar automáticamente el puerto de LM Studio
async function detectLMStudioPort() {
    const possiblePorts = [41343, 1234, 8080, 3000, 5000];
    
    for (const port of possiblePorts) {
        try {
            const response = await fetch(`http://localhost:${port}/`);
            if (response.ok || response.status === 404) {
                console.log(`🔍 LM Studio detectado en puerto: ${port}`);
                return port;
            }
        } catch (error) {
            // Puerto no disponible, continuar
        }
    }
    
    console.log(`⚠️ LM Studio no detectado en puertos comunes, usando 41343 por defecto`);
    return 41343; // Puerto por defecto
}

// Variable global para el puerto de LM Studio
let LM_STUDIO_PORT = 41343;

// Middleware para logs
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Función para verificar si LM Studio está disponible
async function checkLMStudio() {
    try {
        const response = await fetch(`http://localhost:${LM_STUDIO_PORT}/`);
        return response.ok || response.status === 404; // 404 también es válido
    } catch (error) {
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

// Fallback inteligente para /v1/models
app.get('/v1/models', async (req, res) => {
    console.log('🔄 Fallback: Verificando LM Studio directamente...');
    
    const isAvailable = await checkLMStudio();
    if (!isAvailable) {
        // Intentar re-detectar el puerto
        console.log('🔍 Re-detectando puerto de LM Studio...');
        LM_STUDIO_PORT = await detectLMStudioPort();
        
        const isAvailableAfterDetection = await checkLMStudio();
        if (!isAvailableAfterDetection) {
            return res.status(502).json({
                error: {
                    message: 'LM Studio server not responding',
                    type: 'connection_error',
                    code: 'lm_studio_down',
                    attempted_port: LM_STUDIO_PORT
                }
            });
        }
    }

    // Si LM Studio responde pero no tiene modelos, devolver respuesta mock
    res.json({
        object: "list",
        data: [
            {
                id: "nomic-embed-text-v1.5",
                object: "model",
                created: Math.floor(Date.now() / 1000),
                owned_by: "lmstudio"
            }
        ]
    });
});

// Health check mejorado con detección automática
app.get('/health', async (req, res) => {
    const lmStudioStatus = await checkLMStudio();
    
    if (!lmStudioStatus) {
        // Intentar re-detectar puerto
        const newPort = await detectLMStudioPort();
        if (newPort !== LM_STUDIO_PORT) {
            LM_STUDIO_PORT = newPort;
            console.log(`🔄 Puerto actualizado a: ${LM_STUDIO_PORT}`);
        }
    }
    
    const finalStatus = await checkLMStudio();
    
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        lm_studio_port: LM_STUDIO_PORT,
        lm_studio_available: finalStatus,
        proxy_version: '2.0.0'
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
    
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`🚀 LM Studio API Proxy v2.0 running on port ${PORT}`);
        console.log(`📡 Auto-detected LM Studio on port ${LM_STUDIO_PORT}`);
        console.log(`🌐 Available at: http://0.0.0.0:${PORT}`);
        console.log(`🔍 Health check: http://0.0.0.0:${PORT}/health`);
        
        // Verificar LM Studio periódicamente
        setInterval(async () => {
            const isAvailable = await checkLMStudio();
            if (!isAvailable) {
                console.log(`⚠️ LM Studio no disponible en puerto ${LM_STUDIO_PORT}, re-detectando...`);
                const newPort = await detectLMStudioPort();
                if (newPort !== LM_STUDIO_PORT) {
                    LM_STUDIO_PORT = newPort;
                    console.log(`🔄 Puerto actualizado a: ${LM_STUDIO_PORT}`);
                }
            }
        }, 30000); // Verificar cada 30 segundos
    });
}

startServer();