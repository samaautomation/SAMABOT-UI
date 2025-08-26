#!/bin/bash

echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "📅 $(date '+%A %d/%m/%Y') ⏰ $(date '+%H:%M:%S')"
echo "💡 Build. Break. Repeat."
echo ""

echo "🚀 Iniciando SAMABOT Industrial en Jetson..."
echo ""

# Función para matar procesos existentes
kill_existing_processes() {
    echo "🔧 Deteniendo procesos existentes..."
    ssh samabot@192.168.1.7 "pkill -f 'snap7_backend_improved.py' 2>/dev/null || true"
    ssh samabot@192.168.1.7 "pkill -f 'next dev' 2>/dev/null || true"
    ssh samabot@192.168.1.7 "pkill -f 'npm run dev' 2>/dev/null || true"
    sleep 2
}

# Función para verificar servicios
check_services() {
    echo "🔍 Verificando servicios..."
    
    # Verificar Ollama
    if ssh samabot@192.168.1.7 "ollama list | grep samita-es" > /dev/null 2>&1; then
        echo "✅ Ollama: Modelo samita-es disponible"
    else
        echo "❌ Ollama: Modelo samita-es no encontrado"
        echo "   Ejecuta: ssh samabot@192.168.1.7 'ollama pull samita-es'"
    fi
    
    # Verificar Python y dependencias
    if ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/backend && source venv/bin/activate && python -c 'import flask, flask_cors, snap7'" > /dev/null 2>&1; then
        echo "✅ Python: Dependencias instaladas"
    else
        echo "❌ Python: Faltan dependencias"
        echo "   Ejecuta: ssh samabot@192.168.1.7 'cd /home/samabot/SAMABOT-UI/backend && source venv/bin/activate && pip install flask flask-cors python-snap7'"
    fi
    
    # Verificar Node.js
    if ssh samabot@192.168.1.7 "node --version" > /dev/null 2>&1; then
        echo "✅ Node.js: Disponible"
    else
        echo "❌ Node.js: No disponible"
    fi
}

# Función para iniciar backend
start_backend() {
    echo ""
    echo "📡 Iniciando Backend SAMABOT..."
    ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/backend && source venv/bin/activate && nohup python snap7_backend_improved.py > backend.log 2>&1 &"
    sleep 3
    
    # Verificar que el backend esté corriendo
    if ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" > /dev/null 2>&1; then
        echo "✅ Backend: Conectado al PLC (puerto 3001)"
    else
        echo "❌ Backend: Error al conectar"
        echo "   Revisa: ssh samabot@192.168.1.7 'tail -f /home/samabot/SAMABOT-UI/backend/backend.log'"
    fi
}

# Función para iniciar frontend
start_frontend() {
    echo ""
    echo "🌐 Iniciando Frontend SAMABOT..."
    ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/samabot-frontend && nohup npm run dev > frontend.log 2>&1 &"
    sleep 10
    
    # Verificar que el frontend esté corriendo
    if ssh samabot@192.168.1.7 "curl -s http://localhost:3000" > /dev/null 2>&1; then
        echo "✅ Frontend: Conectado (puerto 3000)"
    else
        echo "❌ Frontend: Error al conectar"
        echo "   Revisa: ssh samabot@192.168.1.7 'tail -f /home/samabot/SAMABOT-UI/samabot-frontend/frontend.log'"
    fi
}

# Función para probar endpoints
test_endpoints() {
    echo ""
    echo "🧪 Probando endpoints..."
    
    # Probar backend
    echo "📊 Backend /api/plc/status:"
    BACKEND_STATUS=$(ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    echo "   Estado PLC: $BACKEND_STATUS"
    
    # Probar frontend
    echo "📊 Frontend /api/plc/status:"
    FRONTEND_STATUS=$(ssh samabot@192.168.1.7 "curl -s http://localhost:3000/api/plc/status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    echo "   Estado PLC: $FRONTEND_STATUS"
    
    # Probar SAMITA AI
    echo "💬 SAMITA AI /api/chat:"
    if ssh samabot@192.168.1.7 "curl -s -X POST http://localhost:3000/api/chat -H 'Content-Type: application/json' -d '{\"message\":\"Hola\"}'" | grep -q '"success":true'; then
        echo "   ✅ SAMITA AI responde"
    else
        echo "   ❌ Error en SAMITA AI"
    fi
}

# Función para abrir navegador
open_browser() {
    echo ""
    echo "🌐 Abriendo SAMABOT UI..."
    ssh samabot@192.168.1.7 "DISPLAY=:0 xdg-open http://localhost:3000" &
    
    echo ""
    echo "✅ SAMABOT está listo para usar!"
    echo "📱 Jetson: http://localhost:3000"
    echo "💻 Local:  http://192.168.1.7:3000"
    echo ""
    echo "🎯 ¡Prueba la interfaz y el chat con SAMITA!"
}

# Función para mostrar logs
show_logs() {
    echo ""
    echo "📋 Comandos útiles para monitorear:"
    echo "   Backend logs: ssh samabot@192.168.1.7 'tail -f /home/samabot/SAMABOT-UI/backend/backend.log'"
    echo "   Frontend logs: ssh samabot@192.168.1.7 'tail -f /home/samabot/SAMABOT-UI/samabot-frontend/frontend.log'"
    echo "   Procesos: ssh samabot@192.168.1.7 'ps aux | grep -E \"(python|node|next)\"'"
    echo "   Detener todo: ssh samabot@192.168.1.7 'pkill -f \"(snap7_backend_improved|next dev)\"'"
}

# Ejecutar funciones
kill_existing_processes
check_services
start_backend
start_frontend
test_endpoints
open_browser
show_logs 