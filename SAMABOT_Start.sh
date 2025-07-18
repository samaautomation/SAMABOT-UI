#!/bin/bash

# SAMABOT - Launcher Automático
# ING. SERGIO M - #SAMAKER

echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "🚀 Iniciando SAMABOT Industrial..."
echo ""

# Variables
PROJECT_DIR="/home/samabot/SAMABOT-UI"
BACKEND_PORT=8000
FRONTEND_PORT=3000

# Función para verificar si un puerto está en uso
check_port() {
    local port=$1
    if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
        return 0
    else
        return 1
    fi
}

# Función para esperar hasta que un servicio esté listo
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Esperando que $service_name esté listo..."
    
    while [ $attempt -le $max_attempts ]; do
        if check_port $port; then
            echo "✅ $service_name está listo en puerto $port"
            return 0
        fi
        
        echo "   Intento $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done
    
    echo "❌ $service_name no se inició en el tiempo esperado"
    return 1
}

# Verificar si los servicios ya están corriendo
echo "🔍 Verificando servicios existentes..."

if check_port $BACKEND_PORT; then
    echo "✅ Backend ya está corriendo en puerto $BACKEND_PORT"
else
    echo "🚀 Iniciando Backend..."
    cd $PROJECT_DIR/backend
    source venv/bin/activate
    python snap7_backend_improved.py &
    sleep 3
fi

if check_port $FRONTEND_PORT; then
    echo "✅ Frontend ya está corriendo en puerto $FRONTEND_PORT"
else
    echo "🚀 Iniciando Frontend..."
    cd $PROJECT_DIR/samabot-frontend
    npm run dev &
    sleep 5
fi

# Esperar a que los servicios estén listos
wait_for_service $BACKEND_PORT "Backend"
wait_for_service $FRONTEND_PORT "Frontend"

# Verificar Ollama
echo "🤖 Verificando Ollama..."
if command -v ollama &> /dev/null; then
    echo "✅ Ollama está instalado"
    ollama list
else
    echo "❌ Ollama no está instalado"
fi

# Abrir navegador
echo ""
echo "🌐 Abriendo SAMABOT en el navegador..."
echo "   URL: http://localhost:3000"
echo ""

# Intentar diferentes navegadores
if command -v firefox &> /dev/null; then
    firefox http://localhost:3000 &
elif command -v chromium-browser &> /dev/null; then
    chromium-browser http://localhost:3000 &
elif command -v google-chrome &> /dev/null; then
    google-chrome http://localhost:3000 &
else
    echo "❌ No se encontró ningún navegador instalado"
    echo "   Abre manualmente: http://localhost:3000"
fi

echo ""
echo "🎉 ¡SAMABOT Industrial está listo!"
echo "📊 Panel de Control: http://localhost:3000"
echo "🔧 API Backend: http://localhost:8000"
echo "🤖 Chat SAMITA: Usa el chat en la interfaz"
echo ""
echo "💡 Para detener los servicios: ./stop_samabot.sh"
echo "📊 Para ver estado: ./status_samabot.sh"

# Mantener el script corriendo para mostrar logs
echo ""
echo "📋 Logs en tiempo real (Ctrl+C para salir):"
echo "=========================================="
tail -f $PROJECT_DIR/backend/app.log 2>/dev/null || echo "No hay logs disponibles" 