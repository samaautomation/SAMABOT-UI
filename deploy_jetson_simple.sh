#!/bin/bash

echo "🚀 DEPLOY SAMABOT FRONTEND EN JETSON"
echo "======================================"
echo ""

# Configuración
JETSON_IP="192.168.1.7"
JETSON_USER="jetson"
JETSON_PATH="/home/jetson/samabot-frontend"

echo "📡 Preparando archivos para transferencia..."
echo "📍 IP del Jetson: $JETSON_IP"
echo "👤 Usuario: $JETSON_USER"
echo "📁 Destino: $JETSON_PATH"
echo ""

# Crear archivo comprimido del frontend
echo "📦 Creando archivo comprimido..."
tar -czf samabot-frontend.tar.gz --exclude='node_modules' --exclude='.next' samabot-frontend/

echo "✅ Archivo comprimido creado: samabot-frontend.tar.gz"
echo ""

echo "📋 INSTRUCCIONES PARA TRANSFERIR AL JETSON:"
echo "============================================="
echo ""
echo "1. Copia el archivo al Jetson:"
echo "   scp samabot-frontend.tar.gz $JETSON_USER@$JETSON_IP:~/"
echo ""
echo "2. Conecta al Jetson:"
echo "   ssh $JETSON_USER@$JETSON_IP"
echo ""
echo "3. En el Jetson, ejecuta estos comandos:"
echo "   cd ~"
echo "   tar -xzf samabot-frontend.tar.gz"
echo "   cd samabot-frontend"
echo "   npm install"
echo "   npm run build"
echo ""
echo "4. Para iniciar el frontend:"
echo "   npm run dev"
echo ""
echo "5. URL de acceso: http://192.168.1.7:3000"
echo ""

# Crear script de instalación para Jetson
echo "🔧 Creando script de instalación para Jetson..."
cat > install_jetson.sh << 'EOF'
#!/bin/bash

echo "🤖 INSTALANDO SAMABOT FRONTEND EN JETSON"
echo "=========================================="
echo ""

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado"
    echo "Instalando Node.js..."
    sudo apt update
    sudo apt install -y nodejs npm
    echo "✅ Node.js instalado"
fi

echo "✅ Node.js detectado: $(node --version)"
echo "✅ npm detectado: $(npm --version)"
echo ""

# Extraer archivos si existe el tar
if [ -f "samabot-frontend.tar.gz" ]; then
    echo "📦 Extrayendo archivos..."
    tar -xzf samabot-frontend.tar.gz
    echo "✅ Archivos extraídos"
fi

# Verificar que existe el directorio
if [ ! -d "samabot-frontend" ]; then
    echo "❌ Error: Directorio samabot-frontend no encontrado"
    echo "Asegúrate de que el archivo samabot-frontend.tar.gz esté en el directorio actual"
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
echo "🌐 URL de acceso: http://192.168.1.7:3000"
echo ""
echo "📋 COMANDOS DISPONIBLES:"
echo "  npm run dev     # Iniciar servidor de desarrollo"
echo "  npm run build   # Compilar para producción"
echo "  npm run start   # Iniciar servidor de producción"
echo ""
echo "🚀 Para iniciar el frontend:"
echo "  npm run dev"
echo ""
echo "🎯 PARA LA DEMOSTRACIÓN:"
echo "1. Ejecuta: npm run dev"
echo "2. Accede desde cualquier dispositivo: http://192.168.1.7:3000"
echo "3. La interfaz estará disponible sin necesidad de laptop"
echo ""
echo "¡Listo para la demostración! 🚀"
EOF

chmod +x install_jetson.sh

echo "✅ Script de instalación creado: install_jetson.sh"
echo ""

echo "📋 RESUMEN DE ARCHIVOS CREADOS:"
echo "================================"
echo "✅ samabot-frontend.tar.gz - Archivo comprimido del frontend"
echo "✅ install_jetson.sh - Script de instalación para Jetson"
echo ""

echo "🚀 PASOS PARA DEPLOY:"
echo "====================="
echo "1. Copia los archivos al Jetson:"
echo "   scp samabot-frontend.tar.gz install_jetson.sh $JETSON_USER@$JETSON_IP:~/"
echo ""
echo "2. Conecta al Jetson:"
echo "   ssh $JETSON_USER@$JETSON_IP"
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
echo "¡Listo para transferir! 🚀" 