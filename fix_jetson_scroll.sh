#!/bin/bash

# Script para solucionar scroll infinito en Jetson
JETSON_IP="192.168.1.7"
JETSON_USER="sergio"

echo "🔧 Solucionando scroll infinito en Jetson..."
echo "IP: $JETSON_IP"
echo "Usuario: $JETSON_USER"
echo ""

# Función para ejecutar comandos en Jetson
run_on_jetson() {
    local cmd="$1"
    echo "📋 Ejecutando: $cmd"
    sshpass -p "TU_CONTRASEÑA_AQUI" ssh -o StrictHostKeyChecking=no $JETSON_USER@$JETSON_IP "$cmd"
}

echo "🛑 Deteniendo todos los procesos problemáticos..."
run_on_jetson "pkill -f 'python.*app.py'"
run_on_jetson "pkill -f 'npm.*start'"
run_on_jetson "pkill -f 'node.*next'"
run_on_jetson "pkill -f 'chromium'"
run_on_jetson "pkill -f 'firefox'"
run_on_jetson "pkill -f 'python.*flask'"

echo "🧹 Limpiando terminal..."
run_on_jetson "clear"

echo "📊 Verificando procesos activos..."
run_on_jetson "ps aux | grep -E '(python|node|npm|chromium|firefox)' | grep -v grep"

echo "🔍 Verificando puertos en uso..."
run_on_jetson "netstat -tlnp | grep -E ':(3000|5000|8000)'"

echo "💾 Verificando uso de memoria..."
run_on_jetson "free -h"

echo "🌡️ Verificando temperatura del sistema..."
run_on_jetson "cat /sys/class/thermal/thermal_zone*/temp"

echo "✅ Diagnóstico completado."
echo ""
echo "📝 Para reiniciar el sistema correctamente:"
echo "1. Ejecuta: ssh sergio@192.168.1.7"
echo "2. Ve al directorio: cd ~/SAMABOT-UI"
echo "3. Inicia backend: python backend/app.py &"
echo "4. Inicia frontend: cd frontend && npm start &"
echo "5. Abre navegador: firefox http://localhost:3000 &" 