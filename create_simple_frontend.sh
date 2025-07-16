#!/bin/bash

# SAMABOT Simple Frontend Creator
# Crea un frontend básico compatible con Jetson ARM64

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                SAMABOT SIMPLE FRONTEND                       ║"
echo "║                Frontend Compatible con Jetson                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Crear directorio del frontend simple
FRONTEND_DIR="samabot-simple-frontend"
show_info "Creando frontend simple compatible con Jetson..."

# Crear estructura de directorios
mkdir -p "$FRONTEND_DIR"
mkdir -p "$FRONTEND_DIR/public"
mkdir -p "$FRONTEND_DIR/src"

# Crear package.json simple
cat > "$FRONTEND_DIR/package.json" << 'EOF'
{
  "name": "samabot-simple-frontend",
  "version": "1.0.0",
  "description": "SAMABOT Simple Frontend for Jetson",
  "main": "index.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.6.0"
  },
  "keywords": ["samabot", "plc", "industrial"],
  "author": "Ing. Sergio M",
  "license": "MIT"
}
EOF

# Crear servidor Express simple
cat > "$FRONTEND_DIR/server.js" << 'EOF'
const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// Configuración del backend
const BACKEND_URL = 'http://localhost:8000';

// Ruta principal
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API proxy para el backend
app.get('/api/status', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/status`);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Error conectando al backend' });
    }
});

app.get('/api/inputs', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/inputs`);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Error obteniendo entradas' });
    }
});

app.get('/api/outputs', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/outputs`);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Error obteniendo salidas' });
    }
});

app.post('/api/outputs/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { value } = req.body;
        const response = await axios.post(`${BACKEND_URL}/outputs/${id}`, { value });
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Error controlando salida' });
    }
});

app.post('/api/connect', async (req, res) => {
    try {
        const response = await axios.post(`${BACKEND_URL}/connect`);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Error conectando al PLC' });
    }
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 SAMABOT Simple Frontend corriendo en http://localhost:${PORT}`);
    console.log(`📡 Backend: ${BACKEND_URL}`);
    console.log(`🔧 PLC: 192.168.1.5 (Siemens S7-1200)`);
});
EOF

