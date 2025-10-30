const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const http = require('http');

const app = express();
const PORT = 1234;
const LM_STUDIO_PORT = 41343;

// Middleware para logs
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Función simple para verificar si LM Studio está disponible
async function checkLMStudio() {
    return new Promise((resolve) => {
        const req = http.request({
            hostname: '127.0.0.1',
            port: LM_STUDIO_PORT,
            path: '/',
            method: 'GET',
            timeout: 3000
        }, (res) => {
            resolve(true);
        });
        
        req.on('error', () => resolve(false));
        req.on('timeout', () => {
            req.destroy();
            resolve(false);
        });
        
        req.end();
    });
}

// Proxy simple para todas las rutas /v1
app.use('/v1', createProxyMiddleware({
    target: `http://127.0.0.1:${LM_STUDIO_PORT}`,
    changeOrigin: true,
    timeout: 10000,
    onError: (err, req, res) => {
        console.log(`❌ Proxy error: ${err.message}`);
        
        // Respuesta simple cuando LM Studio no está disponible
        if (req.url === '/models') {
            res.json({
                object: "list",
                data: [
                    {
                        id: "lmstudio-model",
                        object: "model",
                        created: Math.floor(Date.now() / 1000),
                        owned_by: "lmstudio"
                    }
                ]
            });
        } else {
            res.status(503).json({
                error: {
                    message: "LM Studio is starting up, please wait...",
                    type: "service_unavailable"
                }
            });
        }
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`📡 Proxying to LM Studio: ${req.method} ${req.url}`);
    }
}));

// Health check simple
app.get('/health', async (req, res) => {
    const isAvailable = await checkLMStudio();
    res.json({
        status: 'ok',
        lm_studio_available: isAvailable,
        lm_studio_port: LM_STUDIO_PORT,
        proxy_version: '4.0.0',
        timestamp: new Date().toISOString()
    });
});

// Endpoint raíz
app.get('/', (req, res) => {
    res.json({
        message: 'LM Studio API Proxy',
        version: '4.0.0',
        status: 'running',
        endpoints: ['/v1/models', '/v1/chat/completions', '/health']
    });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 LM Studio API Proxy v4.0 running on port ${PORT}`);
    console.log(`📡 Proxying to LM Studio on port ${LM_STUDIO_PORT}`);
    console.log(`🌐 Available at: http://0.0.0.0:${PORT}`);
    console.log(`🔍 Health check: http://0.0.0.0:${PORT}/health`);
});