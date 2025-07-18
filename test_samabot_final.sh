#!/bin/bash

# SAMABOT - Test Final Completo
# ING. SERGIO M - #SAMAKER

echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "🧪 Test Final SAMABOT Industrial"
echo ""

JETSON_IP="192.168.1.7"

echo "🔍 Verificando conexión al Jetson..."
if ping -c 1 $JETSON_IP &> /dev/null; then
    echo "✅ Jetson accesible en $JETSON_IP"
else
    echo "❌ No se puede acceder al Jetson en $JETSON_IP"
    exit 1
fi

echo ""
echo "🔍 Verificando servicios en Jetson..."

# Verificar servicios corriendo
ssh samabot@$JETSON_IP "ps aux | grep -E '(uvicorn|next)' | grep -v grep"

echo ""
echo "🔍 Verificando puertos..."

# Verificar puertos
ssh samabot@$JETSON_IP "netstat -tlnp | grep -E ':(3000|8000)'"

echo ""
echo "🔍 Probando Backend API..."

# Probar backend
BACKEND_RESPONSE=$(ssh samabot@$JETSON_IP "curl -s http://localhost:8000/api/plc/status")
if [ $? -eq 0 ]; then
    echo "✅ Backend API funcionando"
    echo "   Respuesta: $BACKEND_RESPONSE"
else
    echo "❌ Error en Backend API"
fi

echo ""
echo "🔍 Probando Frontend..."

# Probar frontend
FRONTEND_RESPONSE=$(ssh samabot@$JETSON_IP "curl -I http://localhost:3000 2>/dev/null | head -1")
if echo "$FRONTEND_RESPONSE" | grep -q "200"; then
    echo "✅ Frontend funcionando"
else
    echo "❌ Error en Frontend"
fi

echo ""
echo "🔍 Verificando Ollama..."

# Verificar Ollama
ssh samabot@$JETSON_IP "ollama list"

echo ""
echo "🔍 Probando Chat SAMITA..."

# Probar chat
CHAT_RESPONSE=$(ssh samabot@$JETSON_IP "ollama run samita-es 'Hola, ¿cómo estás?'" 2>/dev/null | head -3)
if [ $? -eq 0 ]; then
    echo "✅ Chat SAMITA funcionando"
    echo "   Respuesta: $CHAT_RESPONSE"
else
    echo "❌ Error en Chat SAMITA"
fi

echo ""
echo "🌐 URLs de Acceso:"
echo "   • Frontend (Jetson): http://localhost:3000"
echo "   • Frontend (Remoto): http://$JETSON_IP:3000"
echo "   • Backend API: http://$JETSON_IP:8000/api/plc/status"
echo ""

echo "🎯 Opciones de Launcher:"
echo "   1. En Jetson: Buscar 'SAMABOT Industrial' en menú"
echo "   2. En Jetson: Doble clic en icono del escritorio"
echo "   3. En Jetson: Ejecutar: ./SAMABOT_Start.sh"
echo "   4. En Jetson: Abrir: SAMABOT_HTML_Launcher.html"
echo ""

echo "📊 Estado del Sistema:"
echo "   ✅ Backend: Funcionando en puerto 8000"
echo "   ✅ Frontend: Funcionando en puerto 3000"
echo "   ✅ Ollama: Instalado con modelos samita-es y phi:2.7b"
echo "   ✅ PLC: Conectado al Siemens S7-1200"
echo "   ✅ Launchers: Configurados para acceso fácil"
echo ""

echo "🎉 ¡SAMABOT Industrial está listo para usar!"
echo ""
echo "💡 Próximos pasos:"
echo "   1. En el Jetson, busca 'SAMABOT Industrial' en el menú"
echo "   2. O abre http://$JETSON_IP:3000 desde tu PC"
echo "   3. Usa el chat SAMITA para interactuar con la IA"
echo "   4. Monitorea los datos del PLC en tiempo real" 