#!/bin/bash

# Script para reiniciar limpiamente SAMABOT en Jetson
# Edita la contraseña abajo antes de ejecutar

JETSON_IP="192.168.1.7"
JETSON_USER="samabot"
JETSON_PASS="samita2307"

echo "🚀 Reiniciando SAMABOT en Jetson..."
echo ""

# Reiniciar sistema SAMABOT
sshpass -p "$JETSON_PASS" ssh -o StrictHostKeyChecking=no $JETSON_USER@$JETSON_IP << 'EOF'
echo "🛑 Deteniendo procesos anteriores..."
pkill -f 'python.*app.py'
pkill -f 'npm.*start'
pkill -f 'node.*next'
pkill -f 'chromium'
pkill -f 'firefox'
sleep 2

echo "🧹 Limpiando terminal..."
clear

echo "📁 Navegando al directorio SAMABOT-UI..."
cd ~/maker/samabot

echo "🐍 Iniciando backend Flask..."
python backend/app.py > backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend iniciado con PID: $BACKEND_PID"

echo "⏳ Esperando 3 segundos..."
sleep 3

echo "🌐 Iniciando frontend Next.js..."
cd frontend
npm start > frontend.log 2>&1 &
FRONTEND_PID=$!
echo "Frontend iniciado con PID: $FRONTEND_PID"

echo "⏳ Esperando 10 segundos para que todo se inicie..."
sleep 10

echo "🌍 Abriendo navegador..."
firefox http://localhost:3000 > /dev/null 2>&1 &

echo "✅ Sistema SAMABOT reiniciado correctamente!"
echo ""
echo "📊 Estado del sistema:"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "🔍 Verificando puertos:"
netstat -tlnp | grep -E ':(3000|5000|8000)' || echo "Puertos no disponibles aún"
echo ""
echo "💾 Memoria disponible:"
free -h
echo ""
echo "🌡️ Temperatura:"
cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{print $1/1000 "°C"}' || echo "No disponible"
EOF

echo ""
echo "✅ Reinicio completado."
echo "🌐 Accede a: http://192.168.1.7:3000" 