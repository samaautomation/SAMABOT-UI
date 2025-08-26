# 🚀 INSTRUCCIONES EXACTAS PARA JETSON

## 📁 ARCHIVOS QUE NECESITAS SUBIR A LA MEMORIA USB:

1. **samabot-frontend.tar.gz** - Archivo comprimido del frontend
2. **install_jetson.sh** - Script de instalación automática

## 📋 PASOS EXACTOS:

### Paso 1: Copiar archivos a memoria USB
```bash
# En tu laptop, copia estos archivos a la memoria USB:
cp samabot-frontend.tar.gz /media/tu-usuario/NOMBRE_MEMORIA_USB/
cp install_jetson.sh /media/tu-usuario/NOMBRE_MEMORIA_USB/
```

### Paso 2: Conectar memoria al Jetson
- Conecta la memoria USB al Jetson Nano

### Paso 3: En el Jetson, copiar archivos
```bash
# En el Jetson, abre terminal y ejecuta:
cd ~
cp /media/jetson/NOMBRE_MEMORIA_USB/samabot-frontend.tar.gz ./
cp /media/jetson/NOMBRE_MEMORIA_USB/install_jetson.sh ./
```

### Paso 4: Ejecutar instalación automática
```bash
# En el Jetson:
chmod +x install_jetson.sh
./install_jetson.sh
```

### Paso 5: Iniciar el frontend
```bash
# En el Jetson:
cd samabot-frontend
npm run dev
```

### Paso 6: Acceder desde cualquier dispositivo
**URL: http://192.168.1.7:3000**

---

## 🔧 SI HAY PROBLEMAS:

### Si Node.js no está instalado:
```bash
# En el Jetson:
sudo apt update
sudo apt install nodejs npm
```

### Si hay errores de permisos:
```bash
# En el Jetson:
sudo chown -R jetson:jetson ~/samabot-frontend
```

### Si el puerto 3000 está ocupado:
```bash
# En el Jetson, edita package.json:
# "dev": "next dev -p 3001"
```

---

## 📁 ESTRUCTURA FINAL EN JETSON:

```
/home/jetson/
├── samabot-frontend/
│   ├── src/
│   │   ├── app/
│   │   ├── components/ui/
│   │   └── services/
│   ├── package.json
│   ├── node_modules/
│   └── .next/
├── samabot-frontend.tar.gz
└── install_jetson.sh
```

---

## 🎯 COMANDOS RÁPIDOS PARA JETSON:

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

## 🎉 PARA LA DEMOSTRACIÓN:

1. **Inicia el Jetson**
2. **Ejecuta:** `cd ~/samabot-frontend && npm run dev`
3. **Accede desde cualquier dispositivo:** http://192.168.1.7:3000
4. **¡Listo!** La interfaz estará disponible sin laptop

**¡El frontend funcionará independientemente en el Jetson! 🚀**

---

## 📋 CHECKLIST:

- [ ] Copiar archivos a memoria USB
- [ ] Conectar memoria al Jetson
- [ ] Copiar archivos al Jetson
- [ ] Ejecutar install_jetson.sh
- [ ] Iniciar con npm run dev
- [ ] Probar acceso desde red

**¡Listo para la demostración! 🎯** 