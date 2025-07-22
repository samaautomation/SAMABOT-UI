#!/bin/bash

# Script para corregir la conexión del frontend al backend del Jetson
# SAMABOT Industrial - Fix PLC Connection

echo "🔧 SAMABOT - Corrigiendo conexión PLC Frontend-Backend"
echo "=================================================="

# Verificar conectividad con Jetson
echo "📡 Verificando conectividad con Jetson..."
if ping -c 1 192.168.1.7 &> /dev/null; then
    echo "✅ Jetson accesible"
else
    echo "❌ Jetson no accesible desde esta red"
    echo "💡 Ejecuta este script desde la misma red que el Jetson"
    exit 1
fi

# Conectar al Jetson y hacer los cambios
echo "🔗 Conectando al Jetson para aplicar correcciones..."

ssh samabot@192.168.1.7 << 'EOF'
echo "🔄 Aplicando corrección en Jetson..."

# Navegar al directorio del frontend
cd ~/maker/samabot/frontend/src/components/ui/

# Hacer backup del archivo original
cp PLCPanel.tsx PLCPanel.tsx.backup

# Aplicar la corrección usando sed
sed -i 's|http://localhost:8000/plc/status|http://192.168.1.7:8000/status|g' PLCPanel.tsx

# Verificar que el cambio se aplicó
if grep -q "192.168.1.7:8000/status" PLCPanel.tsx; then
    echo "✅ Corrección aplicada exitosamente"
else
    echo "❌ Error al aplicar corrección"
    exit 1
fi

# Reiniciar el frontend
echo "🔄 Reiniciando frontend..."
cd ~/maker/samabot/frontend
pkill -f "npm run dev" || true
sleep 2
npm run dev > frontend.log 2>&1 &

echo "✅ Frontend reiniciado"
echo "🌐 URL del frontend: http://192.168.1.7:3000"
echo "🔧 URL del backend: http://192.168.1.7:8000"
EOF

echo ""
echo "🎉 ¡Corrección completada!"
echo "📱 Abre http://192.168.1.7:3000 en tu navegador"
echo "🔍 Verifica que ahora muestra datos reales del PLC"
echo ""
echo "📋 Para verificar el estado:"
echo "   ssh samabot@192.168.1.7 'curl http://localhost:8000/status'" 