#!/bin/bash

echo "🚀 Configuración completa de SAMABOT en Jetson Orin Nano..."

# 1. Verificar que estamos en el Jetson
if [[ $(uname -m) != "aarch64" ]]; then
    echo "❌ Este script debe ejecutarse en el Jetson Orin Nano"
    exit 1
fi

# 2. Navegar al directorio
cd ~/maker/samabot/frontend

# 3. Instalar Node.js si no está instalado
if ! command -v node &> /dev/null; then
    echo "📦 Instalando Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 4. Verificar Node.js
echo "📋 Verificando Node.js..."
node --version
npm --version

# 5. Instalar dependencias del frontend
echo "📦 Instalando dependencias del frontend..."
npm install

# 6. Crear archivos de configuración faltantes
echo "⚙️ Creando archivos de configuración..."

# Tailwind config
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic':
          'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
      },
    },
  },
  plugins: [],
}
EOF

# PostCSS config
cat > postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# 7. Crear archivo de configuración de entorno
cat > .env.local << 'EOF'
NEXT_PUBLIC_SAMITA_API_URL=http://localhost:3001
NEXT_PUBLIC_PLC_API_URL=http://localhost:3001
EOF

# 8. Activar entorno virtual Python
echo "🐍 Activando entorno virtual Python..."
source samita_ai/bin/activate

# 9. Instalar dependencias Python
echo "📦 Instalando dependencias Python..."
pip install requests flask flask-cors python-snap7

# 10. Verificar Ollama
echo "🤖 Verificando Ollama..."
if ! pgrep -x "ollama" > /dev/null; then
    echo "⚠️ Ollama no está corriendo. Iniciando..."
    ollama serve > /tmp/ollama.log 2>&1 &
    sleep 5
fi

# 11. Descargar modelo si no existe
if ! ollama list | grep -q "phi:2.7b"; then
    echo "📥 Descargando modelo Phi-2.7b..."
    ollama pull phi:2.7b
fi

# 12. Crear modelo SAMITA si no existe
if ! ollama list | grep -q "samita-es"; then
    echo "🔧 Creando modelo SAMITA personalizado..."
    
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

    ollama create samita-es -f samita_prompt.txt
    ollama cp phi:2.7b samita-es
fi

# 13. Verificar modelos
echo "📋 Modelos disponibles:"
ollama list

# 14. Probar SAMITA
echo "🧪 Probando SAMITA AI..."
ollama run samita-es "Hola, ¿cómo estás? Responde en español."

echo "✅ Configuración completa finalizada!"
echo ""
echo "🚀 Para ejecutar el sistema:"
echo "1. Terminal 1 (Backend): python samita_ai_backend_fixed.py"
echo "2. Terminal 2 (Frontend): npm run dev"
echo "3. Abrir navegador: http://localhost:3000"
echo ""
echo "📱 Para pantalla de 10\": http://192.168.1.7:3000" 