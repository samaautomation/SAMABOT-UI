# 🚀 SAMABOT - Comandos y Scripts Disponibles

## 📋 Resumen del Sistema

**SAMABOT** es un sistema de monitoreo industrial que conecta un PLC Siemens S7-1200 con una interfaz web moderna.

### 🌐 Arquitectura del Sistema
- **Frontend**: Next.js + React + Tailwind CSS (Laptop - Puerto 3000/3001)
- **Backend**: FastAPI + Python + Snap7 (Jetson Nano - Puerto 8000)
- **PLC**: Siemens S7-1200 (IP: 192.168.1.5)
- **Jetson**: NVIDIA Jetson Nano (IP: 192.168.1.7)

---

## 🎯 Scripts Principales

### 1. `start_samabot.sh` - Inicio Completo del Sistema
```bash
./start_samabot.sh
```
**Función**: Inicia todo el sistema SAMABOT
- ✅ Verifica conectividad al Jetson y PLC
- ✅ Inicia backend en el Jetson (o local si es necesario)
- ✅ Inicia frontend en la laptop
- ✅ Abre el navegador automáticamente
- ✅ Muestra URLs de acceso

### 2. `jetson_quick_start.sh` - Inicio Rápido del Backend
```bash
./jetson_quick_start.sh
```
**Función**: Inicia solo el backend en el Jetson
- ✅ Verifica conectividad al Jetson
- ✅ Inicia backend si no está corriendo
- ✅ Muestra estado del PLC
- ⚡ Inicio rápido y eficiente

### 3. `open_samabot.sh` - Abrir Navegador
```bash
./open_samabot.sh
```
**Función**: Abre el navegador con SAMABOT
- 🌐 Abre http://localhost:3000
- 🔄 Intenta puerto 3001 si 3000 está ocupado

### 4. `samabot_status.sh` - Estado del Sistema
```bash
./samabot_status.sh
```
**Función**: Muestra estado completo del sistema
- 📊 Estado de conectividad (Jetson, PLC)
- 🔧 Estado de backend y frontend
- 📈 Información del sistema
- 🌐 URLs de acceso
- 💡 Comandos útiles

---

## 🔧 Scripts de Gestión del Jetson

### 5. `jetson_start_backend.sh` - Script del Jetson
```bash
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/backend && ./jetson_start_backend.sh"
```
**Función**: Script para ejecutar en el Jetson
- 🐍 Activa entorno virtual Python
- 📦 Instala dependencias
- 🔌 Verifica conexión al PLC
- 🚀 Inicia servidor uvicorn

### 6. `jetson_auto_start.sh` - Auto-inicio del Jetson
```bash
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/backend && ./jetson_auto_start.sh"
```
**Función**: Configura auto-inicio en el Jetson
- ⏰ Configura crontab para auto-inicio
- 🔄 Reinicia automáticamente si falla
- 📝 Crea logs del sistema

### 7. `start_samabot_jetson.sh` - Sistema Completo en Jetson
```bash
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI && ./start_samabot_jetson.sh"
```
**Función**: Inicia backend y frontend en el Jetson
- 🚀 Backend del PLC (puerto 8000)
- 🌐 Frontend web (puerto 3000/3001)
- 🖥️ Navegador automático
- 📊 Estado del PLC en tiempo real
- 💻 Ideal para demos con clientes

### 8. Acceso Directo del Escritorio (Jetson)
**Ubicación**: `/home/samabot/Desktop/SAMABOT.desktop`
**Uso**: Doble clic en el icono "SAMABOT" del escritorio del Jetson
**Función**: Inicia todo el sistema automáticamente
- ✅ Backend + Frontend + Navegador
- ✅ Perfecto para presentaciones
- ✅ No requiere comandos manuales

---

## 🛠️ Comandos de Mantenimiento

### Verificar Estado del Sistema
```bash
# Estado completo
./samabot_status.sh

# Verificar solo backend
curl http://192.168.1.7:8000/status

# Verificar solo frontend
curl http://localhost:3000
```

