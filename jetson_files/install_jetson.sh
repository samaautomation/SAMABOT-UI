#!/bin/bash

echo "🤖 INSTALANDO SAMABOT FRONTEND EN JETSON"
echo "=========================================="
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado"
    echo "Instalando Node.js..."
    sudo apt update
    sudo apt install -y nodejs npm
    echo "✅ Node.js instalado"
fi

echo "✅ Node.js: $(node --version)"
echo "✅ npm: $(npm --version)"
echo ""

# Extraer archivos
if [ -f "samabot-frontend.tar.gz" ]; then
    echo "📦 Extrayendo archivos..."
    tar -xzf samabot-frontend.tar.gz
    echo "✅ Archivos extraídos"
else
    echo "❌ Error: samabot-frontend.tar.gz no encontrado"
    exit 1
fi

cd samabot-frontend

echo "📦 Instalando dependencias..."
npm install

echo "🔨 Compilando frontend..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Frontend compilado correctamente"
else
    echo "❌ Error en la compilación"
    exit 1
fi

echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA!"
echo "============================"
echo ""
echo "📍 Ubicación: $(pwd)"
echo "🌐 URL: http://192.168.1.7:3000"
echo ""
echo "🚀 Para iniciar: npm run dev"
echo "🎯 Acceso: http://192.168.1.7:3000"
echo ""
echo "¡Listo para la demostración! 🚀"
