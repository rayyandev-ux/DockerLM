const express = require('express');
const http = require('http');

const app = express();
const PORT = 1234;
const LM_STUDIO_PORT = 41343;

// Middleware esencial
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Middleware para logs
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Función para hacer petición a LM Studio
function proxyToLMStudio(path, method = 'GET', body = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: '127.0.0.1',
            port: LM_STUDIO_PORT,
            path: path,
            method: method,
            headers: {
                'Content-Type': 'application/json'
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                try {
                    const jsonData = JSON.parse(data);
                    resolve({ success: true, data: jsonData, status: res.statusCode });
                } catch (e) {
                    resolve({ success: true, data: data, status: res.statusCode });
                }
            });
        });

        req.on('error', (err) => {
            reject(err);
        });

        if (body) {
            req.write(JSON.stringify(body));
        }
        req.end();
    });
}

// Endpoint de prueba simple
app.get('/test', (req, res) => {
    res.json({
        message: 'Test endpoint working',
        version: '4.2.0',
        timestamp: new Date().toISOString()
    });
});

// Endpoint de prueba para /v1
app.get('/v1/test', (req, res) => {
    res.json({
        message: 'V1 test endpoint working',
        version: '4.2.0',
        timestamp: new Date().toISOString()
    });
});

// Endpoint directo para /v1/models (versión simplificada para debug)
app.get('/v1/models', (req, res) => {
    console.log('📡 Handling /v1/models request - SIMPLE VERSION');
    
    // Respuesta simple sin async/await para probar
    res.json({
        object: "list",
        data: [
            {
                id: "lmstudio-model-simple",
                object: "model",
                created: Math.floor(Date.now() / 1000),
                owned_by: "lmstudio"
            }
        ],
        debug: {
            message: "Simple version working",
            version: "4.3.0"
        }
    });
});

// Endpoint directo para /v1/chat/completions
app.post('/v1/chat/completions', async (req, res) => {
    console.log('📡 Handling /v1/chat/completions request');
    
    try {
        const result = await proxyToLMStudio('/v1/chat/completions', 'POST', req.body);
        if (result.success) {
            console.log('✅ Got response from LM Studio');
            res.status(result.status).json(result.data);
        } else {
            throw new Error('LM Studio not responding');
        }
    } catch (error) {
        console.log('⚠️ LM Studio not available for chat');
        res.status(503).json({
            error: {
                message: "LM Studio is starting up, please wait...",
                type: "service_unavailable"
            }
        });
    }
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

// Health check simple
app.get('/health', async (req, res) => {
    const isAvailable = await checkLMStudio();
    res.json({
        status: 'ok',
        lm_studio_available: isAvailable,
        lm_studio_port: LM_STUDIO_PORT,
        proxy_version: '4.4.0',
        timestamp: new Date().toISOString()
    });
});

// Endpoint raíz
app.get('/', (req, res) => {
    res.json({
        message: 'LM Studio API Proxy',
        version: '4.4.0',
        status: 'running',
        endpoints: ['/v1/models', '/v1/chat/completions', '/health', '/test', '/v1/test']
    });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 LM Studio API Proxy v4.3 running on port ${PORT}`);
    console.log(`📡 Direct proxy to LM Studio on port ${LM_STUDIO_PORT}`);
    console.log(`🌐 Available at: http://0.0.0.0:${PORT}`);
    console.log(`🔍 Health check: http://0.0.0.0:${PORT}/health`);
    console.log(`🧪 Test endpoint: http://0.0.0.0:${PORT}/test`);
    console.log(`🧪 V1 Test endpoint: http://0.0.0.0:${PORT}/v1/test`);
});