#!/bin/bash

# Script completo para iniciar SAMABOT en Jetson
# SAMABOT Industrial - Complete Startup Script

echo "🏭 SAMABOT Industrial - Iniciando Sistema Completo"
echo "=================================================="

# Función para verificar si un puerto está en uso
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        return 0
    else
        return 1
    fi
}

# Función para matar procesos en un puerto
kill_port() {
    local port=$1
    echo "🔄 Deteniendo procesos en puerto $port..."
    sudo pkill -f ":$port" || true
    sleep 2
}

# 1. Verificar conectividad con PLC
echo "📡 Verificando conectividad con PLC..."
if ping -c 1 192.168.1.5 &> /dev/null; then
    echo "✅ PLC Siemens S7-1200 accesible"
else
    echo "❌ PLC no accesible - verificar red"
fi

# 2. Iniciar Backend (Puerto 8000)
echo "🔧 Iniciando Backend API..."
kill_port 8000

cd ~/maker/samabot/backend
echo "🚀 Iniciando uvicorn en puerto 8000..."
python -m uvicorn snap7_backend:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &
BACKEND_PID=$!

# Esperar a que el backend esté listo
echo "⏳ Esperando que backend esté listo..."
for i in {1..30}; do
    if check_port 8000; then
        echo "✅ Backend iniciado en puerto 8000"
        break
    fi
    sleep 1
done

# 3. Verificar backend
echo "🔍 Verificando backend..."
sleep 3
if curl -s http://localhost:8000/status > /dev/null; then
    echo "✅ Backend respondiendo correctamente"
    echo "📊 Datos del PLC:"
    curl -s http://localhost:8000/status | jq '.connectionQuality, .inputs, .outputs' 2>/dev/null || curl -s http://localhost:8000/status
else
    echo "❌ Backend no responde - revisar logs"
    tail -n 10 backend.log
fi

# 4. Iniciar Frontend (Puerto 3000)
echo "🌐 Iniciando Frontend Web..."
kill_port 3000

cd ~/maker/samabot/frontend
echo "🚀 Iniciando Next.js en puerto 3000..."
npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!

# Esperar a que el frontend esté listo
echo "⏳ Esperando que frontend esté listo..."
for i in {1..60}; do
    if check_port 3000; then
        echo "✅ Frontend iniciado en puerto 3000"
        break
    fi
    sleep 1
done

# 5. Verificar frontend
echo "🔍 Verificando frontend..."
sleep 5
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend respondiendo correctamente"
else
    echo "❌ Frontend no responde - revisar logs"
    tail -n 10 frontend.log
fi

# 6. Mostrar información final
echo ""
echo "🎉 ¡SAMABOT Industrial iniciado exitosamente!"
echo "=============================================="
echo "🌐 Frontend: http://192.168.1.7:3000"
echo "🔧 Backend:  http://192.168.1.7:8000"
echo "📚 API Docs: http://192.168.1.7:8000/docs"
echo "🏭 PLC:      192.168.1.5"
echo ""
echo "📊 Estado de servicios:"
echo "   Backend PID:  $BACKEND_PID"
echo "   Frontend PID: $FRONTEND_PID"
echo ""
echo "📋 Comandos útiles:"
echo "   Ver logs backend:  tail -f ~/maker/samabot/backend/backend.log"
echo "   Ver logs frontend: tail -f ~/maker/samabot/frontend/frontend.log"
echo "   Verificar estado:  curl http://192.168.1.7:8000/status"
echo "   Abrir navegador:   firefox http://192.168.1.7:3000"
echo ""
echo "🔄 Para reiniciar todo: ./start_samabot_complete.sh" 