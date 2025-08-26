# 🏭 SAMABOT Industrial - Sistema de Monitoreo PLC

**Sistema de Monitoreo y Control Industrial para PLC Siemens S7-1200**

## 📋 Descripción

SAMABOT Industrial es un sistema completo de monitoreo y control para PLC Siemens S7-1200, desarrollado para demostraciones profesionales y control industrial. El sistema incluye:

- **Backend API**: FastAPI con comunicación Snap7 al PLC
- **Frontend Web**: Interfaz moderna y responsiva
- **Arquitectura Distribuida**: Backend en Jetson Nano, Frontend accesible desde cualquier dispositivo
- **Control en Tiempo Real**: Monitoreo y control de entradas/salidas digitales

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend Web  │    │  Backend API    │    │  PLC Siemens    │
│   (Puerto 3000) │◄──►│  (Puerto 8000)  │◄──►│  S7-1200        │
│                 │    │                 │    │  (192.168.1.5)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│   Jetson Nano   │    │   Red Local     │
│  (192.168.1.7)  │    │   (192.168.1.x) │
└─────────────────┘    └─────────────────┘
```

## 🚀 Estado Actual del Sistema

### ✅ Componentes Funcionando

1. **Backend API** (FastAPI + Snap7)
   - ✅ Comunicación establecida con PLC Siemens S7-1200
   - ✅ API REST funcional en puerto 8000
   - ✅ Endpoints para estado, entradas y salidas
   - ✅ Documentación automática en `/docs`

2. **Frontend Web** (Express.js + HTML/CSS/JS)
   - ✅ Interfaz moderna y responsiva
   - ✅ Control en tiempo real de entradas/salidas
   - ✅ Diseño optimizado para pantallas táctiles
   - ✅ Compatible con dispositivos móviles

3. **Infraestructura**
   - ✅ Jetson Nano configurado como servidor
   - ✅ Auto-inicio del backend al reiniciar
   - ✅ Scripts de gestión automatizados
   - ✅ Acceso directo en escritorio para demos

## 📊 URLs del Sistema

- **🌐 Frontend Principal**: http://192.168.1.7:3000
- **🔧 Backend API**: http://192.168.1.7:8000
- **📚 Documentación API**: http://192.168.1.7:8000/docs
- **🏭 PLC Siemens**: 192.168.1.5

## 🛠️ Scripts de Gestión

### Scripts Principales

1. **`start_samabot_jetson.sh`** - Inicia todo el sistema en el Jetson
2. **`test_samabot_complete.sh`** - Prueba completa del sistema
3. **`samabot_status.sh`** - Verifica estado de todos los componentes
4. **`transfer_frontend_to_jetson.sh`** - Transfiere frontend al Jetson
5. **`create_simple_frontend.sh`** - Crea frontend compatible con ARM64

### Comandos Rápidos

```bash
# Iniciar sistema completo
./start_samabot_jetson.sh

# Probar sistema
./test_samabot_complete.sh

# Ver estado
./samabot_status.sh

