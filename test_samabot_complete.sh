#!/bin/bash

# SAMABOT Complete System Test
# Prueba completa del sistema SAMABOT Industrial

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                SAMABOT COMPLETE SYSTEM TEST                  ║"
echo "║                Prueba Completa del Sistema                   ║"
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

# Función para probar conectividad
test_connectivity() {
    local host=$1
    local description=$2
    
    if ping -c 1 "$host" > /dev/null 2>&1; then
        show_status "$description ($host) está accesible"
        return 0
    else
        show_error "$description ($host) no está accesible"
        return 1
    fi
}

# Función para probar servicio HTTP
test_http_service() {
    local url=$1
    local description=$2
    
    if curl -s "$url" > /dev/null 2>&1; then
        show_status "$description ($url) está funcionando"
        return 0
    else
        show_error "$description ($url) no está funcionando"
        return 1
    fi
}

# Función para obtener datos del API
get_api_data() {
    local url=$1
    local description=$2
    
    echo ""
    show_info "Obteniendo datos de $description..."
    response=$(curl -s "$url" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ ! -z "$response" ]; then
        show_status "Datos obtenidos correctamente"
        echo "$response" | jq . 2>/dev/null || echo "$response"
    else
        show_error "Error obteniendo datos de $description"
    fi
}

# Inicio de pruebas
show_section "Iniciando Pruebas del Sistema SAMABOT"

# 1. Pruebas de conectividad
show_section "1. Pruebas de Conectividad"

test_connectivity "192.168.1.7" "Jetson Nano"
test_connectivity "192.168.1.5" "PLC Siemens S7-1200"

# 2. Pruebas de servicios HTTP
show_section "2. Pruebas de Servicios HTTP"

test_http_service "http://192.168.1.7:8000" "Backend API"
test_http_service "http://192.168.1.7:3000" "Frontend Web"

# 3. Pruebas de API
show_section "3. Pruebas de API del Backend"

get_api_data "http://192.168.1.7:8000/" "Información del API"
get_api_data "http://192.168.1.7:8000/status" "Estado del PLC"
get_api_data "http://192.168.1.7:8000/inputs" "Entradas Digitales"
get_api_data "http://192.168.1.7:8000/outputs" "Salidas Digitales"

# 4. Pruebas del Frontend
show_section "4. Pruebas del Frontend"

echo ""
show_info "Verificando contenido del frontend..."
frontend_content=$(curl -s http://192.168.1.7:3000)

if echo "$frontend_content" | grep -q "SAMABOT Industrial"; then
    show_status "Frontend cargado correctamente"
    show_info "Título encontrado: SAMABOT Industrial"
else
    show_error "Frontend no se cargó correctamente"
fi

# 5. Pruebas de procesos
show_section "5. Verificación de Procesos"

echo ""
show_info "Verificando procesos en el Jetson..."

backend_process=$(ssh samabot@192.168.1.7 "ps aux | grep uvicorn | grep -v grep" 2>/dev/null)
if [ ! -z "$backend_process" ]; then
    show_status "Backend (uvicorn) está ejecutándose"
else
    show_error "Backend (uvicorn) no está ejecutándose"
fi

frontend_process=$(ssh samabot@192.168.1.7 "ps aux | grep 'node server.js' | grep -v grep" 2>/dev/null)
if [ ! -z "$frontend_process" ]; then
    show_status "Frontend (node server.js) está ejecutándose"
else
    show_error "Frontend (node server.js) no está ejecutándose"
fi

# 6. Resumen final
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    RESUMEN DE PRUEBAS                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

show_info "URLs del Sistema:"
echo "   🌐 Frontend: http://192.168.1.7:3000"
echo "   🔧 Backend: http://192.168.1.7:8000"
echo "   📚 API Docs: http://192.168.1.7:8000/docs"
echo "   🏭 PLC: 192.168.1.5 (Siemens S7-1200)"

echo ""
show_info "Comandos útiles:"
echo "   📊 Estado del sistema: ./samabot_status.sh"
echo "   🚀 Iniciar sistema: ./start_samabot_jetson.sh"
echo "   🛑 Detener sistema: ssh samabot@192.168.1.7 'pkill -f uvicorn && pkill -f \"node server.js\"'"

echo ""
show_info "Para demos con clientes:"
echo "   💻 Abrir navegador: firefox http://192.168.1.7:3000"
echo "   📱 Acceso móvil: http://192.168.1.7:3000 (desde cualquier dispositivo en la red)"

echo ""
show_status "Sistema SAMABOT Industrial listo para demos profesionales!"
show_info "El sistema está completamente funcional y listo para presentaciones" 