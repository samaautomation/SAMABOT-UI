#!/bin/bash

# SAMABOT Frontend Transfer Script
# Transfiere el frontend completo al Jetson

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                SAMABOT FRONTEND TRANSFER                     ║"
echo "║                Transferencia al Jetson                       ║"
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

# Verificar que existe el directorio frontend local
show_info "Verificando directorio frontend local..."
if [ ! -d "samabot-frontend" ]; then
    show_error "No se encontró el directorio samabot-frontend"
    exit 1
fi

show_status "Directorio frontend encontrado"

# Crear directorio en el Jetson si no existe
show_info "Creando directorio en el Jetson..."
ssh samabot@192.168.1.7 "mkdir -p /home/samabot/SAMABOT-UI/samabot-frontend"

# Transferir el frontend completo
show_info "Transferiendo frontend al Jetson..."
rsync -avz --progress samabot-frontend/ samabot@192.168.1.7:/home/samabot/SAMABOT-UI/samabot-frontend/

if [ $? -eq 0 ]; then
    show_status "Frontend transferido correctamente"
else
    show_error "Error al transferir el frontend"
    exit 1
fi

# Verificar que se transfirió correctamente
show_info "Verificando transferencia..."
ssh samabot@192.168.1.7 "ls -la /home/samabot/SAMABOT-UI/samabot-frontend/"

# Verificar que el package.json tiene el script dev
show_info "Verificando scripts disponibles..."
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/samabot-frontend && npm run"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    TRANSFERENCIA COMPLETADA                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
show_status "Frontend transferido al Jetson"
show_info "Ubicación: /home/samabot/SAMABOT-UI/samabot-frontend"
echo ""
show_info "Para instalar dependencias en el Jetson:"
echo "   ssh samabot@192.168.1.7 'cd /home/samabot/SAMABOT-UI/samabot-frontend && npm install'"
echo ""
show_info "Para probar el frontend:"
echo "   ssh samabot@192.168.1.7 'cd /home/samabot/SAMABOT-UI/samabot-frontend && npm run dev'" 