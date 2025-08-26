# 🚀 SAMABOT - Inicio Rápido

## ⚡ Acceso Directo

### Opción 1: Icono del Escritorio
- **Doble clic** en el icono `SAMABOT` del escritorio
- Se abrirá automáticamente en tu navegador

### Opción 2: Comando Rápido
```bash
./open_samabot.sh
```

### Opción 3: URL Directa
```
http://localhost:3000
```

## 🔧 Scripts Disponibles

| Comando | Descripción |
|---------|-------------|
| `./open_samabot.sh` | ⚡ Abrir navegador rápidamente |
| `./start_samabot.sh` | 🚀 Iniciar todo el sistema |
| `./samabot_status.sh` | 📊 Ver estado del sistema |
| `./jetson_start_backend.sh` | 🤖 Iniciar backend en Jetson |

## 📋 Estado Actual del Sistema

✅ **Frontend**: http://localhost:3000 - Funcionando  
✅ **Backend Jetson**: http://192.168.1.7:8000 - Conectado  
✅ **PLC Siemens**: 192.168.1.5 - Accesible  
✅ **Jetson Nano**: 192.168.1.7 - Accesible  

## 🎯 Funcionalidades Disponibles

### Frontend
- 🖥️ Panel de Samita con GIF animado
- 📊 Estado del PLC en tiempo real
- 🔌 Control de entradas/salidas digitales
- 📈 Monitoreo de entradas analógicas
- 🚨 Sistema de alarmas
- 💚 Health check del sistema

### Backend
- 🔗 Conexión automática al PLC
- 🔄 Reconexión exponencial
- 🌐 API REST completa
- 📝 Logging detallado
- 🛡️ Manejo de errores robusto

## 🔍 Verificar Estado

Para verificar que todo esté funcionando:

```bash
./samabot_status.sh
```

## 🆘 Solución de Problemas

### Si el navegador no se abre automáticamente:
```bash
# Abrir manualmente
xdg-open http://localhost:3000
```

### Si el frontend no carga:
```bash
# Verificar que esté corriendo
curl http://localhost:3000
```

### Si el backend no responde:
```bash
# Verificar conexión al Jetson
ping 192.168.1.7
curl http://192.168.1.7:8000
```

## 📱 Uso en Pantalla Táctil

La interfaz está optimizada para pantallas táctiles de 10":
- Botones grandes y fáciles de tocar
- Indicadores visuales claros
- Actualización automática cada 5 segundos
- Diseño responsive

## 🎨 Características de la UI

- **Tema Oscuro Industrial**: Interfaz moderna y profesional
- **Indicadores de Estado**: Colores para mostrar conexión
- **Control Directo**: Botones para activar/desactivar salidas
- **Monitoreo en Tiempo Real**: Datos actualizados automáticamente
- **Sistema de Alarmas**: Notificaciones visuales de eventos

---

**¡SAMABOT está listo para usar! 🎉**

**Desarrollado por ING. SERGIO M - #SAMAKER**  
💡 Build. Break. Repeat. 