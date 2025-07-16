# SAMITA AI - Sistema de IA para SAMABOT Industrial

## 🚀 ¿Qué es SAMITA AI?

SAMITA AI es un asistente inteligente especializado en sistemas industriales que:
- **Lee datos del PLC** Siemens S7-1200 en tiempo real
- **Procesa preguntas** en lenguaje natural usando IA local
- **Responde sobre el estado del sistema** de manera inteligente
- **Aprende y mejora** con el tiempo

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Jetson Orin   │    │   PLC Siemens   │
│   Next.js       │◄──►│   Nano          │◄──►│   S7-1200       │
│   (Puerto 3000) │    │   (Puerto 3001) │    │   (192.168.1.5) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Ollama        │
                       │   (IA Local)    │
                       │   Phi-2.7b      │
                       └─────────────────┘
```

## 📋 Requisitos

### Hardware
- **Jetson Orin Nano** con GPU NVIDIA
- **PLC Siemens S7-1200** conectado por Ethernet
- **Red local** (192.168.1.x)

### Software
- **Ubuntu 22.04** en Jetson
- **Python 3.8+** con entorno virtual
- **Ollama** para IA local
- **Node.js 18+** para frontend

## 🛠️ Instalación

### 1. En el Jetson Orin Nano

```bash
# Conectarse al Jetson
ssh samabot@192.168.1.7

# Navegar al directorio
cd ~/maker/samabot/frontend

# Ejecutar script de configuración
./setup_samita.sh
```

### 2. En tu computadora principal

```bash
# Navegar al frontend
cd ~/Projects/samabot/SAMABOT-UI/samabot-frontend

# Instalar dependencias
npm install

# Crear archivo de configuración
cp env.example .env.local

# Editar configuración
nano .env.local
```

Configurar `.env.local`:
```env
NEXT_PUBLIC_SAMITA_API_URL=http://192.168.1.7:3001
NEXT_PUBLIC_PLC_API_URL=http://192.168.1.7:3001
```

### 3. Ejecutar el sistema

```bash
# Terminal 1: Frontend
npm run dev

# Terminal 2: Backend (en Jetson)
python samita_ai_backend.py
```

## 🧪 Pruebas

### 1. Verificar conectividad

```bash
# Verificar que el backend esté corriendo
curl http://192.168.1.7:3001/api/health

# Verificar que Ollama esté funcionando
curl http://192.168.1.7:11434/api/tags
```

### 2. Probar SAMITA AI

Abrir navegador en `http://localhost:3000` y preguntar:

- "¿Está funcionando el PLC?"
- "¿Qué entradas están activas?"
- "¿Hay algún error en el sistema?"
- "¿Cuál es el estado de las salidas digitales?"

## 🔧 Configuración Avanzada

### Variables de Entorno

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `NEXT_PUBLIC_SAMITA_API_URL` | URL del backend SAMITA | `http://192.168.1.7:3001` |
| `NEXT_PUBLIC_PLC_API_URL` | URL del backend PLC | `http://192.168.1.7:3001` |

### Configuración del PLC

```python
# En samita_ai_backend.py
PLC_IP = "192.168.1.5"  # IP del PLC
PLC_RACK = 0            # Rack del PLC
PLC_SLOT = 1            # Slot del PLC
```

### Configuración de Ollama

```bash
# Ver modelos disponibles
ollama list

# Crear modelo personalizado
ollama create mi-modelo -f prompt.txt
ollama cp phi:2.7b mi-modelo
```

## 🐛 Solución de Problemas

### Error: "CPU : Item not available"
- **Causa**: El PLC no tiene configurado el bloque de datos DB
- **Solución**: El backend lee entradas/salidas físicas como alternativa

### Error: "Connection refused"
- **Causa**: El backend no está corriendo
- **Solución**: Ejecutar `python samita_ai_backend.py`

### Error: "Ollama not responding"
- **Causa**: Ollama no está corriendo
- **Solución**: Ejecutar `ollama serve &`

### Error: "Model not found"
- **Causa**: El modelo no está descargado
- **Solución**: Ejecutar `ollama pull phi:2.7b`

## 📊 Monitoreo

### Logs del Backend
```bash
# Ver logs en tiempo real
tail -f /tmp/samita_backend.log

# Ver logs de Ollama
tail -f /tmp/ollama.log
```

### Métricas del Sistema
```bash
# Uso de GPU
nvidia-smi

# Uso de memoria
free -h

# Temperatura
cat /sys/class/thermal/thermal_zone*/temp
```

## 🔄 Actualizaciones

### Actualizar SAMITA AI
```bash
# En el Jetson
cd ~/maker/samabot/frontend
git pull
./setup_samita.sh
```

### Actualizar Frontend
```bash
# En tu computadora
cd ~/Projects/samabot/SAMABOT-UI/samabot-frontend
git pull
npm install
npm run dev
```

## 📝 API Endpoints

### PLC
- `GET /api/plc/status` - Estado del PLC
- `GET /api/plc/real-data` - Datos reales del PLC

### SAMITA AI
- `POST /api/samita/chat` - Chat con SAMITA AI
- `GET /api/health` - Health check del sistema

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 👨‍💻 Autor

**Ing. Sergio M** - #SAMAKER
- GitHub: [@samaker](https://github.com/samaker)
- Email: sergio@samabot.com

---

💡 **Build. Break. Repeat.** 🚀 