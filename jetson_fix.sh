#!/bin/bash

# Script simple para solucionar scroll infinito en Jetson
# Edita la contraseña abajo antes de ejecutar

JETSON_IP="192.168.1.7"
JETSON_USER="samabot"
JETSON_PASS="samita2307"

echo "🔧 Solucionando scroll infinito en Jetson..."
echo ""

# Detener procesos problemáticos
echo "🛑 Deteniendo procesos..."
sshpass -p "$JETSON_PASS" ssh -o StrictHostKeyChecking=no $JETSON_USER@$JETSON_IP << 'EOF'
pkill -f 'python.*app.py'
pkill -f 'npm.*start'
pkill -f 'node.*next'
pkill -f 'chromium'
pkill -f 'firefox'
pkill -f 'python.*flask'
clear
echo "✅ Procesos detenidos"
echo ""
echo "📊 Procesos activos:"
ps aux | grep -E '(python|node|npm|chromium|firefox)' | grep -v grep || echo "No hay procesos activos"
echo ""
echo "💾 Memoria disponible:"
free -h
echo ""
echo "🌡️ Temperatura:"
cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{print $1/1000 "°C"}' || echo "No disponible"
EOF

echo ""
echo "✅ Diagnóstico completado."
echo ""
echo "📝 Para reiniciar el sistema:"
echo "ssh sergio@192.168.1.7"
echo "cd ~/SAMABOT-UI"
echo "python backend/app.py &"
echo "cd frontend && npm start &"
echo "firefox http://localhost:3000 &" 