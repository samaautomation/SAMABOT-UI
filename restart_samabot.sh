#!/bin/bash

echo "🚀 Reiniciando SAMABOT Industrial..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar conexión SSH
print_status "Verificando conexión a Jetson..."
if ! ssh -o ConnectTimeout=5 samabot@192.168.1.7 "echo 'Conexión SSH OK'" > /dev/null 2>&1; then
    print_error "No se puede conectar a la Jetson. Verifica la IP y conexión SSH."
    exit 1
fi
print_success "Conexión SSH establecida"

# Matar procesos existentes
print_status "Deteniendo procesos existentes..."
ssh samabot@192.168.1.7 "pkill -f snap7_backend_improved.py" 2>/dev/null
ssh samabot@192.168.1.7 "pkill -f 'next dev'" 2>/dev/null
ssh samabot@192.168.1.7 "fuser -k 3000/tcp" 2>/dev/null
ssh samabot@192.168.1.7 "fuser -k 3001/tcp" 2>/dev/null
sleep 2

# Verificar Ollama
print_status "Verificando Ollama..."
if ssh samabot@192.168.1.7 "ollama list | grep samita-es" > /dev/null 2>&1; then
    print_success "Modelo samita-es disponible"
else
    print_warning "Modelo samita-es no encontrado. Ejecutando 'ollama pull samita-es'..."
    ssh samabot@192.168.1.7 "ollama pull samita-es" &
fi

# Iniciar backend
print_status "Iniciando backend SAMABOT..."
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/backend && source venv/bin/activate && python snap7_backend_improved.py" &
BACKEND_PID=$!

# Esperar a que el backend esté listo
print_status "Esperando a que el backend esté listo..."
sleep 5

# Verificar backend
if ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" > /dev/null 2>&1; then
    print_success "Backend iniciado correctamente en puerto 3001"
else
    print_error "Error al iniciar el backend"
    exit 1
fi

# Iniciar frontend
print_status "Iniciando frontend SAMABOT..."
ssh samabot@192.168.1.7 "cd /home/samabot/SAMABOT-UI/samabot-frontend && npm run dev" &
FRONTEND_PID=$!

# Esperar a que el frontend esté listo
print_status "Esperando a que el frontend esté listo..."
sleep 10

# Verificar frontend
if ssh samabot@192.168.1.7 "curl -s http://localhost:3000" > /dev/null 2>&1; then
    print_success "Frontend iniciado correctamente en puerto 3000"
else
    print_warning "Frontend puede estar tardando en iniciar..."
fi

# Mostrar información final
echo ""
print_success "🎉 SAMABOT Industrial reiniciado exitosamente!"
echo ""
echo "📊 Estado del sistema:"
echo "   • Backend (PLC + SAMITA): http://192.168.1.7:3001"
echo "   • Frontend (UI): http://192.168.1.7:3000"
echo "   • Ollama (IA): Modelo samita-es"
echo ""
echo "🔧 Comandos útiles:"
echo "   • Ver logs backend: ssh samabot@192.168.1.7 'tail -f /home/samabot/SAMABOT-UI/backend/logs/*'"
echo "   • Probar SAMITA: curl -X POST http://192.168.1.7:3001/api/samita/chat -H 'Content-Type: application/json' -d '{\"message\":\"Hola SAMITA\"}'"
echo "   • Verificar PLC: curl http://192.168.1.7:3001/api/plc/status"
echo ""
print_status "¡Sistema listo para usar! 🚀" 