#!/bin/bash

# Comandos útiles para SAMABOT
# Uso: source samabot_commands.sh

# Función para verificar estado del sistema
samabot_status() {
    echo "🔍 Verificando estado del sistema SAMABOT..."
    jetson "ps aux | grep -E '(snap7|next)' | grep -v grep"
    echo ""
    echo "📊 Puertos abiertos:"
    jetson "netstat -tlnp | grep -E '(3000|3001)'"
    echo ""
    echo "🌐 URLs de acceso:"
    echo "Frontend: http://192.168.1.7:3000"
    echo "Backend:  http://192.168.1.7:3001"
}

# Función para ver datos del PLC
samabot_data() {
    echo "📊 Datos del PLC en tiempo real:"
    jetson "curl -s http://localhost:3001/api/plc/real-data | grep -o '\"temperature\":[0-9.]*' | sed 's/\"temperature\":/🌡️  Temperatura: /' | sed 's/$/°C/'"
    jetson "curl -s http://localhost:3001/api/plc/real-data | grep -o '\"pressure\":[0-9.]*' | sed 's/\"pressure\":/📊 Presión: /' | sed 's/$/ bar/'"
    jetson "curl -s http://localhost:3001/api/plc/real-data | grep -o '\"isConnected\":[a-z]*' | sed 's/\"isConnected\":/🔌 Conexión: /'"
    jetson "curl -s http://localhost:3001/api/plc/real-data | grep -o '\"responseTime\":[0-9]*' | sed 's/\"responseTime\":/⚡ Response Time: /' | sed 's/$/ms/'"
}

# Función para reiniciar backend
samabot_restart_backend() {
    echo "🔄 Reiniciando backend..."
    jetson "pkill -f snap7-backend"
    sleep 2
    jetson "cd ~/maker/samabot/backend/snap7 && python3 snap7_backend_improved.py &"
    echo "✅ Backend reiniciado"
}

# Función para ver logs
samabot_logs() {
    echo "📋 Últimos logs del backend:"
    jetson "tail -20 ~/maker/samabot/backend/snap7/snap7-backend.log 2>/dev/null || echo 'No log file found'"
}

# Función para test PLC
samabot_test_plc() {
    echo "🧪 Probando conexión PLC..."
    jetson "cd ~/maker/samabot/backend/snap7 && python3 test_iq_lectura.py"
}

# Función para abrir UI en navegador
samabot_open() {
    echo "🌐 Abriendo SAMABOT UI..."
    xdg-open http://192.168.1.7:3000 2>/dev/null || echo "Navegador no disponible"
}

# Función para monitoreo continuo
samabot_monitor() {
    echo "📈 Monitoreo continuo (Ctrl+C para salir)..."
    while true; do
        clear
        echo "🕐 $(date)"
        echo "=========================================="
        samabot_status
        echo ""
        samabot_data
        echo ""
        echo "⏳ Actualizando en 5 segundos..."
        sleep 5
    done
}

# Función de ayuda
samabot_help() {
    echo "🔧 COMANDOS SAMABOT DISPONIBLES:"
    echo "=================================="
    echo "samabot_status      - Verificar estado del sistema"
    echo "samabot_data        - Ver datos del PLC"
    echo "samabot_restart_backend - Reiniciar backend"
    echo "samabot_logs        - Ver logs del backend"
    echo "samabot_test_plc    - Test de conexión PLC"
    echo "samabot_open        - Abrir UI en navegador"
    echo "samabot_monitor     - Monitoreo continuo"
    echo "samabot_help        - Esta ayuda"
    echo ""
    echo "💡 Acceso directo: jetson 'comando'"
}

# Mostrar ayuda al cargar
echo "🚀 Comandos SAMABOT cargados!"
echo "💡 Usa 'samabot_help' para ver comandos disponibles" 