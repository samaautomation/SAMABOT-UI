# SAMABOT INDUSTRIAL

Sistema de Monitoreo Industrial con PLC Siemens S7-1200

## 🚀 Inicio Rápido

### Opción 1: Script Automático (Recomendado)
```bash
./start_samabot.sh
```

### Opción 2: Abrir Solo Navegador
```bash
./open_samabot.sh
```

### Opción 3: Inicio Manual

#### 1. Backend en Jetson
```bash
# En el Jetson Nano
cd /home/samabot/SAMABOT-UI/backend
./jetson_start_backend.sh
```

#### 2. Frontend en Laptop
```bash
# En tu laptop
cd samabot-frontend
npm run dev
```

#### 3. Abrir Navegador
```
http://localhost:3000
```

## 📋 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `start_samabot.sh` | Inicia todo el sistema automáticamente |
| `open_samabot.sh` | Abre solo el navegador |
| `jetson_start_backend.sh` | Inicia backend en Jetson |

## 🔧 Configuración del Sistema

### Arquitectura
```
┌─────────────────┐    HTTP    ┌─────────────────┐    Snap7    ┌─────────────────┐
│   Frontend      │ ──────────► │   Backend       │ ──────────► │   PLC Siemens   │
│  (localhost:3000)│            │ (192.168.1.7:8000)│            │ (192.168.1.5)   │
└─────────────────┘            └─────────────────┘            └─────────────────┘
```

### URLs Importantes
- **Frontend**: http://localhost:3000
- **Backend Jetson**: http://192.168.1.7:8000
- **PLC Siemens**: 192.168.1.5

## 🎯 Funcionalidades

### Frontend
- ✅ Panel de Samita con GIF animado
- ✅ Estado del PLC en tiempo real
- ✅ Control de entradas/salidas digitales
- ✅ Monitoreo de entradas analógicas
- ✅ Sistema de alarmas
- ✅ Health check del sistema

### Backend
- ✅ Conexión automática al PLC
- ✅ Reconexión exponencial
- ✅ API REST completa
- ✅ Logging detallado
- ✅ Manejo de errores

## 🔍 Endpoints del Backend

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/` | GET | Información básica de la API |
| `/status` | GET | Estado completo del sistema |
| `/healthz` | GET | Health check |
| `/connect` | POST | Conectar al PLC |
| `/output` | POST | Escribir salida digital |
| `/alarms` | GET | Lista de alarmas |

## 🛠️ Solución de Problemas

### Frontend no carga
```bash
# Verificar que el servidor esté corriendo
curl http://localhost:3000

# Reiniciar frontend
cd samabot-frontend
npm run dev
```

### Backend no responde
```bash
# Verificar conexión al Jetson
ping 192.168.1.7

# Verificar backend
curl http://192.168.1.7:8000
```

### PLC no conecta
```bash
# Verificar red
ping 192.168.1.5

# Verificar en Jetson
ssh samabot@192.168.1.7
cd /home/samabot/SAMABOT-UI/backend
./jetson_start_backend.sh
```

## 📁 Estructura del Proyecto

```
SAMABOT-UI/
├── start_samabot.sh          # Script principal
├── open_samabot.sh           # Abrir navegador
├── jetson_start_backend.sh   # Backend en Jetson
├── backend/                  # Backend Python
│   ├── plc_backend/
│   │   ├── snap7_backend.py  # API FastAPI
│   │   └── plc_client.py     # Cliente PLC
│   └── requirements.txt
└── samabot-frontend/         # Frontend Next.js
    ├── src/
    │   ├── components/ui/
    │   │   ├── SamitaPanel.tsx
    │   │   └── PLCStatus.tsx
    │   └── services/api.ts
    └── package.json
```

## 🎨 Características de la UI

- **Diseño Industrial**: Interfaz moderna con tema oscuro
- **Responsive**: Optimizado para pantallas táctiles de 10"
- **Tiempo Real**: Actualización automática cada 5 segundos
- **Feedback Visual**: Indicadores de estado con colores
- **Control Directo**: Botones para controlar salidas del PLC

## 🔐 Seguridad

- Backend configurado para red local
- CORS habilitado para desarrollo
- Logging detallado para debugging
- Manejo de errores robusto

## 📞 Soporte

Para problemas técnicos:
1. Verificar logs del backend en Jetson
2. Revisar consola del navegador
3. Verificar conectividad de red
4. Reiniciar servicios si es necesario

---

**Desarrollado por ING. SERGIO M - #SAMAKER**  
💡 Build. Break. Repeat. 