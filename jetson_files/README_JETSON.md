# 🚀 SAMABOT FRONTEND - JETSON NANO

## 📋 ARCHIVOS INCLUIDOS:
- `samabot-frontend.tar.gz` - Frontend comprimido
- `install_jetson_improved.sh` - Script de instalación mejorado
- `install_jetson.sh` - Script de instalación original

## 🎯 PASOS PARA INSTALAR:

### 1. Copiar archivos al Jetson
```bash
# En el Jetson, copia estos archivos desde la memoria USB:
cp /media/jetson/NOMBRE_USB/* ./
```

### 2. Ejecutar instalación
```bash
# En el Jetson:
chmod +x install_jetson_improved.sh
./install_jetson_improved.sh
```

### 3. Iniciar el frontend
```bash
# En el Jetson:
cd samabot-frontend
./start_samabot.sh
```

## 🌐 ACCESO:
- **URL:** http://192.168.1.7:3000
- **Acceso desde cualquier dispositivo en la red**

## 🔧 COMANDOS ÚTILES:
```bash
# Verificar estado
cd samabot-frontend && npm run dev

# Detener servidor
Ctrl+C

# Reiniciar
./start_samabot.sh
```

## 🎉 ¡LISTO PARA LA DEMOSTRACIÓN!
