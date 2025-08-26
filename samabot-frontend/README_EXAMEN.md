# 🤖 SAMABOT INDUSTRIAL - FRONTEND PARA EXAMEN

## 🚀 Inicio Rápido

```bash
# Opción 1: Script automático
./start_exam.sh

# Opción 2: Manual
npm install
npm run dev
```

## 📍 Acceso
- **URL**: http://localhost:3000
- **Puerto**: 3000

## 🎯 Características del Frontend

### ✅ Funcionalidades Implementadas
- **Interfaz Industrial Moderna**: Diseño profesional con gradientes y efectos visuales
- **Samita AI**: Representada por emoji robot 🤖 con animaciones
- **Estado del PLC en Tiempo Real**: 
  - Conexión PLC (conectado/desconectado)
  - Entradas digitales (ON/OFF)
  - Salidas digitales (ON/OFF) 
  - Entradas analógicas (valores numéricos)
  - Alarmas activas
- **Actualización Automática**: Cada 2 segundos
- **Responsive Design**: Funciona en móvil, tablet y desktop
- **Indicadores Visuales**: Colores y iconos para estados

### 🎨 Elementos Visuales
- **Header**: Título "SAMABOT INDUSTRIAL" con indicadores de estado
- **Panel Samita**: Robot animado con texto "SAMITA AI"
- **Panel PLC**: Estado completo del sistema industrial
- **Footer**: Información del sistema (Jetson Nano, Ubuntu, etc.)

## 🔧 Estructura del Proyecto

```
samabot-frontend/
├── src/
│   ├── app/
│   │   ├── page.tsx          # Página principal
│   │   ├── layout.tsx        # Layout base
│   │   └── globals.css       # Estilos globales
│   ├── components/ui/
│   │   ├── SamitaPanel.tsx   # Panel de Samita AI
│   │   └── PLCStatus.tsx     # Estado del PLC
│   └── services/
│       └── api.ts            # Servicio API
├── public/                   # Archivos estáticos
├── start_exam.sh            # Script de inicio
└── README_EXAMEN.md         # Este archivo
```

## 📡 API Endpoints

El frontend se conecta al backend en `http://192.168.1.7:8000`:

- `GET /status` - Estado completo del PLC
- `POST /output` - Escribir salida digital
- `GET /healthz` - Health check
- `POST /connect` - Conectar al PLC
- `POST /disconnect` - Desconectar del PLC

## 🎯 Para el Examen

### ✅ Lo que está listo:
1. **Frontend completamente funcional**
2. **Interfaz profesional y moderna**
3. **Conexión con backend configurada**
4. **Actualización en tiempo real**
5. **Diseño responsive**

### 📋 Checklist del Examen:
- [x] Frontend compila sin errores
- [x] Interfaz visual atractiva
- [x] Samita AI visible y animada
- [x] Estado del PLC en tiempo real
- [x] Diseño industrial profesional
- [x] Responsive design
- [x] Script de inicio automático

## 🚨 Solución de Problemas

### Si no inicia:
```bash
# Verificar Node.js
node --version

# Limpiar e instalar
rm -rf node_modules package-lock.json
npm install

# Iniciar
npm run dev
```

### Si hay errores de compilación:
```bash
# Limpiar cache
rm -rf .next
npm run build
```

## 🎉 ¡Listo para el Examen!

El frontend está completamente funcional y listo para presentar. Incluye:
- Interfaz profesional de SAMABOT Industrial
- Samita AI representada visualmente
- Monitoreo en tiempo real del PLC
- Diseño moderno y responsive

**¡Buena suerte en tu examen! 🍀** 