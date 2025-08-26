#!/bin/bash

echo "🚀 INICIANDO SAMABOT FRONTEND EN JETSON"
echo "========================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No se encontró package.json"
    echo "Asegúrate de estar en el directorio del frontend"
    exit 1
fi

echo "✅ Directorio correcto detectado"
echo ""

# Instalar dependencias si no están
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
    echo ""
fi

# Compilar si no está compilado
if [ ! -d ".next" ]; then
    echo "🔨 Compilando frontend..."
    npm run build -- --no-lint
    echo ""
fi

echo "🚀 Iniciando servidor..."
echo "📍 URL: http://192.168.1.7:3000"
echo ""

# Iniciar el servidor
npm run dev 