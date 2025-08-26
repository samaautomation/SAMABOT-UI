#!/bin/bash

# SAMABOT - Setup Launchers para Jetson
# ING. SERGIO M - #SAMAKER

echo "███████╗ █████╗ ███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗"
echo "██╔════╝██╔══██╗████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗"
echo "███████╗███████║██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝"
echo "╚════██║██╔══██║██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████║██║  ██║██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "             ING. SERGIO M – #SAMAKER"
echo "🚀 Configurando Launchers para Jetson..."
echo ""

JETSON_USER="samabot"
JETSON_IP="192.168.1.7"
PROJECT_DIR="/home/$JETSON_USER/SAMABOT-UI"

echo "📁 Copiando archivos de launcher al Jetson..."

# Copiar archivos
scp SAMABOT_Start.sh $JETSON_USER@$JETSON_IP:$PROJECT_DIR/
scp SAMABOT_HTML_Launcher.html $JETSON_USER@$JETSON_IP:$PROJECT_DIR/
scp SAMABOT_Launcher.desktop $JETSON_USER@$JETSON_IP:$PROJECT_DIR/

echo "🔧 Configurando permisos y acceso directo..."

# Configurar en el Jetson
ssh $JETSON_USER@$JETSON_IP << 'EOF'
cd /home/samabot/SAMABOT-UI

# Hacer ejecutable el script
chmod +x SAMABOT_Start.sh

# Crear acceso directo en el escritorio
cp SAMABOT_Launcher.desktop ~/Desktop/
chmod +x ~/Desktop/SAMABOT_Launcher.desktop

# Crear acceso directo en el menú de aplicaciones
sudo cp SAMABOT_Launcher.desktop /usr/share/applications/

# Crear enlace simbólico para fácil acceso
ln -sf /home/samabot/SAMABOT-UI/SAMABOT_Start.sh /usr/local/bin/samabot

echo "✅ Launchers configurados correctamente"
echo ""
echo "🎯 Opciones de acceso:"
echo "   1. Doble clic en 'SAMABOT Industrial' en el escritorio"
echo "   2. Buscar 'SAMABOT' en el menú de aplicaciones"
echo "   3. Ejecutar: samabot (desde terminal)"
echo "   4. Doble clic en: SAMABOT_Start.sh"
echo "   5. Abrir: SAMABOT_HTML_Launcher.html en navegador"
echo ""
echo "🌐 URLs de acceso:"
echo "   • Panel Principal: http://localhost:3000"
echo "   • API Backend: http://localhost:8000"
echo "   • Status PLC: http://localhost:8000/api/plc/status"
EOF

echo ""
echo "🎉 ¡Configuración completada!"
echo ""
echo "📋 Instrucciones de uso:"
echo "   1. En el Jetson, busca 'SAMABOT Industrial' en el menú"
echo "   2. O haz doble clic en el icono del escritorio"
echo "   3. O ejecuta: samabot (desde terminal)"
echo ""
echo "🔧 Comandos útiles:"
echo "   • Iniciar: ./SAMABOT_Start.sh"
echo "   • Detener: ./stop_samabot.sh"
echo "   • Status: ./status_samabot.sh"
echo ""
echo "🌐 Acceso remoto desde tu PC:"
echo "   • Frontend: http://192.168.1.7:3000"
echo "   • Backend: http://192.168.1.7:8000" 