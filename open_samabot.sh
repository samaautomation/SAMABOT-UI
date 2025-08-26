#!/bin/bash

# SAMABOT Quick Launch Script
# Abre SAMABOT en el navegador

echo "🚀 Abriendo SAMABOT Industrial..."

# Verificar si el frontend está corriendo
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend detectado en http://localhost:3000"
    
    # Abrir navegador
    if command -v xdg-open > /dev/null; then
        xdg-open http://localhost:3000
    elif command -v open > /dev/null; then
        open http://localhost:3000
    elif command -v start > /dev/null; then
        start http://localhost:3000
    else
        echo "⚠️  No se pudo abrir el navegador automáticamente"
        echo "🌐 Abre manualmente: http://localhost:3000"
    fi
else
    echo "❌ Frontend no está corriendo"
    echo "💡 Ejecuta primero: ./start_samabot.sh"
fi 