# Crear HTML principal
cat > "$FRONTEND_DIR/public/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SAMABOT Industrial - PLC Control</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            color: white;
        }
        
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .header p {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            transition: transform 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-5px);
        }
        
        .card h2 {
            color: #667eea;
            margin-bottom: 20px;
            font-size: 1.5rem;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 10px;
        }
        
        .status-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .status-item:last-child {
            border-bottom: none;
        }
        
        .status-label {
            font-weight: 600;
            color: #555;
        }
        
        .status-value {
            font-weight: bold;
        }
        
        .status-connected {
            color: #28a745;
        }
        
        .status-disconnected {
            color: #dc3545;
        }
        
        .button {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            margin: 5px;
        }
        
        .button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        
        .button:active {
            transform: translateY(0);
        }
        
        .button-secondary {
            background: linear-gradient(45deg, #6c757d, #495057);
        }
        
        .button-danger {
            background: linear-gradient(45deg, #dc3545, #c82333);
        }
        
        .button-success {
            background: linear-gradient(45deg, #28a745, #20c997);
        }
        
        .controls {
            text-align: center;
            margin: 20px 0;
        }
        
        .loading {
            text-align: center;
            color: #666;
            font-style: italic;
        }
        
        .error {
            color: #dc3545;
            font-weight: bold;
        }
        
        .success {
            color: #28a745;
            font-weight: bold;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .header h1 {
                font-size: 2rem;
            }
            
            .status-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏭 SAMABOT Industrial</h1>
            <p>Sistema de Monitoreo y Control PLC Siemens S7-1200</p>
        </div>
        
        <div class="controls">
            <button class="button button-success" onclick="connectPLC()">🔌 Conectar PLC</button>
            <button class="button button-secondary" onclick="refreshData()">🔄 Actualizar</button>
        </div>
        
        <div class="status-grid">
            <div class="card">
                <h2>📊 Estado del Sistema</h2>
                <div id="system-status">
                    <div class="loading">Cargando estado...</div>
                </div>
            </div>
            
            <div class="card">
                <h2>📥 Entradas Digitales</h2>
                <div id="digital-inputs">
                    <div class="loading">Cargando entradas...</div>
                </div>
            </div>
            
            <div class="card">
                <h2>📤 Salidas Digitales</h2>
                <div id="digital-outputs">
                    <div class="loading">Cargando salidas...</div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Función para conectar al PLC
        async function connectPLC() {
            try {
                const response = await fetch('/api/connect', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });
                const data = await response.json();
                
                if (response.ok) {
                    showMessage('PLC conectado exitosamente', 'success');
                    refreshData();
                } else {
                    showMessage('Error al conectar PLC: ' + data.error, 'error');
                }
            } catch (error) {
                showMessage('Error de conexión: ' + error.message, 'error');
            }
        }
        
        // Función para refrescar datos
        async function refreshData() {
            await Promise.all([
                loadSystemStatus(),
                loadDigitalInputs(),
                loadDigitalOutputs()
            ]);
        }
        
        // Cargar estado del sistema
        async function loadSystemStatus() {
            try {
                const response = await fetch('/api/status');
                const data = await response.json();
                
                const statusDiv = document.getElementById('system-status');
                statusDiv.innerHTML = `
                    <div class="status-item">
                        <span class="status-label">Conexión PLC:</span>
                        <span class="status-value ${data.connected ? 'status-connected' : 'status-disconnected'}">
                            ${data.connected ? '✅ Conectado' : '❌ Desconectado'}
                        </span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">Calidad de Conexión:</span>
                        <span class="status-value">${data.connectionQuality || 'N/A'}</span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">IP del PLC:</span>
                        <span class="status-value">${data.ip || 'N/A'}</span>
                    </div>
                    <div class="status-item">
                        <span class="status-label">Última Actualización:</span>
                        <span class="status-value">${new Date().toLocaleTimeString()}</span>
                    </div>
                `;
            } catch (error) {
                document.getElementById('system-status').innerHTML = 
                    '<div class="error">Error cargando estado del sistema</div>';
            }
        }
        
        // Cargar entradas digitales
        async function loadDigitalInputs() {
            try {
                const response = await fetch('/api/inputs');
                const data = await response.json();
                
                const inputsDiv = document.getElementById('digital-inputs');
                if (data.digital && data.digital.length > 0) {
                    let html = '';
                    data.digital.forEach((input, index) => {
                        html += `
                            <div class="status-item">
                                <span class="status-label">Entrada ${index + 1}:</span>
                                <span class="status-value ${input ? 'status-connected' : 'status-disconnected'}">
                                    ${input ? '🔴 ON' : '⚫ OFF'}
                                </span>
                            </div>
                        `;
                    });
                    inputsDiv.innerHTML = html;
                } else {
                    inputsDiv.innerHTML = '<div class="loading">No hay entradas disponibles</div>';
                }
            } catch (error) {
                document.getElementById('digital-inputs').innerHTML = 
                    '<div class="error">Error cargando entradas</div>';
            }
        }
        
        // Cargar salidas digitales
        async function loadDigitalOutputs() {
            try {
                const response = await fetch('/api/outputs');
                const data = await response.json();
                
                const outputsDiv = document.getElementById('digital-outputs');
                if (data.digital && data.digital.length > 0) {
                    let html = '';
                    data.digital.forEach((output, index) => {
                        html += `
                            <div class="status-item">
                                <span class="status-label">Salida ${index + 1}:</span>
                                <span class="status-value ${output ? 'status-connected' : 'status-disconnected'}">
                                    ${output ? '🔴 ON' : '⚫ OFF'}
                                </span>
                                <button class="button button-secondary" onclick="toggleOutput(${index})">
                                    ${output ? '🔴 Apagar' : '🟢 Encender'}
                                </button>
                            </div>
                        `;
                    });
                    outputsDiv.innerHTML = html;
                } else {
                    outputsDiv.innerHTML = '<div class="loading">No hay salidas disponibles</div>';
                }
            } catch (error) {
                document.getElementById('digital-outputs').innerHTML = 
                    '<div class="error">Error cargando salidas</div>';
            }
        }
        
        // Función para cambiar estado de salida
        async function toggleOutput(index) {
            try {
                const response = await fetch(`/api/outputs/${index}`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ value: true })
                });
                
                if (response.ok) {
                    showMessage('Salida controlada exitosamente', 'success');
                    setTimeout(loadDigitalOutputs, 500);
                } else {
                    showMessage('Error controlando salida', 'error');
                }
            } catch (error) {
                showMessage('Error de conexión: ' + error.message, 'error');
            }
        }
        
        // Función para mostrar mensajes
        function showMessage(message, type) {
            const messageDiv = document.createElement('div');
            messageDiv.textContent = message;
            messageDiv.className = type;
            messageDiv.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 15px 20px;
                border-radius: 5px;
                color: white;
                font-weight: bold;
                z-index: 1000;
                background: ${type === 'success' ? '#28a745' : '#dc3545'};
            `;
            
            document.body.appendChild(messageDiv);
            
            setTimeout(() => {
                messageDiv.remove();
            }, 3000);
        }
        
        // Cargar datos iniciales
        document.addEventListener('DOMContentLoaded', function() {
            refreshData();
            
            // Actualizar cada 5 segundos
            setInterval(refreshData, 5000);
        });
    </script>
</body>
</html>
EOF

show_status "Frontend simple creado en $FRONTEND_DIR"

# Instalar dependencias
show_info "Instalando dependencias..."
cd "$FRONTEND_DIR"
npm install

if [ $? -eq 0 ]; then
    show_status "Dependencias instaladas correctamente"
else
    show_error "Error instalando dependencias"
    exit 1
fi

cd ..

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    FRONTEND SIMPLE LISTO                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
show_status "Frontend simple creado y configurado"
show_info "Ubicación: $FRONTEND_DIR"
echo ""
show_info "Para iniciar el frontend:"
echo "   cd $FRONTEND_DIR && npm start"
echo ""
show_info "Para transferir al Jetson:"
echo "   rsync -avz $FRONTEND_DIR/ samabot@192.168.1.7:/home/samabot/SAMABOT-UI/$FRONTEND_DIR/" 