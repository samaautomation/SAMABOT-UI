#!/bin/bash

echo "🎯 SAMABOT FRONTEND PARA EXAMEN"
echo "================================"
echo ""

# Verificar si estamos en el directorio correcto
if [ ! -d "samabot-frontend" ]; then
    echo "❌ Error: No se encuentra samabot-frontend"
    echo "Ejecuta este script desde el directorio SAMABOT-UI"
    exit 1
fi

cd samabot-frontend

echo "📦 Verificando dependencias..."
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
fi

echo "🔨 Compilando frontend..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Frontend compilado correctamente"
else
    echo "❌ Error en la compilación"
    exit 1
fi

echo ""
echo "🎉 ¡FRONTEND LISTO PARA EXAMEN!"
echo "================================"
echo ""
echo "🚀 Iniciando servidor..."
echo "📍 URL: http://localhost:3000"
echo "🌐 Red: http://192.168.1.23:3000"
echo ""
echo "📋 CARACTERÍSTICAS DISPONIBLES:"
echo "✅ Interfaz SAMABOT Industrial"
echo "✅ Samita AI con robot animado"
echo "✅ Estado del PLC en tiempo real"
echo "✅ Diseño responsive y profesional"
echo "✅ Actualización automática cada 2 segundos"
echo ""
echo "🎯 PARA LA DEMOSTRACIÓN:"
echo "1. Abre http://localhost:3000"
echo "2. Muestra la interfaz profesional"
echo "3. Explica que es para Jetson Nano"
echo "4. Demuestra el monitoreo en tiempo real"
echo ""
echo "🛑 Para detener: Ctrl+C"
echo ""

# Iniciar el servidor
npm run dev 