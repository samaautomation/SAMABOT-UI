# 🚀 INSTRUCCIONES PARA DEPLOY EN JETSON

## 📋 PASOS MANUALES (SIN SSH AUTOMÁTICO)

### Paso 1: Copiar archivos al Jetson
```bash
# Desde tu laptop, ejecuta:
scp samabot-frontend.tar.gz install_jetson.sh jetson@192.168.1.7:~/
```

**Cuando te pida la contraseña, usa la contraseña de inicio de sesión del Jetson.**

### Paso 2: Conectar al Jetson
```bash
ssh jetson@192.168.1.7
```

**Usa la misma contraseña de inicio de sesión.**

### Paso 3: En el Jetson, ejecutar la instalación
```bash
# Una vez conectado al Jetson:
cd ~
./install_jetson.sh
```

### Paso 4: Iniciar el frontend
```bash
cd samabot-frontend
npm run dev
```

### Paso 5: Acceder desde cualquier dispositivo
**URL: http://192.168.1.7:3000**

---

## 🔧 SI HAY PROBLEMAS CON SSH

### Opción A: Usar USB/Red directa
1. Conecta tu laptop al Jetson por USB o red directa
2. Copia los archivos manualmente:
   ```bash
   # En tu laptop
   cp samabot-frontend.tar.gz /media/tu-usuario/jetson/
   cp install_jetson.sh /media/tu-usuario/jetson/
   ```

### Opción B: Usar memoria USB
1. Copia los archivos a una memoria USB
2. Conecta la memoria al Jetson
3. Copia desde la memoria al Jetson

### Opción C: Descargar desde GitHub
1. Sube los archivos a GitHub
2. En el Jetson:
   ```bash
   wget https://github.com/tu-usuario/samabot/releases/download/v1.0/samabot-frontend.tar.gz
   wget https://github.com/tu-usuario/samabot/releases/download/v1.0/install_jetson.sh
   ```

---

## 🎯 COMANDOS RÁPIDOS PARA JETSON

### Instalación completa:
```bash
cd ~
tar -xzf samabot-frontend.tar.gz
cd samabot-frontend
npm install
npm run build
npm run dev
```

### Verificar que funciona:
```bash
# En el Jetson
curl http://localhost:3000
```

### Acceder desde otro dispositivo:
- Abre navegador
- Ve a: http://192.168.1.7:3000

---

## 🚨 SOLUCIÓN DE PROBLEMAS

### Si Node.js no está instalado:
```bash
sudo apt update
sudo apt install nodejs npm
```

### Si hay errores de permisos:
```bash
sudo chown -R jetson:jetson ~/samabot-frontend
```

### Si el puerto 3000 está ocupado:
```bash
# Cambiar puerto en package.json
# "dev": "next dev -p 3001"
```

### Si no se puede acceder desde red:
```bash
# Verificar IP del Jetson
ip addr show

# Verificar firewall
sudo ufw status
```

---

## 🎉 PARA LA DEMOSTRACIÓN

1. **Inicia el Jetson**
2. **Ejecuta:** `cd ~/samabot-frontend && npm run dev`
3. **Accede desde cualquier dispositivo:** http://192.168.1.7:3000
4. **¡Listo!** La interfaz estará disponible sin laptop

**¡El frontend funcionará independientemente en el Jetson! 🚀** 