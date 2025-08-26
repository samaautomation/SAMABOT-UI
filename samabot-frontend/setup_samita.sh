#!/bin/bash

echo "🚀 Configurando SAMITA AI en Jetson Orin Nano..."

# 1. Verificar que estamos en el Jetson
if [[ $(uname -m) != "aarch64" ]]; then
    echo "❌ Este script debe ejecutarse en el Jetson Orin Nano"
    exit 1
fi

# 2. Navegar al directorio correcto
cd ~/maker/samabot/frontend

# 3. Activar entorno virtual
echo "📦 Activando entorno virtual..."
source samita_ai/bin/activate

# 4. Instalar dependencias
echo "📦 Instalando dependencias..."
pip install requests flask flask-cors python-snap7

# 5. Verificar que Ollama esté corriendo
echo "🤖 Verificando Ollama..."
if ! pgrep -x "ollama" > /dev/null; then
    echo "⚠️ Ollama no está corriendo. Iniciando..."
    ollama serve > /tmp/ollama.log 2>&1 &
    sleep 5
fi

# 6. Verificar modelos disponibles
echo "📋 Verificando modelos de IA..."
ollama list

# 7. Si no existe el modelo samita-es, crearlo
if ! ollama list | grep -q "samita-es"; then
    echo "🔧 Creando modelo SAMITA personalizado..."
    
    # Crear prompt personalizado
    cat > samita_prompt.txt << 'EOF'
Eres SAMITA AI, un asistente inteligente especializado en sistemas industriales SAMABOT.

INSTRUCCIONES:
- Responde SIEMPRE en español
- Sé técnico pero claro
- Eres experto en PLCs Siemens S7-1200
- Conoces entradas/salidas digitales y analógicas
- Explica conceptos de automatización industrial

CONTEXTO DEL SISTEMA:
- PLC: Siemens S7-1200 conectado a Jetson Orin Nano
- Entradas Digitales: 14 canales (I0.0 a I1.5)
- Salidas Digitales: 10 canales (Q0.0 a Q1.1)
- Entradas Analógicas: 2 canales (AI0, AI1)
- Sistema: Monitoreo en tiempo real

EJEMPLOS DE RESPUESTAS:
- "¿Está funcionando el PLC?" → "Sí, el PLC está conectado y operativo"
- "¿Qué entradas están activas?" → "Las entradas digitales activas son: [lista]"
- "¿Hay algún error?" → "Revisando el estado del sistema..."

Responde de manera profesional y técnica en español.
EOF

    # Crear modelo personalizado
    ollama create samita-es -f samita_prompt.txt
    ollama cp phi:2.7b samita-es
fi

# 8. Probar el modelo
echo "🧪 Probando SAMITA AI..."
ollama run samita-es "Hola, ¿cómo estás? Responde en español."

# 9. Ejecutar el backend
echo "🚀 Iniciando SAMITA AI Backend..."
python samita_ai_backend.py

echo "✅ SAMITA AI configurado y listo!" 