#!/bin/bash

echo "🚀 PREPARANDO ARCHIVOS PARA JETSON"
echo "==================================="
echo ""

# Crear archivo comprimido
echo "📦 Creando archivo comprimido..."
tar -czf samabot-frontend.tar.gz --exclude='node_modules' --exclude='.next' samabot-frontend/

# Crear script de instalación
echo "🔧 Creando script de instalación..."
cat > install_jetson.sh << 'EOF'
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
EOF

chmod +x install_jetson.sh

echo "✅ Archivos creados:"
echo "  - samabot-frontend.tar.gz"
echo "  - install_jetson.sh"
echo ""

echo "📋 INSTRUCCIONES PARA TRANSFERIR:"
echo "================================"
echo ""
echo "1. Copia los archivos al Jetson:"
echo "   scp samabot-frontend.tar.gz install_jetson.sh jetson@192.168.1.7:~/"
echo ""
echo "2. Conecta al Jetson:"
echo "   ssh jetson@192.168.1.7"
echo ""
echo "3. Ejecuta la instalación:"
echo "   ./install_jetson.sh"
echo ""
echo "4. Inicia el frontend:"
echo "   cd samabot-frontend && npm run dev"
echo ""
echo "5. Accede desde cualquier dispositivo:"
echo "   http://192.168.1.7:3000"
echo ""
echo "¡Archivos listos para transferir! 🚀" 