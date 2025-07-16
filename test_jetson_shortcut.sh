#!/bin/bash

# SAMABOT Jetson Shortcut Test
# Prueba el acceso directo del Jetson

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                SAMABOT JETSON SHORTCUT TEST                  ║"
echo "║                    Prueba del Acceso Directo                 ║"
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

# Verificar que el archivo .desktop existe
show_info "Verificando acceso directo..."
if ssh samabot@192.168.1.7 "test -f /home/samabot/Desktop/SAMABOT.desktop"; then
    show_status "Acceso directo encontrado"
else
    show_error "Acceso directo no encontrado"
    exit 1
fi

# Verificar que el script existe
show_info "Verificando script de inicio..."
if ssh samabot@192.168.1.7 "test -f /home/samabot/SAMABOT-UI/start_samabot_jetson.sh"; then
    show_status "Script de inicio encontrado"
else
    show_error "Script de inicio no encontrado"
    exit 1
fi

# Verificar permisos de ejecución
show_info "Verificando permisos..."
if ssh samabot@192.168.1.7 "test -x /home/samabot/Desktop/SAMABOT.desktop && test -x /home/samabot/SAMABOT-UI/start_samabot_jetson.sh"; then
    show_status "Permisos de ejecución correctos"
else
    show_error "Permisos de ejecución incorrectos"
    exit 1
fi

# Mostrar contenido del archivo .desktop
show_info "Contenido del acceso directo:"
ssh samabot@192.168.1.7 "cat /home/samabot/Desktop/SAMABOT.desktop"

echo ""
show_info "Prueba manual:"
echo "   1. Conecta al Jetson: ssh samabot@192.168.1.7"
echo "   2. Ve al escritorio: cd /home/samabot/Desktop"
echo "   3. Ejecuta el script: ./SAMABOT.desktop"
echo "   4. O ejecuta directamente: /home/samabot/SAMABOT-UI/start_samabot_jetson.sh"
echo ""
show_info "El sistema debería:"
echo "   ✅ Iniciar el backend del PLC"
echo "   ✅ Iniciar el frontend web"
echo "   ✅ Abrir el navegador automáticamente"
echo "   ✅ Mostrar el estado del PLC"
echo ""
show_warning "Para detener: Ctrl+C en la terminal del Jetson" 