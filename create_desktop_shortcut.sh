#!/bin/bash

# Script para crear acceso directo de SAMABOT en el escritorio

echo "🖥️  Creando acceso directo de SAMABOT en el escritorio..."

# Obtener la ruta actual del proyecto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="$HOME/Desktop"

# Crear el archivo .desktop
cat > "$DESKTOP_DIR/SAMABOT.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=SAMABOT Industrial
Comment=Sistema de Monitoreo Industrial
Exec=$PROJECT_DIR/open_samabot.sh
Icon=applications-development
Terminal=false
Categories=Development;Engineering;
Keywords=SAMABOT;PLC;Industrial;Monitoring;
EOF

# Hacer el archivo ejecutable
chmod +x "$DESKTOP_DIR/SAMABOT.desktop"

echo "✅ Acceso directo creado en: $DESKTOP_DIR/SAMABOT.desktop"
echo "🖱️  Haz doble clic en el icono del escritorio para abrir SAMABOT"
echo ""
echo "📋 También puedes usar:"
echo "   ./start_samabot.sh    # Iniciar todo el sistema"
echo "   ./open_samabot.sh     # Abrir solo el navegador" 