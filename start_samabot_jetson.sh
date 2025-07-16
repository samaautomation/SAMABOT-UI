#!/bin/bash

# SAMABOT Jetson Complete Startup Script
# Inicia backend y frontend en el Jetson para demos

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SAMABOT INDUSTRIAL                        ║"
echo "║                Sistema de Monitoreo Industrial               ║"
echo "║                     ING. SERGIO M                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
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

show_section() {
    echo -e "${PURPLE}📋 $1${NC}"
}

# Función de limpieza
cleanup() {
    echo ""
    show_info "Deteniendo SAMABOT..."
    
    # Detener frontend
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        show_status "Frontend detenido"
    fi
    
    # Detener backend
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        show_status "Backend detenido"
    fi
    
    # Detener procesos de uvicorn
    pkill -f uvicorn 2>/dev/null
    pkill -f "npm run dev" 2>/dev/null
    pkill -f "next dev" 2>/dev/null
    pkill -f "node server.js" 2>/dev/null
    
    show_status "SAMABOT detenido correctamente"
    exit 0
}

# Capturar Ctrl+C
trap cleanup SIGINT

# Ir al directorio del proyecto
cd /home/samabot/SAMABOT-UI

show_section "Iniciando SAMABOT Industrial..."

# 1. Verificar y detener procesos existentes
show_info "Verificando procesos existentes..."
pkill -f uvicorn 2>/dev/null
pkill -f "npm run dev" 2>/dev/null
pkill -f "next dev" 2>/dev/null
pkill -f "node server.js" 2>/dev/null

# Verificar puertos ocupados
show_info "Verificando puertos..."
if netstat -tlnp 2>/dev/null | grep ":8000" > /dev/null; then
    show_warning "Puerto 8000 ocupado, liberando..."
    fuser -k 8000/tcp 2>/dev/null || true
fi

if netstat -tlnp 2>/dev/null | grep ":3000" > /dev/null; then
    show_warning "Puerto 3000 ocupado, liberando..."
    fuser -k 3000/tcp 2>/dev/null || true
fi

sleep 3

# 2. Iniciar Backend
show_section "Iniciando Backend del PLC..."

cd backend

# Verificar entorno virtual
if [ ! -d "venv" ]; then
    show_info "Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar entorno virtual
export VIRTUAL_ENV="/home/samabot/SAMABOT-UI/backend/venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
unset PYTHONHOME

# Verificar dependencias
if ! command -v uvicorn &> /dev/null; then
    show_info "Instalando dependencias del backend..."
    pip install -r requirements.txt > /dev/null 2>&1
fi

# Verificar conexión al PLC
show_info "Verificando conexión al PLC Siemens..."
if ping -c 1 192.168.1.5 > /dev/null 2>&1; then
    show_status "PLC Siemens (192.168.1.5) está accesible"
else
    show_warning "No se puede alcanzar el PLC Siemens"
fi

# Iniciar backend en segundo plano
show_info "Iniciando servidor backend..."
python3 -m uvicorn plc_backend.snap7_backend:app --host 0.0.0.0 --port 8000 --reload > backend.log 2>&1 &
BACKEND_PID=$!

# Esperar a que el backend esté listo
show_info "Esperando que el backend se inicie..."
for i in {1..30}; do
    if curl -s http://localhost:8000/ > /dev/null 2>&1; then
        show_status "Backend iniciado correctamente"
        show_info "URL: http://localhost:8000"
        break
    fi
    
    if [ $i -eq 30 ]; then
        show_error "No se pudo iniciar el backend después de 30 segundos"
        show_info "Revisando logs..."
        tail -10 backend.log 2>/dev/null || echo "No se encontraron logs"
        exit 1
    fi
    
    sleep 1
done

cd ..

# 3. Iniciar Frontend
show_section "Iniciando Frontend..."

cd samabot-simple-frontend

# Verificar dependencias del frontend
if [ ! -d "node_modules" ]; then
    show_info "Instalando dependencias del frontend..."
    npm install > /dev/null 2>&1
fi

# Iniciar frontend en segundo plano
show_info "Iniciando servidor frontend..."
npm start > frontend.log 2>&1 &
FRONTEND_PID=$!

# Esperar a que el frontend esté listo
sleep 10

# Verificar que el frontend esté funcionando
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    show_status "Frontend iniciado correctamente"
    show_info "URL: http://localhost:3000"
elif curl -s http://localhost:3001 > /dev/null 2>&1; then
    show_status "Frontend iniciado correctamente (puerto 3001)"
    show_info "URL: http://localhost:3001"
else
    show_error "No se pudo iniciar el frontend"
    exit 1
fi

cd ..

# 4. Abrir navegador
show_section "Abriendo Navegador..."

# Determinar la URL del frontend
FRONTEND_URL="http://localhost:3000"
if ! curl -s http://localhost:3000 > /dev/null 2>&1; then
    FRONTEND_URL="http://localhost:3001"
fi

# Abrir navegador
if command -v chromium-browser > /dev/null; then
    show_info "Abriendo Chromium..."
    chromium-browser --no-sandbox --disable-dev-shm-usage "$FRONTEND_URL" &
elif command -v firefox > /dev/null; then
    show_info "Abriendo Firefox..."
    firefox "$FRONTEND_URL" &
else
    show_warning "No se encontró un navegador compatible"
    show_info "Abre manualmente: $FRONTEND_URL"
fi

# 5. Mostrar información del sistema
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SAMABOT DESPLEGADO                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
show_status "Frontend: $FRONTEND_URL"
show_status "Backend: http://localhost:8000"
show_status "PLC: 192.168.1.5 (Siemens S7-1200)"
show_status "Documentación API: http://localhost:8000/docs"
echo ""
show_info "Para detener el sistema, presiona Ctrl+C"
echo ""

# 6. Mostrar estado del PLC
show_section "Estado del PLC:"
PLC_STATUS=$(curl -s http://localhost:8000/status 2>/dev/null)
if [ ! -z "$PLC_STATUS" ]; then
    echo "$PLC_STATUS" | jq -r '.connectionQuality + " - " + .ip' 2>/dev/null || echo "Conectado a $(echo "$PLC_STATUS" | jq -r '.ip' 2>/dev/null)"
else
    show_warning "No se pudo obtener el estado del PLC"
fi

echo ""
show_info "Sistema SAMABOT listo para demo con clientes!"
show_info "El navegador se abrirá automáticamente"
echo ""

# Mantener el script corriendo
while true; do
    sleep 1
done 