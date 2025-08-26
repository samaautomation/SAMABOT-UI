#!/bin/bash

# SAMABOT Status Script
# Muestra el estado completo del sistema SAMABOT

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SAMABOT STATUS                            ║"
echo "║                Estado del Sistema Industrial                 ║"
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

# Función para mostrar información de red
show_network_info() {
    echo "🌐 Información de Red:"
    echo "   Laptop: $(hostname -I | awk '{print $1}')"
    echo "   Jetson: 192.168.1.7"
    echo "   PLC: 192.168.1.5"
    echo ""
}

# Función para verificar conectividad
check_connectivity() {
    show_section "Verificando Conectividad"
    
    # Verificar Jetson
    if ping -c 1 192.168.1.7 > /dev/null 2>&1; then
        show_status "Jetson Nano (192.168.1.7) - Conectado"
    else
        show_error "Jetson Nano (192.168.1.7) - No accesible"
    fi
    
    # Verificar PLC
    if ping -c 1 192.168.1.5 > /dev/null 2>&1; then
        show_status "PLC Siemens (192.168.1.5) - Conectado"
    else
        show_error "PLC Siemens (192.168.1.5) - No accesible"
    fi
    
    echo ""
}

# Función para verificar backend
check_backend() {
    show_section "Estado del Backend"
    
    # Verificar backend del Jetson
    if curl -s http://192.168.1.7:8000/ > /dev/null 2>&1; then
        show_status "Backend del Jetson - Funcionando"
        
        # Obtener estado del PLC
        PLC_STATUS=$(curl -s http://192.168.1.7:8000/status 2>/dev/null)
        if [ ! -z "$PLC_STATUS" ]; then
            echo "   📊 Estado del PLC:"
            echo "$PLC_STATUS" | jq -r '.connectionQuality + " - " + .ip' 2>/dev/null || echo "   Conectado a $(echo "$PLC_STATUS" | jq -r '.ip' 2>/dev/null)"
        fi
    else
        show_error "Backend del Jetson - No disponible"
    fi
    
    # Verificar backend local
    if curl -s http://localhost:8000/ > /dev/null 2>&1; then
        show_status "Backend Local - Funcionando"
    else
        show_info "Backend Local - No disponible"
    fi
    
    echo ""
}

# Función para verificar frontend
check_frontend() {
    show_section "Estado del Frontend"
    
    # Verificar frontend en puerto 3000
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        show_status "Frontend (puerto 3000) - Funcionando"
    else
        show_info "Frontend (puerto 3000) - No disponible"
    fi
    
    # Verificar frontend en puerto 3001
    if curl -s http://localhost:3001 > /dev/null 2>&1; then
        show_status "Frontend (puerto 3001) - Funcionando"
    else
        show_info "Frontend (puerto 3001) - No disponible"
    fi
    
    echo ""
}

# Función para mostrar procesos
show_processes() {
    show_section "Procesos Activos"
    
    # Procesos de uvicorn
    UVICORN_PROCESSES=$(ps aux | grep uvicorn | grep -v grep | wc -l)
    if [ $UVICORN_PROCESSES -gt 0 ]; then
        show_status "Procesos uvicorn: $UVICORN_PROCESSES"
    else
        show_info "No hay procesos uvicorn activos"
    fi
    
    # Procesos de Next.js
    NEXT_PROCESSES=$(ps aux | grep "next dev" | grep -v grep | wc -l)
    if [ $NEXT_PROCESSES -gt 0 ]; then
        show_status "Procesos Next.js: $NEXT_PROCESSES"
    else
        show_info "No hay procesos Next.js activos"
    fi
    
    echo ""
}

# Función para mostrar información del sistema
show_system_info() {
    show_section "Información del Sistema"
    
    echo "🖥️  Sistema: $(uname -s) $(uname -r)"
    echo "💾 Memoria: $(free -h | awk 'NR==2{printf "%.1f/%.1f GB", $3/1024, $2/1024}')"
    echo "💿 Disco: $(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 ")"}')"
    echo "⏰ Hora: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

# Función para mostrar URLs de acceso
show_access_urls() {
    show_section "URLs de Acceso"
    
    echo "🌐 Frontend:"
    echo "   http://localhost:3000"
    echo "   http://localhost:3001"
    echo ""
    echo "🔧 Backend:"
    echo "   http://192.168.1.7:8000"
    echo "   http://localhost:8000"
    echo ""
    echo "📚 Documentación API:"
    echo "   http://192.168.1.7:8000/docs"
    echo "   http://localhost:8000/docs"
    echo ""
}

# Función para mostrar comandos útiles
show_useful_commands() {
    show_section "Comandos Útiles"
    
    echo "🚀 Iniciar sistema completo:"
    echo "   ./start_samabot.sh"
    echo ""
    echo "⚡ Inicio rápido del backend:"
    echo "   ./jetson_quick_start.sh"
    echo ""
    echo "🌐 Abrir navegador:"
    echo "   ./open_samabot.sh"
    echo ""
    echo "🛑 Detener backend en Jetson:"
    echo "   ssh samabot@192.168.1.7 'pkill -f uvicorn'"
    echo ""
}

# Ejecutar todas las verificaciones
show_network_info
check_connectivity
check_backend
check_frontend
show_processes
show_system_info
show_access_urls
show_useful_commands

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SAMABOT STATUS COMPLETO                   ║"
echo "╚══════════════════════════════════════════════════════════════╝" 