### Detener Servicios
```bash
# Detener backend en Jetson
ssh samabot@192.168.1.7 'pkill -f uvicorn'

# Detener frontend local
pkill -f "npm run dev"

# Detener todos los procesos SAMABOT
pkill -f "samabot"
```

### Reiniciar Servicios
```bash
# Reiniciar backend
ssh samabot@192.168.1.7 'pkill -f uvicorn && cd /home/samabot/SAMABOT-UI/backend && ./jetson_start_backend.sh'

# Reiniciar frontend
pkill -f "npm run dev" && cd samabot-frontend && npm run dev
```

---

## 📁 Estructura de Archivos

```
SAMABOT-UI/
├── start_samabot.sh          # Script principal de inicio
├── jetson_quick_start.sh     # Inicio rápido del backend
├── open_samabot.sh           # Abrir navegador
├── samabot_status.sh         # Estado del sistema
├── jetson_start_backend.sh   # Script del Jetson
├── jetson_auto_start.sh      # Auto-inicio del Jetson
├── samabot-frontend/         # Frontend Next.js
│   ├── src/
│   │   ├── app/
│   │   └── components/
│   └── package.json
└── backend/                  # Backend FastAPI
    ├── plc_backend/
    ├── requirements.txt
    └── venv/
```

---

## 🌐 URLs de Acceso

### Frontend
- **Principal**: http://localhost:3000
- **Alternativo**: http://localhost:3001
- **Red**: http://192.168.1.23:3000

### Backend
- **Jetson**: http://192.168.1.7:8000
- **Local**: http://localhost:8000
- **Documentación**: http://192.168.1.7:8000/docs

### PLC
- **IP**: 192.168.1.5
- **Tipo**: Siemens S7-1200
- **Protocolo**: Snap7

---

## 🔍 Solución de Problemas

### Backend no responde
```bash
# Verificar si está corriendo
ssh samabot@192.168.1.7 'ps aux | grep uvicorn'

# Reiniciar backend
./jetson_quick_start.sh

# Verificar logs
ssh samabot@192.168.1.7 'tail -f /home/samabot/SAMABOT-UI/backend/backend.log'
```

### Frontend no carga
```bash
# Verificar puertos
netstat -tlnp | grep :300

# Reiniciar frontend
cd samabot-frontend && npm run dev

# Verificar dependencias
cd samabot-frontend && npm install
```

### PLC no conecta
```bash
# Verificar conectividad
ping 192.168.1.5

# Verificar estado del PLC
curl http://192.168.1.7:8000/status

# Reiniciar conexión
curl -X POST http://192.168.1.7:8000/connect
```

---

## 📝 Notas Importantes

1. **Puertos**: El frontend puede usar puerto 3000 o 3001 automáticamente
2. **Red**: Todos los dispositivos deben estar en la misma red (192.168.1.x)
3. **Jetson**: El backend corre en el Jetson Nano para mejor rendimiento
4. **PLC**: Los errores "CPU : Item not available" son normales si no hay entradas analógicas configuradas
5. **Auto-inicio**: El Jetson está configurado para auto-iniciar el backend al reiniciar

---

## 🎯 Flujo de Trabajo Recomendado

1. **Inicio diario**: `./start_samabot.sh`
2. **Verificar estado**: `./samabot_status.sh`
3. **Acceso rápido**: `./open_samabot.sh`
4. **Reinicio backend**: `./jetson_quick_start.sh`
5. **Mantenimiento**: Revisar logs y estado del sistema

## 🖥️ Demo con Clientes (Jetson)

### Acceso Directo del Escritorio
- **Ubicación**: `/home/samabot/Desktop/SAMABOT.desktop`
- **Uso**: Doble clic en el icono "SAMABOT"
- **Resultado**: Sistema completo automático

### Script Manual
```bash
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI && ./start_samabot_jetson.sh"
```

### Configuración del Acceso Directo
```bash
./jetson_desktop_shortcut.sh
```

### Prueba del Sistema
```bash
./test_jetson_shortcut.sh
```

---

**Desarrollado por ING. SERGIO M - #SAMAKER**  
**Sistema de Monitoreo Industrial SAMABOT**  
**Build. Break. Repeat.** 🚀 