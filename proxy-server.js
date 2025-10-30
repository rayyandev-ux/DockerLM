const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 1234;
const LM_STUDIO_PORT = 41343;

// Middleware para logs
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Función para verificar si LM Studio está disponible
async function checkLMStudio() {
    try {
        const response = await fetch(`http://localhost:${LM_STUDIO_PORT}/`);
        return response.ok;
    } catch (error) {
        return false;
    }
}

// Proxy para la API OpenAI
app.use('/v1', createProxyMiddleware({
    target: `http://localhost:${LM_STUDIO_PORT}`,
    changeOrigin: true,
    timeout: 30000,
    proxyTimeout: 30000,
    onError: (err, req, res) => {
        console.error('Proxy error:', err.message);
        res.status(502).json({
            error: {
                message: 'LM Studio not available',
                type: 'proxy_error',
                code: 'lm_studio_unavailable',
                details: err.message
            }
        });
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`Proxying ${req.method} ${req.url} to LM Studio:${LM_STUDIO_PORT}`);
    },
    onProxyRes: (proxyRes, req, res) => {
        console.log(`Response from LM Studio: ${proxyRes.statusCode}`);
    }
}));

// Fallback para /v1/models si el proxy falla
app.get('/v1/models', async (req, res) => {
    console.log('Fallback: Checking LM Studio directly...');
    
    const isAvailable = await checkLMStudio();
    if (!isAvailable) {
        return res.status(502).json({
            error: {
                message: 'LM Studio server not responding',
                type: 'connection_error',
                code: 'lm_studio_down'
            }
        });
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

// Health check mejorado
app.get('/health', async (req, res) => {
    const lmStudioStatus = await checkLMStudio();
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        lm_studio_port: LM_STUDIO_PORT,
        lm_studio_available: lmStudioStatus
    });
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        message: 'LM Studio API Proxy',
        version: '1.0.0',
        endpoints: ['/v1/models', '/v1/chat/completions', '/health']
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 LM Studio API Proxy running on port ${PORT}`);
    console.log(`📡 Proxying to LM Studio on port ${LM_STUDIO_PORT}`);
    console.log(`🌐 Available at: http://0.0.0.0:${PORT}`);
    
    // Verificar LM Studio al iniciar
    setTimeout(async () => {
        const isAvailable = await checkLMStudio();
        console.log(`🔍 LM Studio status: ${isAvailable ? 'Available' : 'Not available'}`);
    }, 5000);
});