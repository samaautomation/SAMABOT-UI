#!/bin/bash

echo "🚀 INSTALANDO SAMABOT LAUNCHER EN JETSON"
echo "========================================="
echo ""

# Copiar el script principal
echo "📁 Copiando script principal..."
cp samabot_complete_launcher.sh /home/samabot/
chmod +x /home/samabot/samabot_complete_launcher.sh

# Crear icono simple (si no existe)
if [ ! -f "/home/samabot/samabot-icon.png" ]; then
    echo "🎨 Creando icono..."
    # Crear un icono simple con ImageMagick si está disponible
    if command -v convert &> /dev/null; then
        convert -size 64x64 xc:transparent -fill blue -draw "circle 32,32 32,8" -fill white -draw "text 20,40 'S'" /home/samabot/samabot-icon.png
    else
        # Crear un icono de texto como fallback
        echo "🤖" > /home/samabot/samabot-icon.txt
    fi
fi

# Copiar archivo .desktop
echo "📋 Copiando archivo .desktop..."
cp SAMABOT-Launcher.desktop /home/samabot/Desktop/
chmod +x /home/samabot/Desktop/SAMABOT-Launcher.desktop

# También copiar a aplicaciones del sistema
sudo cp SAMABOT-Launcher.desktop /usr/share/applications/

# Crear script de detención
cat > /home/samabot/samabot_stop.sh << 'EOF'
#!/bin/bash
echo "🛑 Deteniendo SAMABOT..."
pkill -f "next dev"
pkill -f "python.*samita_ai_backend"
pkill -f "python.*plc_backend"
echo "✅ SAMABOT detenido"
EOF

chmod +x /home/samabot/samabot_stop.sh

# Crear script de estado
cat > /home/samabot/samabot_status.sh << 'EOF'
#!/bin/bash
echo "📊 Estado de SAMABOT:"
echo "====================="

if pgrep -f "next dev" > /dev/null; then
    echo "✅ Frontend: Ejecutándose"
else
    echo "❌ Frontend: No ejecutándose"
fi

if pgrep -f "python.*samita_ai_backend" > /dev/null; then
    echo "✅ Backend: Ejecutándose"
else
    echo "❌ Backend: No ejecutándose"
fi

JETSON_IP=$(hostname -I | awk '{print $1}')
echo "🌐 URL: http://$JETSON_IP:3000"
EOF

chmod +x /home/samabot/samabot_status.sh

echo ""
echo "✅ ¡INSTALACIÓN COMPLETADA!"
echo "=========================="
echo ""
echo "🎯 PRÓXIMOS PASOS:"
echo "1. Haz doble clic en el icono 'SAMABOT Industrial' en el escritorio"
echo "2. O ejecuta: /home/samabot/samabot_complete_launcher.sh"
echo ""
echo "📋 COMANDOS ÚTILES:"
echo "  Estado: /home/samabot/samabot_status.sh"
echo "  Detener: /home/samabot/samabot_stop.sh"
echo "  Iniciar: /home/samabot/samabot_complete_launcher.sh"
echo ""
echo "🎉 ¡Listo para usar! 🚀" 