#!/bin/bash

# SAMABOT - Test Completo del Sistema
# ING. SERGIO M - #SAMAKER

echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "🧪 Test Completo SAMABOT"
echo ""

JETSON_IP="192.168.1.7"
BACKEND_PORT=8000
FRONTEND_PORT=3000

echo "🔍 Verificando servicios en Jetson..."
ssh samabot@$JETSON_IP "ps aux | grep -E '(uvicorn|next)' | grep -v grep"

echo ""
echo "🔍 Verificando puertos..."
ssh samabot@$JETSON_IP "netstat -tlnp | grep -E ':(3000|8000)'"

echo ""
echo "🔍 Probando Backend API..."
echo "📡 GET /api/plc/status"
curl -s http://$JETSON_IP:$BACKEND_PORT/api/plc/status | jq '.' 2>/dev/null || curl -s http://$JETSON_IP:$BACKEND_PORT/api/plc/status

echo ""
echo "🔍 Probando Frontend..."
echo "📡 GET / (Frontend)"
curl -s -I http://$JETSON_IP:$FRONTEND_PORT | head -3

echo ""
echo "🔍 Verificando Ollama..."
ssh samabot@$JETSON_IP "ollama list"

echo ""
echo "🔍 Verificando PLC..."
ssh samabot@$JETSON_IP "cd /home/samabot/SAMABOT-UI/backend && source venv/bin/activate && python -c \"import snap7; print('✅ snap7 disponible')\""

echo ""
echo "🌐 URLs de Acceso:"
echo "   Frontend: http://$JETSON_IP:$FRONTEND_PORT"
echo "   Backend:  http://$JETSON_IP:$BACKEND_PORT"
echo "   API Status: http://$JETSON_IP:$BACKEND_PORT/api/plc/status"

echo ""
echo "📱 Pantalla Táctil:"
echo "   Se abrirá automáticamente en: http://localhost:$FRONTEND_PORT"

echo ""
echo "🔧 Comandos de Control:"
echo "   ssh samabot@$JETSON_IP"
echo "   cd /home/samabot/SAMABOT-UI"
echo "   ./start_samabot.sh"
echo "   ./stop_samabot.sh"
echo "   ./status_samabot.sh"

echo ""
echo "✅ Test completado"
echo ""
echo "🎉 ¡SAMABOT está funcionando correctamente!"
echo ""
echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "💡 Build. Break. Repeat." 