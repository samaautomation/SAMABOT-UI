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

echo "🚀 Abriendo SAMABOT UI..."

# Verificar que los servicios estén corriendo
echo "🔍 Verificando servicios..."

# Verificar backend
if ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" > /dev/null 2>&1; then
    echo "✅ Backend SAMABOT: CONECTADO"
else
    echo "❌ Backend SAMABOT: DESCONECTADO"
fi

# Verificar frontend
if ssh samabot@192.168.1.7 "curl -s http://localhost:3000" > /dev/null 2>&1; then
    echo "✅ Frontend SAMABOT: CONECTADO"
else
    echo "❌ Frontend SAMABOT: DESCONECTADO"
fi

echo ""
echo "🌐 Abriendo navegador..."

# Abrir en el navegador del Jetson
ssh samabot@192.168.1.7 "DISPLAY=:0 xdg-open http://localhost:3000" &

# También abrir en el navegador local si es posible
if command -v xdg-open > /dev/null; then
    xdg-open http://192.168.1.7:3000 &
elif command -v open > /dev/null; then
    open http://192.168.1.7:3000 &
fi

echo "✅ SAMABOT UI abierta en:"
echo "   📱 Jetson: http://localhost:3000"
echo "   💻 Local:  http://192.168.1.7:3000"
echo ""
echo "🎯 ¡SAMABOT está listo para usar!" 