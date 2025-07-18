#!/bin/bash

# SAMABOT - Setup Completo para Jetson Orin Nano
# ING. SERGIO M - #SAMAKER
# Build. Break. Repeat.

echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "💡 Build. Break. Repeat."
echo ""

# Variables de configuración
JETSON_USER="samabot"
JETSON_IP="192.168.1.7"
PROJECT_DIR="/home/$JETSON_USER/SAMABOT-UI"
BACKEND_PORT=3001
FRONTEND_PORT=3000

echo "🚀 Iniciando configuración completa de SAMABOT en Jetson..."
echo "📍 IP del Jetson: $JETSON_IP"
echo "👤 Usuario: $JETSON_USER"
echo "📁 Directorio: $PROJECT_DIR"
echo ""

# Función para ejecutar comandos en Jetson
run_on_jetson() {
    echo "🔧 Ejecutando: $1"
    ssh $JETSON_USER@$JETSON_IP "$1"
}

# Función para copiar archivos al Jetson
copy_to_jetson() {
    echo "📁 Copiando: $1 -> $2"
    scp -r "$1" $JETSON_USER@$JETSON_IP:"$2"
}

echo "📋 Paso 1: Verificando conexión SSH al Jetson..."
if ! ssh -o ConnectTimeout=5 $JETSON_USER@$JETSON_IP "echo 'Conexión SSH exitosa'" 2>/dev/null; then
    echo "❌ Error: No se puede conectar al Jetson"
    echo "🔧 Verifica:"
    echo "   - IP del Jetson: $JETSON_IP"
    echo "   - Usuario: $JETSON_USER"
    echo "   - SSH habilitado en Jetson"
    exit 1
fi
echo "✅ Conexión SSH establecida"

echo ""
echo "📋 Paso 2: Actualizando sistema del Jetson..."
run_on_jetson "sudo apt update && sudo apt upgrade -y"

echo ""
echo "📋 Paso 3: Instalando dependencias del sistema..."
run_on_jetson "sudo apt install -y python3 python3-pip python3-venv nodejs npm git curl wget"

echo ""
echo "📋 Paso 4: Instalando Ollama..."
run_on_jetson "curl -fsSL https://ollama.ai/install.sh | sh"

echo ""
echo "📋 Paso 5: Configurando variables de entorno para GPU..."
run_on_jetson "echo 'export CUDA_VISIBLE_DEVICES=0' >> ~/.bashrc"
run_on_jetson "echo 'export OLLAMA_HOST=0.0.0.0' >> ~/.bashrc"
run_on_jetson "source ~/.bashrc"

echo ""
echo "📋 Paso 6: Descargando modelo Phi-2.7b..."
run_on_jetson "ollama pull phi2.7b"

echo ""
echo "📋 Paso 7: Creando directorio del proyecto..."
run_on_jetson "mkdir -p $PROJECT_DIR"

echo ""
echo "📋 Paso 8: Copiando archivos del proyecto..."
copy_to_jetson "backend/" "$PROJECT_DIR/"
copy_to_jetson "samabot-frontend/" "$PROJECT_DIR/"

echo ""
echo "📋 Paso 9: Configurando entorno Python..."
run_on_jetson "cd $PROJECT_DIR/backend && python3 -m venv venv"
run_on_jetson "cd $PROJECT_DIR/backend && source venv/bin/activate && pip install -r requirements.txt"

echo ""
echo "📋 Paso 10: Instalando dependencias Node.js..."
run_on_jetson "cd $PROJECT_DIR/samabot-frontend && npm install"

echo ""
echo "📋 Paso 11: Configurando servicios del sistema..."

# Crear servicio para el backend
run_on_jetson "sudo tee /etc/systemd/system/samabot-backend.service > /dev/null << 'EOF'
[Unit]
Description=SAMABOT Backend Service
After=network.target

[Service]
Type=simple
User=$JETSON_USER
WorkingDirectory=$PROJECT_DIR/backend
Environment=PATH=$PROJECT_DIR/backend/venv/bin
ExecStart=$PROJECT_DIR/backend/venv/bin/python snap7_backend_improved.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

