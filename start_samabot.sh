#!/bin/bash

# SAMABOT Startup Script
# Despliega el sistema completo SAMABOT

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SAMABOT INDUSTRIAL                        ║"
echo "║                Sistema de Monitoreo Industrial               ║"
echo "║                     ING. SERGIO M                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Función para mostrar estado
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

# Verificar si estamos en el directorio correcto
if [ ! -f "samabot-frontend/package.json" ]; then
    show_error "No se encontró el proyecto SAMABOT. Asegúrate de estar en el directorio correcto."
    exit 1
fi

show_info "Iniciando SAMABOT Industrial..."

# 1. Verificar conexión al Jetson
show_info "Verificando conexión al Jetson Nano..."
if ping -c 1 192.168.1.7 > /dev/null 2>&1; then
    show_status "Jetson Nano (192.168.1.7) está accesible"
else
    show_warning "No se puede alcanzar el Jetson Nano. Verificando backend local..."
fi

# 2. Verificar backend del Jetson
show_info "Verificando backend del PLC..."
if curl -s http://192.168.1.7:8000/ > /dev/null 2>&1; then
    show_status "Backend del Jetson está funcionando"
    BACKEND_URL="http://192.168.1.7:8000"
else
    show_warning "Backend del Jetson no está disponible. Iniciando backend en el Jetson..."
    
    # Usar el script de inicio rápido del Jetson
    if [ -f "jetson_quick_start.sh" ]; then
        show_info "Iniciando backend en el Jetson..."
        ./jetson_quick_start.sh > /dev/null 2>&1
        
        # Verificar si el backend se inició correctamente
        sleep 5
        if curl -s http://192.168.1.7:8000/ > /dev/null 2>&1; then
            show_status "Backend del Jetson iniciado correctamente"
            BACKEND_URL="http://192.168.1.7:8000"
        else
            show_warning "No se pudo iniciar el backend en el Jetson. Iniciando backend local..."
        fi
    else
        show_warning "No se encontró el script de inicio del Jetson. Iniciando backend local..."
    fi
    
    # Iniciar backend local si es necesario
    if [ -d "backend" ]; then
        cd backend
        if [ ! -d "venv" ]; then
            show_info "Creando entorno virtual para backend..."
            python3 -m venv venv
        fi
        
        source venv/bin/activate
        pip install -r requirements.txt > /dev/null 2>&1
        
        show_info "Iniciando backend local..."
        python3 -m uvicorn plc_backend.snap7_backend:app --host 0.0.0.0 --port 8000 &
        BACKEND_PID=$!
        sleep 3
        
        if curl -s http://localhost:8000/ > /dev/null 2>&1; then
            show_status "Backend local iniciado correctamente"
            BACKEND_URL="http://localhost:8000"
        else
            show_error "No se pudo iniciar el backend local"
            exit 1
        fi
        
        cd ..
    else
        show_error "No se encontró el directorio backend"
        exit 1
    fi
fi

# 3. Actualizar configuración del frontend si es necesario
if [ "$BACKEND_URL" != "http://192.168.1.7:8000" ]; then
    show_info "Actualizando configuración del frontend para usar backend local..."
    sed -i "s|http://192.168.1.7:8000|$BACKEND_URL|g" samabot-frontend/src/services/api.ts
fi

# 4. Iniciar frontend
show_info "Iniciando frontend SAMABOT..."
cd samabot-frontend

# Verificar si node_modules existe
if [ ! -d "node_modules" ]; then
    show_info "Instalando dependencias del frontend..."
    npm install
fi

# Iniciar el servidor de desarrollo
show_info "Iniciando servidor de desarrollo..."
npm run dev &
FRONTEND_PID=$!

# Esperar a que el servidor esté listo
sleep 5

# Verificar que el frontend esté funcionando
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    show_status "Frontend iniciado correctamente"
else
    show_error "No se pudo iniciar el frontend"
    exit 1
fi

# 5. Abrir navegador
show_info "Abriendo navegador..."
if command -v xdg-open > /dev/null; then
    xdg-open http://localhost:3000
elif command -v open > /dev/null; then
    open http://localhost:3000
elif command -v start > /dev/null; then
    start http://localhost:3000
else
    show_warning "No se pudo abrir el navegador automáticamente"
    show_info "Abre manualmente: http://localhost:3000"
fi

# 6. Mostrar información del sistema
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SAMABOT DESPLEGADO                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
show_status "Frontend: http://localhost:3000"
show_status "Backend: $BACKEND_URL"
show_status "PLC: 192.168.1.5 (Siemens S7-1200)"
echo ""
show_info "Para detener el sistema, presiona Ctrl+C"
echo ""

# Función de limpieza
cleanup() {
    echo ""
    show_info "Deteniendo SAMABOT..."
    
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        show_status "Frontend detenido"
    fi
    
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        show_status "Backend detenido"
    fi
    
    show_status "SAMABOT detenido correctamente"
    exit 0
}

# Capturar Ctrl+C
trap cleanup SIGINT

# Mantener el script corriendo
while true; do
    sleep 1
done 