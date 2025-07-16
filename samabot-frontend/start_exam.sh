#!/bin/bash

echo "🤖 SAMABOT INDUSTRIAL - FRONTEND PARA EXAMEN"
echo "=============================================="
echo ""

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js no está instalado"
    echo "Instala Node.js desde: https://nodejs.org/"
    exit 1
fi

# Verificar si npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm no está instalado"
    exit 1
fi

echo "✅ Node.js y npm detectados"
echo ""

# Instalar dependencias si no están instaladas
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
    echo ""
fi

echo "🚀 Iniciando SAMABOT Frontend..."
echo "📍 URL: http://localhost:3000"
echo "⏰ Hora de inicio: $(date)"
echo ""
echo "📋 INSTRUCCIONES PARA EL EXAMEN:"
echo "1. El frontend se abrirá automáticamente en tu navegador"
echo "2. Si no se abre, ve a: http://localhost:3000"
echo "3. La interfaz muestra el estado del PLC en tiempo real"
echo "4. Samita AI está representada por el emoji robot 🤖"
echo "5. Los datos se actualizan cada 2 segundos"
echo ""
echo "🛑 Para detener: Ctrl+C"
echo ""

# Iniciar el servidor de desarrollo
npm run dev 