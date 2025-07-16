# 🚀 SOLUCIÓN ALTERNATIVA PARA JETSON

## 📋 PROBLEMA: Jetson no responde por red

### 🔧 SOLUCIONES DISPONIBLES:

## **Opción 1: Memoria USB**
1. Copia los archivos a una memoria USB:
   ```bash
   cp samabot-frontend.tar.gz /media/tu-usuario/MEMORIA_USB/
   cp install_jetson.sh /media/tu-usuario/MEMORIA_USB/
   ```

2. Conecta la memoria al Jetson
3. En el Jetson:
   ```bash
   cp /media/jetson/MEMORIA_USB/samabot-frontend.tar.gz ~/
   cp /media/jetson/MEMORIA_USB/install_jetson.sh ~/
   ./install_jetson.sh
   ```

## **Opción 2: Conexión USB directa**
1. Conecta el Jetson a tu laptop por USB
2. Copia archivos directamente
3. Ejecuta instalación en Jetson

## **Opción 3: Instalación manual en Jetson**
En el Jetson, ejecuta estos comandos:

```bash
# Instalar Node.js si no está
sudo apt update
sudo apt install nodejs npm

# Crear directorio
mkdir ~/samabot-frontend
cd ~/samabot-frontend

# Crear package.json
cat > package.json << 'EOF'
{
  "name": "samabot-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "react": "^18",
    "react-dom": "^18",
    "next": "15.3.5"
  },
  "devDependencies": {
    "typescript": "^5",
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "autoprefixer": "^10.0.1",
    "postcss": "^8",
    "tailwindcss": "^3.3.0",
    "eslint": "^8",
    "eslint-config-next": "15.3.5"
  }
}
EOF

# Instalar dependencias
npm install

# Crear estructura básica
mkdir -p src/app src/components/ui src/services

# Crear archivos del frontend
# (Los archivos se crearán en el siguiente paso)
```

## **Opción 4: Usar el frontend local**
Si no puedes conectar al Jetson, usa tu laptop:

```bash
cd samabot-frontend
npm run dev
```

**URL: http://localhost:3000**

---

## 🎯 RECOMENDACIÓN PARA EXAMEN

**Usa tu laptop para la demostración:**
1. Ejecuta: `cd samabot-frontend && npm run dev`
2. Accede: http://localhost:3000
3. Muestra la interfaz SAMABOT Industrial
4. Explica que está diseñado para Jetson

**¡El frontend está completamente funcional en tu laptop! 🚀** 