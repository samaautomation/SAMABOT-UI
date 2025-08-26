#!/bin/bash

echo "🚀 TRANSFERIENDO SAMABOT FRONTEND AL JETSON"
echo "============================================="
echo ""

# Configuración
JETSON_IP="192.168.1.7"
JETSON_USER="jetson"
JETSON_PATH="/home/jetson/samabot-frontend"

echo "📡 Conectando al Jetson Nano..."
echo "📍 IP: $JETSON_IP"
echo "👤 Usuario: $JETSON_USER"
echo "📁 Destino: $JETSON_PATH"
echo ""

# Verificar conexión al Jetson
if ! ping -c 1 $JETSON_IP &> /dev/null; then
    echo "❌ Error: No se puede conectar al Jetson en $JETSON_IP"
    echo "Verifica que el Jetson esté encendido y conectado a la red"
    exit 1
fi

echo "✅ Jetson detectado"
echo ""

# Crear directorio en Jetson
echo "📁 Creando directorio en Jetson..."
ssh $JETSON_USER@$JETSON_IP "mkdir -p $JETSON_PATH"

# Transferir archivos del frontend
echo "📤 Transfiriendo archivos del frontend..."
rsync -avz --exclude 'node_modules' --exclude '.next' samabot-frontend/ $JETSON_USER@$JETSON_IP:$JETSON_PATH/

echo "✅ Archivos transferidos"
echo ""

# Instalar dependencias en Jetson
echo "📦 Instalando dependencias en Jetson..."
ssh $JETSON_USER@$JETSON_IP "cd $JETSON_PATH && npm install"

echo "✅ Dependencias instaladas"
echo ""

# Crear script de inicio en Jetson
echo "🔧 Configurando script de inicio en Jetson..."
ssh $JETSON_USER@$JETSON_IP "cat > $JETSON_PATH/start_jetson.sh << 'EOF'
#!/bin/bash

echo '🤖 SAMABOT INDUSTRIAL - JETSON NANO'
echo '====================================='
echo ''

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo '❌ Error: Node.js no está instalado'
    echo 'Instala Node.js: sudo apt update && sudo apt install nodejs npm'
    exit 1
fi

echo '✅ Node.js detectado'
echo ''

# Instalar dependencias si no están
if [ ! -d 'node_modules' ]; then
    echo '📦 Instalando dependencias...'
    npm install
    echo ''
fi

echo '🚀 Iniciando SAMABOT Frontend en Jetson...'
echo '📍 URL: http://192.168.1.7:3000'
echo '⏰ Hora de inicio: $(date)'
echo ''
echo '📋 INSTRUCCIONES PARA DEMOSTRACIÓN:'
echo '1. El frontend estará disponible en: http://192.168.1.7:3000'
echo '2. Puedes acceder desde cualquier dispositivo en la red'
echo '3. La interfaz muestra el estado del PLC en tiempo real'
echo '4. Samita AI está representada por el emoji robot 🤖'
echo '5. Los datos se actualizan cada 2 segundos'
echo ''
echo '🛑 Para detener: Ctrl+C'
echo ''

# Iniciar el servidor de desarrollo
npm run dev
EOF"

# Hacer ejecutable el script
ssh $JETSON_USER@$JETSON_IP "chmod +x $JETSON_PATH/start_jetson.sh"

echo "✅ Script de inicio creado"
echo ""

# Crear servicio systemd para auto-inicio
echo "🔧 Configurando auto-inicio en Jetson..."
ssh $JETSON_USER@$JETSON_IP "sudo tee /etc/systemd/system/samabot-frontend.service > /dev/null << 'EOF'
[Unit]
Description=SAMABOT Frontend
After=network.target

[Service]
Type=simple
User=jetson
WorkingDirectory=$JETSON_PATH
ExecStart=/usr/bin/npm run dev
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF"

# Habilitar el servicio
ssh $JETSON_USER@$JETSON_IP "sudo systemctl daemon-reload"
ssh $JETSON_USER@$JETSON_IP "sudo systemctl enable samabot-frontend.service"

echo "✅ Servicio configurado para auto-inicio"
echo ""

# Crear script de control
echo "🔧 Creando script de control..."
ssh $JETSON_USER@$JETSON_IP "cat > $JETSON_PATH/control.sh << 'EOF'
#!/bin/bash

case \"\$1\" in
    start)
        echo '🚀 Iniciando SAMABOT Frontend...'
        cd $JETSON_PATH && npm run dev
        ;;
    stop)
        echo '🛑 Deteniendo SAMABOT Frontend...'
        pkill -f 'next dev'
        ;;
    restart)
        echo '🔄 Reiniciando SAMABOT Frontend...'
        pkill -f 'next dev'
        sleep 2
        cd $JETSON_PATH && npm run dev
        ;;
    status)
        echo '📊 Estado del SAMABOT Frontend:'
        if pgrep -f 'next dev' > /dev/null; then
            echo '✅ Frontend ejecutándose'
            echo '📍 URL: http://192.168.1.7:3000'
        else
            echo '❌ Frontend no está ejecutándose'
        fi
        ;;
    *)
        echo 'Uso: ./control.sh {start|stop|restart|status}'
        echo ''
        echo 'Comandos disponibles:'
        echo '  start   - Iniciar el frontend'
        echo '  stop    - Detener el frontend'
        echo '  restart - Reiniciar el frontend'
        echo '  status  - Ver estado del frontend'
        ;;
esac
EOF"

ssh $JETSON_USER@$JETSON_IP "chmod +x $JETSON_PATH/control.sh"

echo "✅ Script de control creado"
echo ""

# Probar la instalación
echo "🧪 Probando instalación..."
ssh $JETSON_USER@$JETSON_IP "cd $JETSON_PATH && npm run build"

if [ $? -eq 0 ]; then
    echo "✅ Frontend compila correctamente en Jetson"
else
    echo "❌ Error en la compilación"
    exit 1
fi

echo ""
echo "🎉 ¡TRANSFERENCIA COMPLETADA!"
echo "================================"
echo ""
echo "📍 Ubicación en Jetson: $JETSON_PATH"
echo "🌐 URL de acceso: http://192.168.1.7:3000"
echo ""
echo "📋 COMANDOS DISPONIBLES EN JETSON:"
echo "  cd $JETSON_PATH"
echo "  ./start_jetson.sh     # Iniciar frontend"
echo "  ./control.sh start    # Iniciar"
echo "  ./control.sh stop     # Detener"
echo "  ./control.sh restart  # Reiniciar"
echo "  ./control.sh status   # Ver estado"
echo ""
echo "🔧 SERVICIO AUTOMÁTICO:"
echo "  sudo systemctl start samabot-frontend.service"
echo "  sudo systemctl stop samabot-frontend.service"
echo "  sudo systemctl status samabot-frontend.service"
echo ""
echo "🎯 PARA LA DEMOSTRACIÓN:"
echo "1. El Jetson iniciará automáticamente el frontend"
echo "2. Accede desde cualquier dispositivo: http://192.168.1.7:3000"
echo "3. La interfaz estará disponible sin necesidad de laptop"
echo ""
echo "¡Listo para la demostración! 🚀" 