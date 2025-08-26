#!/bin/bash

# SAMABOT Jetson Quick Start Script
# Para iniciar el backend en el Jetson desde la laptop

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                SAMABOT JETSON QUICK START                    ║"
echo "║                    Inicio Rápido del Backend                 ║"
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
    show_info "Verifica la conexión de red al Jetson"
    exit 1
fi

# Verificar si el backend ya está corriendo
show_info "Verificando si el backend ya está corriendo..."
if curl -s http://192.168.1.7:8000/ > /dev/null 2>&1; then
    show_status "Backend ya está corriendo en el Jetson"
    show_info "URL: http://192.168.1.7:8000"
    show_info "Estado del PLC:"
    curl -s http://192.168.1.7:8000/status | jq '.'
    exit 0
fi

# Iniciar el backend en el Jetson
show_info "Iniciando backend en el Jetson..."
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/backend && ./jetson_start_backend.sh" &
BACKEND_PID=$!

# Esperar un momento para que el backend se inicie
show_info "Esperando que el backend se inicie..."
sleep 10

# Verificar que el backend esté funcionando
show_info "Verificando que el backend esté funcionando..."
if curl -s http://192.168.1.7:8000/ > /dev/null 2>&1; then
    show_status "Backend iniciado correctamente"
    show_info "URL: http://192.168.1.7:8000"
    show_info "Estado del PLC:"
    curl -s http://192.168.1.7:8000/status | jq '.'
else
    show_error "El backend no se inició correctamente"
    show_info "Verifica los logs en el Jetson"
    exit 1
fi

echo ""
show_info "Para detener el backend, ejecuta: ssh samabot@192.168.1.7 'pkill -f uvicorn'" 