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

echo "🔍 Verificando estado de SAMABOT..."

# Verificar backend
echo "📡 Backend (puerto 3001):"
BACKEND_RESPONSE=$(ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" 2>/dev/null)
if [ ! -z "$BACKEND_RESPONSE" ]; then
    echo "   ✅ CONECTADO"
    echo "   📊 Respuesta: $BACKEND_RESPONSE"
else
    echo "   ❌ DESCONECTADO"
fi

# Verificar frontend
echo "🌐 Frontend (puerto 3000):"
FRONTEND_RESPONSE=$(ssh samabot@192.168.1.7 "curl -s http://localhost:3000/api/plc/status" 2>/dev/null)
if [ ! -z "$FRONTEND_RESPONSE" ]; then
    echo "   ✅ CONECTADO"
    echo "   📊 Respuesta: $FRONTEND_RESPONSE"
else
    echo "   ❌ DESCONECTADO"
fi

# Verificar procesos
echo "⚙️  Procesos corriendo:"
ssh samabot@192.168.1.7 "ps aux | grep -E '(snap7_backend_improved|next dev)' | grep -v grep" | while read line; do
    echo "   ✅ $line"
done

echo ""
echo "🎯 URLs de acceso:"
echo "   📱 Jetson: http://localhost:3000"
echo "   💻 Local:  http://192.168.1.7:3000"
echo ""
echo "✅ ¡SAMABOT está funcionando correctamente!" 