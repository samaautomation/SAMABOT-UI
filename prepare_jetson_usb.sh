#!/bin/bash

echo "🚀 PREPARANDO ARCHIVOS PARA JETSON (MEMORIA USB)"
echo "================================================="
echo ""

# Verificar que tenemos los archivos necesarios
if [ ! -f "samabot-frontend.tar.gz" ]; then
    echo "❌ Error: samabot-frontend.tar.gz no encontrado"
    echo "Creando archivo comprimido..."
    cd samabot-frontend && tar -czf ../samabot-frontend.tar.gz . && cd ..
fi

if [ ! -f "install_jetson.sh" ]; then
    echo "❌ Error: install_jetson.sh no encontrado"
    exit 1
fi

echo "✅ Archivos verificados:"
echo "  - samabot-frontend.tar.gz"
echo "  - install_jetson.sh"
echo ""

# Crear directorio para memoria USB
USB_DIR="jetson_files"
mkdir -p $USB_DIR

# Copiar archivos al directorio
echo "📁 Copiando archivos..."
cp samabot-frontend.tar.gz $USB_DIR/
cp install_jetson.sh $USB_DIR/

# Crear script de instalación mejorado
cat > $USB_DIR/install_jetson_improved.sh << 'EOF'
#!/bin/bash

echo "🤖 INSTALANDO SAMABOT FRONTEND EN JETSON"
echo "=========================================="
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

# Extraer archivos
if [ -f "samabot-frontend.tar.gz" ]; then
    print_info "Extrayendo archivos..."
    tar -xzf samabot-frontend.tar.gz
    print_status "Archivos extraídos"
else
    print_error "samabot-frontend.tar.gz no encontrado"
    exit 1
fi

cd samabot-frontend

print_info "Instalando dependencias..."
npm install

print_info "Compilando frontend..."
npm run build

if [ $? -eq 0 ]; then
    print_status "Frontend compilado correctamente"
else
    print_error "Error en la compilación"
    exit 1
fi

# Crear script de inicio
cat > start_samabot.sh << 'INNER_EOF'
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
INNER_EOF

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
EOF

chmod +x $USB_DIR/install_jetson_improved.sh

# Crear README para el Jetson
cat > $USB_DIR/README_JETSON.md << 'EOF'
# 🚀 SAMABOT FRONTEND - JETSON NANO

## 📋 ARCHIVOS INCLUIDOS:
- `samabot-frontend.tar.gz` - Frontend comprimido
- `install_jetson_improved.sh` - Script de instalación mejorado
- `install_jetson.sh` - Script de instalación original

## 🎯 PASOS PARA INSTALAR:

### 1. Copiar archivos al Jetson
```bash
# En el Jetson, copia estos archivos desde la memoria USB:
cp /media/jetson/NOMBRE_USB/* ./
```

### 2. Ejecutar instalación
```bash
# En el Jetson:
chmod +x install_jetson_improved.sh
./install_jetson_improved.sh
```

### 3. Iniciar el frontend
```bash
# En el Jetson:
cd samabot-frontend
./start_samabot.sh
```

## 🌐 ACCESO:
- **URL:** http://192.168.1.7:3000
- **Acceso desde cualquier dispositivo en la red**

## 🔧 COMANDOS ÚTILES:
```bash
# Verificar estado
cd samabot-frontend && npm run dev

# Detener servidor
Ctrl+C

# Reiniciar
./start_samabot.sh
```

## 🎉 ¡LISTO PARA LA DEMOSTRACIÓN!
EOF

echo "✅ Archivos preparados en directorio: $USB_DIR"
echo ""
echo "📋 ARCHIVOS CREADOS:"
echo "  - $USB_DIR/samabot-frontend.tar.gz"
echo "  - $USB_DIR/install_jetson.sh"
echo "  - $USB_DIR/install_jetson_improved.sh"
echo "  - $USB_DIR/README_JETSON.md"
echo ""
echo "🎯 PRÓXIMOS PASOS:"
echo "1. Copia el directorio $USB_DIR a una memoria USB"
echo "2. Conecta la memoria al Jetson Nano"
echo "3. Copia los archivos al Jetson"
echo "4. Ejecuta: ./install_jetson_improved.sh"
echo "5. Inicia con: ./start_samabot.sh"
echo ""
echo "🌐 URL final: http://192.168.1.7:3000"
echo ""
echo "¡Listo para transferir al Jetson! 🚀" 