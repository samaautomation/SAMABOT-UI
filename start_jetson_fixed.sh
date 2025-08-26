#!/bin/bash

echo "🤖 SAMABOT INDUSTRIAL - JETSON NANO"
echo "====================================="
echo ""

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js no está instalado"
    echo "Instala Node.js: sudo apt update && sudo apt install nodejs npm"
    exit 1
fi

echo "✅ Node.js detectado"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json"
    echo "Asegúrate de estar en el directorio del frontend"
    exit 1
fi

# Instalar dependencias si no están
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
    echo ""
fi

# Verificar si ya está compilado
if [ ! -d ".next" ]; then
    echo "🔨 Compilando frontend..."
    npm run build
    if [ $? -ne 0 ]; then
        echo "⚠️  Intentando compilar sin linting..."
        npm run build -- --no-lint
    fi
    echo ""
fi

echo "🚀 Iniciando SAMABOT Frontend en Jetson..."
echo "📍 URL: http://192.168.1.7:3000"
echo "⏰ Hora de inicio: $(date)"
echo ""
echo "📋 INSTRUCCIONES PARA DEMOSTRACIÓN:"
echo "1. El frontend estará disponible en: http://192.168.1.7:3000"
echo "2. Puedes acceder desde cualquier dispositivo en la red"
echo "3. La interfaz muestra el estado del PLC en tiempo real"
echo "4. Samita AI está representada por el emoji robot 🤖"
echo "5. Los datos se actualizan cada 2 segundos"
echo ""
echo "🛑 Para detener: Ctrl+C"
echo ""

# Iniciar el servidor de desarrollo
npm run dev 