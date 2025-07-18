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

echo "🧪 Probando SAMABOT en Jetson..."
echo ""

# Verificar servicios
echo "🔍 Verificando servicios..."

# Backend
echo "📡 Backend (puerto 3001):"
if ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" > /dev/null 2>&1; then
    echo "   ✅ CONECTADO"
    BACKEND_STATUS=$(ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    echo "   📊 Estado PLC: $BACKEND_STATUS"
else
    echo "   ❌ DESCONECTADO"
fi

# Frontend
echo "🌐 Frontend (puerto 3000):"
if ssh samabot@192.168.1.7 "curl -s http://localhost:3000" > /dev/null 2>&1; then
    echo "   ✅ CONECTADO"
else
    echo "   ❌ DESCONECTADO"
fi

# Ollama
echo "🤖 Ollama:"
if ssh samabot@192.168.1.7 "ollama list | grep samita-es" > /dev/null 2>&1; then
    echo "   ✅ Modelo samita-es disponible"
else
    echo "   ❌ Modelo samita-es no encontrado"
fi

echo ""

# Probar endpoints del frontend
echo "🔗 Probando endpoints del frontend..."

echo "📊 /api/plc/status:"
FRONTEND_STATUS=$(ssh samabot@192.168.1.7 "curl -s http://localhost:3000/api/plc/status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
echo "   Estado: $FRONTEND_STATUS"

echo "📈 /api/plc/real-data:"
if ssh samabot@192.168.1.7 "curl -s http://localhost:3000/api/plc/real-data" | grep -q '"success":true'; then
    echo "   ✅ Datos disponibles"
else
    echo "   ❌ Error obteniendo datos"
fi

echo "💬 /api/chat:"
if ssh samabot@192.168.1.7 "curl -s -X POST http://localhost:3000/api/chat -H 'Content-Type: application/json' -d '{\"message\":\"Hola\"}'" | grep -q '"success":true'; then
    echo "   ✅ SAMITA AI responde"
else
    echo "   ❌ Error en SAMITA AI"
fi

echo ""

# Abrir navegador
echo "🌐 Abriendo SAMABOT UI en el Jetson..."
ssh samabot@192.168.1.7 "DISPLAY=:0 xdg-open http://localhost:3000" &

echo ""
echo "✅ SAMABOT está listo para usar!"
echo "📱 Jetson: http://localhost:3000"
echo "💻 Local:  http://192.168.1.7:3000"
echo ""
echo "🎯 ¡Prueba la interfaz y el chat con SAMITA!" 