# SAMABOT PLC Backend

Backend REST para comunicación con PLC Siemens S7-1200 usando Snap7.

## 🚀 Características

- **Comunicación PLC**: Cliente Snap7 para Siemens S7-1200
- **API REST**: FastAPI con endpoints para I/O y alarmas
- **Reconexión automática**: Con delay exponencial
- **Sistema de alarmas**: Monitoreo de temperatura y presión
- **Health checks**: Verificación de salud de conexión
- **Tests completos**: Cobertura de tests con pytest

## 📋 Requisitos

- Python 3.8+
- libsnap7 (instalado en Jetson Nano)
- FastAPI y dependencias

## 🔧 Instalación

### 1. Instalar dependencias

```bash
cd backend
pip install -r requirements.txt
```

### 2. Verificar instalación

```bash
python test_backend.py
```

### 3. Ejecutar tests

```bash
pytest tests/ -v -m plc
```

## 🏗️ Estructura del Proyecto

```
backend/
├── snap7/
│   ├── __init__.py
│   ├── plc_client.py      # Cliente PLC con reconexión
│   └── snap7_backend.py   # API REST FastAPI
├── tests/
│   ├── conftest.py        # Configuración pytest
│   ├── test_api_status.py # Tests endpoint /status
│   └── test_write_output.py # Tests endpoint /output
├── requirements.txt        # Dependencias Python
├── test_backend.py        # Script de prueba
└── README.md             # Esta documentación
```

## 🔌 Endpoints de la API

### GET `/`
Información básica de la API.

### POST `/connect`
Conectar al PLC Siemens.

### POST `/disconnect`
Desconectar del PLC Siemens.

### GET `/status`
Obtener estado completo del sistema:
- Calidad de conexión
- Entradas digitales (I0-I13)
- Salidas digitales (Q0-Q9)
- Entradas analógicas (AI0-AI1)
- Alarmas activas

### POST `/output`
Escribir salida digital:
```json
{
  "output_name": "Q0",
  "value": true
}
```

### GET `/healthz`
Health check de la conexión PLC.

### GET `/alarms`
Lista de alarmas activas.

## 🔧 Configuración

### Variables de entorno

```bash
# IP del PLC (por defecto: 192.168.1.5)
PLC_IP=192.168.1.5

# Puerto del servidor (por defecto: 8000)
PORT=8000
```

### Configuración del PLC

- **IP**: 192.168.1.5 (configurable)
- **Rack**: 0 (S7-1200)
- **Slot**: 1 (S7-1200)

## 🚀 Ejecución

### Desarrollo

```bash
cd backend
python -m snap7.snap7_backend
```

### Producción

```bash
cd backend
uvicorn snap7.snap7_backend:app --host 0.0.0.0 --port 8000
```

## 🧪 Testing

### Ejecutar todos los tests

```bash
pytest tests/ -v
```

### Ejecutar tests específicos

```bash
# Solo tests de PLC
pytest tests/ -v -m plc

# Solo tests de API
pytest tests/test_api_status.py -v

# Solo tests de escritura
pytest tests/test_write_output.py -v
```

### Verificar cobertura

```bash
pytest tests/ --cov=snap7 --cov-report=html
```

## 🔍 Monitoreo

### Logs

Los logs se configuran automáticamente con nivel INFO:

```
2024-01-15 10:30:00 - snap7.plc_client - INFO - Conectado al PLC en 192.168.1.5
2024-01-15 10:30:05 - snap7.plc_client - WARNING - Nueva alarma: Temperatura alta: 42.5°C
```

### Health Check

```bash
curl http://localhost:8000/healthz
```

Respuesta:
```json
{
  "healthy": true,
  "connection_quality": "connected",
  "message": "Conexión saludable"
}
```

## 🚨 Sistema de Alarmas

### Alarmas implementadas

1. **HIGH_TEMPERATURE**: AI0 > 40°C
2. **HIGH_PRESSURE**: AI1 > 3 bar

### Configuración de alarmas

Las alarmas se verifican cada 5 segundos en background y se almacenan en memoria (máximo 50).

## 🔄 Reconexión Automática

El sistema implementa reconexión exponencial:

- **Delay base**: 1 segundo
- **Máximo intentos**: 5
- **Delay exponencial**: 1s, 2s, 4s, 8s, 16s

## 📊 Estados de Conexión

- **connected**: Conexión activa
- **disconnected**: Sin conexión
- **reconnecting**: Intentando reconexión

## 🔧 Desarrollo

### Agregar nueva funcionalidad

1. Crear método en `PLCClient`
2. Agregar endpoint en `snap7_backend.py`
3. Crear tests en `tests/`
4. Actualizar documentación

### Convenciones de código

- **Python**: PEP8, type hints, docstrings
- **Commits**: Conventional Commits
- **Tests**: Cada función nueva requiere test

## 🐛 Troubleshooting

### Error de conexión

```bash
# Verificar que el PLC esté en la red
ping 192.168.1.5

# Verificar puertos
telnet 192.168.1.5 102
```

### Error de Snap7

```bash
# Verificar instalación de libsnap7
ldconfig -p | grep snap7

# Reinstalar python-snap7
pip uninstall python-snap7
pip install python-snap7
```

### Logs detallados

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 📞 Soporte

- **Issues**: Crear issue en GitHub
- **Documentación**: Ver README.md
- **Tests**: Ejecutar `python test_backend.py`

## 📄 Licencia

MIT License - ver LICENSE para detalles. 