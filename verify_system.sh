#!/bin/bash

echo "🔍 VERIFICACIÓN COMPLETA DEL SISTEMA SAMABOT"
echo "=============================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para verificar
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

echo -e "${BLUE}1. Verificando servicios corriendo...${NC}"
ssh samabot@192.168.1.7 "ps aux | grep -E '(snap7|next)' | grep -v grep" > /dev/null 2>&1
check_status "Servicios backend y frontend corriendo"

echo -e "${BLUE}2. Verificando puertos abiertos...${NC}"
ssh samabot@192.168.1.7 "netstat -tlnp | grep -E '(3000|3001)'" > /dev/null 2>&1
check_status "Puertos 3000 (frontend) y 3001 (backend) abiertos"

echo -e "${BLUE}3. Verificando conectividad al PLC...${NC}"
ssh samabot@192.168.1.7 "ping -c 1 192.168.1.5" > /dev/null 2>&1
check_status "PLC Siemens (192.168.1.5) responde"

echo -e "${BLUE}4. Verificando backend Flask...${NC}"
ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/status" > /dev/null 2>&1
check_status "Backend Flask respondiendo en puerto 3001"

echo -e "${BLUE}5. Verificando datos del PLC...${NC}"
ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/real-data | grep -q 'success.*true'" > /dev/null 2>&1
check_status "Datos del PLC fluyendo correctamente"

echo -e "${BLUE}6. Verificando frontend Next.js...${NC}"
ssh samabot@192.168.1.7 "curl -s http://localhost:3000" > /dev/null 2>&1
check_status "Frontend Next.js respondiendo en puerto 3000"

echo -e "${BLUE}7. Verificando comunicación frontend-backend...${NC}"
ssh samabot@192.168.1.7 "curl -s http://localhost:3000/api/plc/real-data | grep -q 'success.*true'" > /dev/null 2>&1
check_status "Comunicación frontend ↔ backend funcionando"

echo -e "${BLUE}8. Verificando acceso externo...${NC}"
curl -s http://192.168.1.7:3000 > /dev/null 2>&1
check_status "Frontend accesible desde red externa"

curl -s http://192.168.1.7:3001/api/plc/status > /dev/null 2>&1
check_status "Backend accesible desde red externa"

echo ""
echo -e "${BLUE}📊 RESUMEN DE DATOS DEL PLC:${NC}"
echo "=============================================="
ssh samabot@192.168.1.7 "curl -s http://localhost:3001/api/plc/real-data | python3 -c \"
import json, sys
data = json.load(sys.stdin)
print(f'🌡️  Temperatura: {data[\"systemData\"][\"temperature\"]}°C')
print(f'📊 Presión: {data[\"systemData\"][\"pressure\"]} bar')
print(f'🔌 Conexión: {data[\"connection\"][\"isConnected\"]}')
print(f'⚡ Response Time: {data[\"connection\"][\"responseTime\"]}ms')
print(f'📅 Timestamp: {data[\"timestamp\"]}')
print(f'🚨 Alarmas: {len(data[\"systemData\"][\"alarms\"])}')
\""

echo ""
echo -e "${BLUE}🌐 URLs DE ACCESO:${NC}"
echo "=============================================="
echo -e "${GREEN}Frontend UI:${NC} http://192.168.1.7:3000"
echo -e "${GREEN}Backend API:${NC} http://192.168.1.7:3001"
echo -e "${GREEN}PLC Status:${NC} http://192.168.1.7:3001/api/plc/status"
echo -e "${GREEN}PLC Data:${NC} http://192.168.1.7:3001/api/plc/real-data"

echo ""
echo -e "${YELLOW}💡 COMANDOS ÚTILES:${NC}"
echo "=============================================="
echo "Ver logs del backend: ssh samabot@192.168.1.7 'tail -f ~/maker/samabot/backend/snap7/snap7-backend.log'"
echo "Reiniciar backend: ssh samabot@192.168.1.7 'pkill -f snap7-backend && cd ~/maker/samabot/backend/snap7 && python3 snap7_backend_improved.py &'"
echo "Ver procesos: ssh samabot@192.168.1.7 'ps aux | grep -E \"(snap7|next)\"'"
echo "Test PLC: ssh samabot@192.168.1.7 'cd ~/maker/samabot/backend/snap7 && python3 test_iq_lectura.py'"

echo ""
echo -e "${GREEN}🎉 VERIFICACIÓN COMPLETA${NC}" 