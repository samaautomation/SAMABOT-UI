#!/bin/bash

# SAMABOT Desktop Shortcut Setup
# Configura el acceso directo en el escritorio del Jetson

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                SAMABOT DESKTOP SHORTCUT                      ║"
echo "║                Configuración del Acceso Directo              ║"
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

# Verificar conexión al Jetson
show_info "Verificando conexión al Jetson Nano..."
if ping -c 1 192.168.1.7 > /dev/null 2>&1; then
    show_status "Jetson Nano (192.168.1.7) está accesible"
else
    show_error "No se puede alcanzar el Jetson Nano"
    exit 1
fi

# Transferir script de inicio
show_info "Transferiendo script de inicio al Jetson..."
scp start_samabot_jetson.sh samabot@192.168.1.7:/home/samabot/SAMABOT-UI/ > /dev/null 2>&1

if [ $? -eq 0 ]; then
    show_status "Script transferido correctamente"
else
    show_error "Error al transferir el script"
    exit 1
fi

# Crear archivo .desktop en el Jetson
show_info "Creando acceso directo en el escritorio..."
ssh samabot@192.168.1.7 "cat > /home/samabot/Desktop/SAMABOT.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=SAMABOT
Comment=Iniciar sistema SAMABOT (backend y frontend)
Exec=/home/samabot/SAMABOT-UI/start_samabot_jetson.sh
Icon=utilities-terminal
Terminal=true
Categories=Utility;
EOF"

# Hacer ejecutable el archivo .desktop
ssh samabot@192.168.1.7 "chmod +x /home/samabot/Desktop/SAMABOT.desktop"

# Hacer ejecutable el script
ssh samabot@192.168.1.7 "chmod +x /home/samabot/SAMABOT-UI/start_samabot_jetson.sh"

# Verificar que todo esté en su lugar
show_info "Verificando configuración..."
ssh samabot@192.168.1.7 "ls -la /home/samabot/Desktop/SAMABOT.desktop && ls -la /home/samabot/SAMABOT-UI/start_samabot_jetson.sh"

if [ $? -eq 0 ]; then
    show_status "Acceso directo configurado correctamente"
else
    show_error "Error en la configuración"
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    CONFIGURACIÓN COMPLETADA                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
show_status "Acceso directo creado en el escritorio del Jetson"
show_info "Ubicación: /home/samabot/Desktop/SAMABOT.desktop"
show_info "Script: /home/samabot/SAMABOT-UI/start_samabot_jetson.sh"
echo ""
show_info "Para usar SAMABOT:"
echo "   1. Ve al escritorio del Jetson"
echo "   2. Haz doble clic en el icono 'SAMABOT'"
echo "   3. El sistema se iniciará automáticamente"
echo "   4. Se abrirá el navegador con la interfaz"
echo ""
show_info "El sistema incluye:"
echo "   ✅ Backend del PLC (puerto 8000)"
echo "   ✅ Frontend web (puerto 3000/3001)"
echo "   ✅ Navegador automático"
echo "   ✅ Estado del PLC en tiempo real"
echo ""
show_warning "Para detener el sistema, cierra la terminal o presiona Ctrl+C" 