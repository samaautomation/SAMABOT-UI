#!/bin/bash

echo "🤖 INSTALANDO SAMABOT FRONTEND EN JETSON (VERSIÓN CORREGIDA)"
echo "================================================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Verificar Node.js
print_info "Verificando Node.js..."
if ! command -v node &> /dev/null; then
    print_warning "Node.js no está instalado"
    print_info "Instalando Node.js..."
    sudo apt update
    sudo apt install -y nodejs npm
    print_status "Node.js instalado"
else
    print_status "Node.js ya está instalado"
fi

echo ""
print_status "Node.js: $(node --version)"
print_status "npm: $(npm --version)"
echo ""

# Verificar que el archivo existe
if [ ! -f "samabot-frontend.tar.gz" ]; then
    print_error "samabot-frontend.tar.gz no encontrado"
    print_info "Archivos disponibles:"
    ls -la *.tar.gz 2>/dev/null || echo "No hay archivos .tar.gz"
    exit 1
fi

# Extraer archivos
print_info "Extrayendo archivos..."
tar -xzf samabot-frontend.tar.gz
if [ $? -eq 0 ]; then
    print_status "Archivos extraídos correctamente"
else
    print_error "Error al extraer archivos"
    exit 1
fi

# Verificar que se creó el directorio
if [ ! -d "samabot-frontend" ]; then
    print_error "El directorio samabot-frontend no se creó"
    print_info "Contenido actual:"
    ls -la
    exit 1
fi

cd samabot-frontend

print_info "Instalando dependencias..."
npm install

if [ $? -eq 0 ]; then
    print_status "Dependencias instaladas correctamente"
else
    print_error "Error al instalar dependencias"
    exit 1
fi

print_info "Compilando frontend..."
npm run build

if [ $? -eq 0 ]; then
    print_status "Frontend compilado correctamente"
else
    print_error "Error en la compilación"
    print_info "Intentando compilar sin linting..."
    npm run build -- --no-lint
    if [ $? -eq 0 ]; then
        print_status "Frontend compilado sin linting"
    else
        print_error "Error en la compilación incluso sin linting"
        exit 1
    fi
fi

# Crear script de inicio
cat > start_samabot.sh << 'EOF'
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

# Instalar dependencias si no están
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
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
EOF

chmod +x start_samabot.sh

echo ""
print_status "¡INSTALACIÓN COMPLETADA!"
echo "============================"
echo ""
print_info "Ubicación: $(pwd)"
print_info "URL: http://192.168.1.7:3000"
echo ""
print_info "Para iniciar: ./start_samabot.sh"
print_info "Acceso: http://192.168.1.7:3000"
echo ""
print_status "¡Listo para la demostración! 🚀" 