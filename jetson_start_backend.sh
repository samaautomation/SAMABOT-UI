#!/bin/bash

# SAMABOT Jetson Backend Startup Script
# Para ejecutar en el Jetson Nano

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                SAMABOT JETSON BACKEND                        ║"
echo "║                    PLC Controller                             ║"
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

# Verificar que estamos en el Jetson
if [ "$(hostname)" != "ubuntu" ]; then
    show_warning "Este script está diseñado para ejecutarse en el Jetson Nano"
fi

# Ir al directorio del backend
cd /home/samabot/SAMABOT-UI/backend

# Verificar que existe el entorno virtual
if [ ! -d "venv" ]; then
    show_info "Creando entorno virtual..."
    python3 -m venv venv
fi

# Verificar que el archivo activate existe
if [ ! -f "venv/bin/activate" ]; then
    show_error "El entorno virtual no está correctamente configurado"
    show_info "Recreando entorno virtual..."
    rm -rf venv
    python3 -m venv venv
fi

# Activar entorno virtual de forma más robusta
show_info "Activando entorno virtual..."
export VIRTUAL_ENV="/home/samabot/SAMABOT-UI/backend/venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
unset PYTHONHOME

# Verificar que uvicorn está disponible
if ! command -v uvicorn &> /dev/null; then
    show_info "Instalando dependencias..."
    pip install -r requirements.txt
fi

# Verificar conexión al PLC
show_info "Verificando conexión al PLC Siemens..."
if ping -c 1 192.168.1.5 > /dev/null 2>&1; then
    show_status "PLC Siemens (192.168.1.5) está accesible"
else
    show_error "No se puede alcanzar el PLC Siemens"
    show_info "Verifica la conexión de red al PLC"
fi

# Iniciar el backend
show_info "Iniciando backend SAMABOT..."
show_info "Servidor: http://0.0.0.0:8000"
show_info "PLC: 192.168.1.5"
echo ""

# Función de limpieza
cleanup() {
    echo ""
    show_info "Deteniendo backend SAMABOT..."
    show_status "Backend detenido correctamente"
    exit 0
}

# Capturar Ctrl+C
trap cleanup SIGINT

# Iniciar uvicorn con la ruta completa
python3 -m uvicorn plc_backend.snap7_backend:app --host 0.0.0.0 --port 8000 --reload 