# Crear servicio para el frontend
run_on_jetson "sudo tee /etc/systemd/system/samabot-frontend.service > /dev/null << 'EOF'
[Unit]
Description=SAMABOT Frontend Service
After=network.target

[Service]
Type=simple
User=$JETSON_USER
WorkingDirectory=$PROJECT_DIR/samabot-frontend
ExecStart=/usr/bin/npm run dev
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

echo ""
echo "📋 Paso 12: Habilitando servicios..."
run_on_jetson "sudo systemctl daemon-reload"
run_on_jetson "sudo systemctl enable samabot-backend"
run_on_jetson "sudo systemctl enable samabot-frontend"

echo ""
echo "📋 Paso 13: Creando scripts de control..."

# Script para iniciar todo
run_on_jetson "tee $PROJECT_DIR/start_samabot.sh > /dev/null << 'EOF'
#!/bin/bash
echo '🚀 Iniciando SAMABOT...'
sudo systemctl start samabot-backend
sudo systemctl start samabot-frontend
echo '✅ SAMABOT iniciado'
echo '🌐 Frontend: http://$JETSON_IP:$FRONTEND_PORT'
echo '🔧 Backend: http://$JETSON_IP:$BACKEND_PORT'
EOF"

# Script para detener todo
run_on_jetson "tee $PROJECT_DIR/stop_samabot.sh > /dev/null << 'EOF'
#!/bin/bash
echo '🛑 Deteniendo SAMABOT...'
sudo systemctl stop samabot-frontend
sudo systemctl stop samabot-backend
echo '✅ SAMABOT detenido'
EOF"

# Script para verificar estado
run_on_jetson "tee $PROJECT_DIR/status_samabot.sh > /dev/null << 'EOF'
#!/bin/bash
echo '📊 Estado de SAMABOT:'
echo 'Backend:'
sudo systemctl status samabot-backend --no-pager
echo ''
echo 'Frontend:'
sudo systemctl status samabot-frontend --no-pager
echo ''
echo '🌐 URLs:'
echo 'Frontend: http://$JETSON_IP:$FRONTEND_PORT'
echo 'Backend: http://$JETSON_IP:$BACKEND_PORT'
EOF"

run_on_jetson "chmod +x $PROJECT_DIR/*.sh"

echo ""
echo "📋 Paso 14: Configurando acceso desde pantalla táctil..."
run_on_jetson "mkdir -p ~/.config/autostart"
run_on_jetson "tee ~/.config/autostart/samabot.desktop > /dev/null << 'EOF'
[Desktop Entry]
Type=Application
Name=SAMABOT UI
Comment=SAMABOT Industrial Interface
Exec=chromium-browser --kiosk --disable-web-security --user-data-dir=/tmp/chrome-samabot http://localhost:$FRONTEND_PORT
Terminal=false
X-GNOME-Autostart-enabled=true
EOF"

echo ""
echo "📋 Paso 15: Configurando firewall..."
run_on_jetson "sudo ufw allow $BACKEND_PORT"
run_on_jetson "sudo ufw allow $FRONTEND_PORT"

echo ""
echo "🎉 ¡Configuración completada!"
echo ""
echo "📋 Comandos útiles:"
echo "   Iniciar SAMABOT: $PROJECT_DIR/start_samabot.sh"
echo "   Detener SAMABOT:  $PROJECT_DIR/stop_samabot.sh"
echo "   Ver estado:       $PROJECT_DIR/status_samabot.sh"
echo ""
echo "🌐 URLs de acceso:"
echo "   Frontend: http://$JETSON_IP:$FRONTEND_PORT"
echo "   Backend:  http://$JETSON_IP:$BACKEND_PORT"
echo ""
echo "📱 Pantalla táctil: Se abrirá automáticamente al reiniciar"
echo ""
echo "🔧 Para probar ahora:"
echo "   ssh $JETSON_USER@$JETSON_IP"
echo "   cd $PROJECT_DIR"
echo "   ./start_samabot.sh"
echo ""
echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "💡 Build. Break. Repeat." 