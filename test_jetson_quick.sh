#!/bin/bash

# SAMABOT - Test Rápido Jetson
# ING. SERGIO M - #SAMAKER

echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "🧪 Test Rápido Jetson"
echo ""

JETSON_USER="samabot"
JETSON_IP="192.168.1.7"

echo "🔍 Verificando conexión SSH..."
if ssh -o ConnectTimeout=5 $JETSON_USER@$JETSON_IP "echo '✅ SSH OK'" 2>/dev/null; then
    echo "✅ Conexión SSH establecida"
else
    echo "❌ Error de conexión SSH"
    echo "🔧 Verifica:"
    echo "   - IP: $JETSON_IP"
    echo "   - Usuario: $JETSON_USER"
    echo "   - SSH habilitado"
    exit 1
fi

echo ""
echo "🔍 Verificando servicios..."
ssh $JETSON_USER@$JETSON_IP "sudo systemctl status samabot-backend --no-pager | head -5"
ssh $JETSON_USER@$JETSON_IP "sudo systemctl status samabot-frontend --no-pager | head -5"

echo ""
echo "🔍 Verificando puertos..."
ssh $JETSON_USER@$JETSON_IP "netstat -tlnp | grep -E ':(3000|3001)'"

echo ""
echo "🔍 Verificando Ollama..."
ssh $JETSON_USER@$JETSON_IP "ollama list"

echo ""
echo "🔍 Verificando archivos del proyecto..."
ssh $JETSON_USER@$JETSON_IP "ls -la ~/SAMABOT-UI/"

echo ""
echo "🌐 URLs de acceso:"
echo "   Frontend: http://$JETSON_IP:3000"
echo "   Backend:  http://$JETSON_IP:3001"

echo ""
echo "📋 Comandos de control:"
echo "   ssh $JETSON_USER@$JETSON_IP"
echo "   cd ~/SAMABOT-UI"
echo "   ./start_samabot.sh"
echo "   ./stop_samabot.sh"
echo "   ./status_samabot.sh"

echo ""
echo "✅ Test completado" 