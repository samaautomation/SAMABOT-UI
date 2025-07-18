#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🤖 SAMABOT INDUSTRIAL - LAUNCHER COMPLETO${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

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

print_success() {
    echo -e "${PURPLE}🎉 $1${NC}"
}

# Matar procesos viejos
echo "ℹ️  Matando procesos viejos..."
pkill -f 'next dev' 2>/dev/null
pkill -f 'python.*samita_ai_backend' 2>/dev/null
sleep 2
echo "✅ Procesos viejos terminados"

# Preparar frontend
echo "ℹ️  Preparando frontend..."
cd ~/maker/samabot/frontend
if [ -d "node_modules" ]; then
    echo "✅ Frontend encontrado en: $(pwd)"
else
    echo "❌ Frontend no encontrado"
    exit 1
fi

# Preparar backend
echo "ℹ️  Preparando backend..."
cd ~/maker/samabot/backend
if [ -f "samita_ai_backend.py" ]; then
    echo "✅ Backend encontrado"
else
    echo "❌ Backend no encontrado"
    exit 1
fi

# Iniciar backend en puerto específico
echo "ℹ️  Iniciando backend..."
cd ~/maker/samabot/backend
python3 samita_ai_backend.py &
BACKEND_PID=$!
echo "✅ Backend iniciado (PID: $BACKEND_PID)"

# Esperar a que el backend esté listo
sleep 3

# Iniciar frontend
echo "ℹ️  Iniciando frontend..."
cd ~/maker/samabot/frontend
npm run dev &
FRONTEND_PID=$!
echo "✅ Frontend iniciado (PID: $FRONTEND_PID)"

# Esperar a que el frontend esté listo
echo "ℹ️  Esperando a que el frontend esté listo..."
sleep 10

# Abrir navegador
echo "ℹ️  Abriendo navegador..."
xdg-open http://192.168.1.7:3000 2>/dev/null || firefox http://192.168.1.7:3000 2>/dev/null || google-chrome http://192.168.1.7:3000 2>/dev/null

echo ""
echo "🎉 ¡SAMABOT INICIADO COMPLETAMENTE!"
echo "================================"
echo " URL Frontend: http://192.168.1.7:3000"
echo " Backend PID: $BACKEND_PID"
echo "🎨 Frontend PID: $FRONTEND_PID"
echo " COMANDOS ÚTILES:"
echo "  Para detener todo: pkill -f 'next dev' && pkill -f 'python.*samita_ai_backend'"
echo "  Para ver logs: tail -f ~/.samabot.log"
echo "  Para reiniciar: ./samabot_complete_launcher.sh"
echo "ℹ️  Presiona Ctrl+C para detener todo"

# Mantener el script corriendo
wait 