# Abrir en navegador
firefox http://192.168.1.7:3000
```

## 🎯 Características del Frontend

### Interfaz Moderna
- **Diseño Responsivo**: Adaptable a cualquier pantalla
- **Gradientes Modernos**: Interfaz visual atractiva
- **Iconografía Clara**: Emojis y símbolos intuitivos
- **Animaciones Suaves**: Transiciones profesionales

### Funcionalidades
- **📊 Estado del Sistema**: Conexión PLC, calidad de señal
- **📥 Entradas Digitales**: Monitoreo en tiempo real
- **📤 Salidas Digitales**: Control con botones
- **🔄 Actualización Automática**: Cada 5 segundos
- **🔌 Conectar PLC**: Botón para establecer conexión

### Compatibilidad
- **💻 Desktop**: Navegadores modernos
- **📱 Móvil**: Interfaz táctil optimizada
- **🖥️ Tablet**: Pantallas de 10" y mayores
- **🌐 Red Local**: Acceso desde cualquier dispositivo

## 🔧 Configuración Técnica

### Backend (Jetson Nano)
- **Sistema**: Ubuntu 20.04 LTS
- **Python**: 3.10+
- **Framework**: FastAPI
- **PLC Communication**: python-snap7
- **Puerto**: 8000

### Frontend (Express.js)
- **Runtime**: Node.js
- **Framework**: Express.js
- **Estilos**: CSS puro con gradientes
- **JavaScript**: Vanilla JS (sin frameworks)
- **Puerto**: 3000

### PLC Siemens S7-1200
- **Modelo**: S7-1200
- **IP**: 192.168.1.5
- **Protocolo**: Snap7
- **Entradas**: Digitales configurables
- **Salidas**: Digitales configurables

## 📈 Estado de Conexión

### PLC Status
```json
{
  "connectionQuality": "connected",
  "ip": "192.168.1.5",
  "rack": 0,
  "slot": 1,
  "reconnectAttempts": 0,
  "lastUpdate": 1752310528.7432604
}
```

### Errores Normales
- `CPU : Item not available` - Indica que el PLC no tiene entradas analógicas configuradas
- Estos errores son normales y no afectan la funcionalidad del sistema

## 🎪 Demos Profesionales

### Preparación para Demos
1. **Sistema Listo**: Backend y frontend funcionando
2. **Acceso Directo**: Icono en escritorio del Jetson
3. **Red Configurada**: Acceso desde cualquier dispositivo
4. **Documentación**: API docs disponibles

### Flujo de Demo
1. **Presentación**: Mostrar interfaz web
2. **Funcionalidades**: Conectar PLC, ver entradas/salidas
3. **Control**: Activar/desactivar salidas
4. **Tiempo Real**: Mostrar actualizaciones automáticas
5. **Acceso Móvil**: Demostrar acceso desde teléfono

## 🔒 Seguridad y Red

### Configuración de Red
- **Red Local**: 192.168.1.x
- **Jetson Nano**: 192.168.1.7
- **PLC Siemens**: 192.168.1.5
- **Acceso**: Solo desde red local

### Puertos Utilizados
- **3000**: Frontend Web
- **8000**: Backend API
- **22**: SSH (configuración)

## 📝 Logs y Monitoreo

### Logs del Sistema
- **Backend**: `backend.log` en Jetson
- **Frontend**: `frontend.log` en Jetson
- **Sistema**: Logs automáticos de uvicorn

### Monitoreo
- **Estado PLC**: Endpoint `/status`
- **Entradas**: Endpoint `/inputs`
- **Salidas**: Endpoint `/outputs`
- **Documentación**: Endpoint `/docs`

## 🚀 Próximos Pasos

### Mejoras Planificadas
1. **Gráficos en Tiempo Real**: Charts.js para visualización
2. **Histórico de Datos**: Base de datos SQLite
3. **Alertas**: Sistema de notificaciones
4. **Configuración Web**: Panel de configuración
5. **Múltiples PLCs**: Soporte para varios dispositivos

### Optimizaciones
1. **Performance**: Optimización de consultas
2. **UI/UX**: Mejoras en interfaz
3. **Seguridad**: Autenticación básica
4. **Escalabilidad**: Arquitectura modular

## 📞 Soporte

### Información de Contacto
- **Desarrollador**: Ing. Sergio M
- **Proyecto**: SAMABOT Industrial
- **Versión**: 1.0.0
- **Fecha**: Julio 2025

### Comandos de Soporte
```bash
# Verificar conectividad
ping 192.168.1.7
ping 192.168.1.5

# Verificar servicios
curl http://192.168.1.7:8000/
curl http://192.168.1.7:3000/

# Ver logs
ssh samabot@192.168.1.7 "tail -f backend.log"
ssh samabot@192.168.1.7 "tail -f frontend.log"
```

---

**🏭 SAMABOT Industrial - Sistema de Monitoreo PLC Siemens S7-1200**

*Desarrollado por Ing. Sergio M - #SAMAKER*
