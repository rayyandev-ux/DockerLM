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

// Proxy para la API OpenAI
app.use('/v1', createProxyMiddleware({
    target: `http://localhost:${LM_STUDIO_PORT}`,
    changeOrigin: true,
    pathRewrite: {
        '^/v1/models': '/v1/models',
        '^/v1/chat/completions': '/v1/chat/completions',
        '^/v1/completions': '/v1/completions'
    },
    onError: (err, req, res) => {
        console.error('Proxy error:', err.message);
        res.status(502).json({
            error: {
                message: 'LM Studio not available',
                type: 'proxy_error',
                code: 'lm_studio_unavailable'
            }
        });
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`Proxying ${req.method} ${req.url} to LM Studio`);
    }
}));

// Fallback para rutas no encontradas
app.get('/v1/models', (req, res) => {
    // Si el proxy falla, devolver respuesta mock
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

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        lm_studio_port: LM_STUDIO_PORT
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
});