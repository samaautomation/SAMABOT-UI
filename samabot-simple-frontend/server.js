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
