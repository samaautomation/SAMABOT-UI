#!/bin/bash

# SAMABOT - Desktop Launcher
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

# Detener servicios existentes
echo "🛑 Deteniendo servicios existentes..."
pkill -f "python.*snap7" 2>/dev/null
pkill -f "npm.*dev" 2>/dev/null
pkill -f "next" 2>/dev/null

sleep 2

# Iniciar Backend en nueva terminal
echo "🔧 Iniciando Backend..."
gnome-terminal --title="SAMABOT Backend" -- bash -c "
cd /home/samabot/SAMABOT-UI/backend
source venv/bin/activate
echo '🚀 Backend SAMABOT iniciado en puerto 3001'
echo '📊 API: http://localhost:3001/api/plc/status'
python snap7_backend_improved.py
"

sleep 3

# Iniciar Frontend en nueva terminal
echo "🌐 Iniciando Frontend..."
gnome-terminal --title="SAMABOT Frontend" -- bash -c "
cd /home/samabot/SAMABOT-UI/samabot-frontend
echo '🌐 Frontend SAMABOT iniciando...'
echo '📱 UI: http://localhost:3000'
npm run dev
"

sleep 5

# Abrir navegador
echo "🌐 Abriendo navegador..."
if command -v firefox &> /dev/null; then
    firefox http://localhost:3000 &
elif command -v chromium-browser &> /dev/null; then
    chromium-browser http://localhost:3000 &
else
    echo "❌ No se encontró navegador. Abre manualmente: http://localhost:3000"
fi

echo ""
echo "🎉 ¡SAMABOT Industrial está listo!"
echo ""
echo "📊 URLs de Acceso:"
echo "   • Frontend: http://localhost:3000"
echo "   • Backend API: http://localhost:3001/api/plc/status"
echo ""
echo "💡 Para detener: Cierra las terminales o ejecuta ./stop_samabot.sh"
echo ""
echo "🤖 Chat SAMITA: Usa el panel de chat en la interfaz"
echo "📈 PLC Status: Ve el estado del PLC en tiempo real" 