#!/usr/bin/env python3
"""
SAMITA AI Backend - Sistema de IA para SAMABOT Industrial
Comunica con PLC Siemens S7-1200 y Ollama para IA local
"""

import logging
import json
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
import snap7
from snap7.util import *
import os
import time

# Configurar para GPU
os.environ['CUDA_VISIBLE_DEVICES'] = '0'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuración del PLC
PLC_IP = "192.168.1.5"
PLC_RACK = 0
PLC_SLOT = 1

# Configuración de SAMITA AI
OLLAMA_URL = "http://localhost:11434"
MODEL_NAME = "samita-es"

class SAMITAAI:
    def __init__(self):
        self.url = f"{OLLAMA_URL}/api/chat"
        
    def chat(self, message, plc_data=None):
        """Chat con SAMITA AI usando datos del PLC"""
        try:
            # Crear contexto con datos del PLC
            context = ""
            if plc_data:
                context = f"""
                DATOS DEL PLC:
                - Entradas Digitales: {plc_data.get('digital_inputs', [])}
                - Salidas Digitales: {plc_data.get('digital_outputs', [])}
                - Entradas Analógicas: {plc_data.get('analog_inputs', [])}
                - Estado: {plc_data.get('status', 'Desconocido')}
                
                PREGUNTA: {message}
                """
            else:
                context = message
            
            payload = {
                "model": MODEL_NAME,
                "messages": [
                    {"role": "user", "content": context}
                ],
                "stream": False
            }
            
            response = requests.post(self.url, json=payload, timeout=30)
            if response.status_code == 200:
                result = response.json()
                return result.get('message', {}).get('content', 'Error en la respuesta')
            else:
                return f"Error: {response.status_code}"
                
        except Exception as e:
            logger.error(f"Error en SAMITA AI: {e}")
            return f"Error de comunicación: {str(e)}"

class PLCClient:
    def __init__(self):
        self.client = snap7.client.Client()
        self.connected = False
        
    def connect(self):
        try:
            self.client.connect(PLC_IP, PLC_RACK, PLC_SLOT)
            self.connected = self.client.get_connected()
            logger.info(f"✅ Conectado al PLC Siemens")
            return True
        except Exception as e:
            logger.error(f"❌ Error conectando al PLC: {e}")
            return False
    
    def get_status(self):
        return {
            "connected": self.connected,
            "ip": PLC_IP,
            "timestamp": datetime.now().isoformat()
        }
    
    def read_digital_inputs_physical(self):
        """Leer entradas digitales físicas directamente"""
        try:
            if not self.connected:
                return []
            
            inputs = []
            # Intentar leer entradas físicas (I0.0 a I1.5)
            for i in range(14):
                try:
                    # Leer byte específico de entrada
                    byte_index = i // 8
                    bit_index = i % 8
                    
                    # Leer byte de entrada física
                    data = self.client.eb_read(byte_index, 1)  # Leer 1 byte
                    value = get_bool(data, 0, bit_index)
                    
                    inputs.append({
                        "id": f"I{byte_index}.{bit_index}",
                        "value": value,
                        "description": f"Entrada Digital {i+1}"
                    })
                except Exception as e:
                    logger.warning(f"Error leyendo entrada {i}: {e}")
                    inputs.append({
                        "id": f"I{i//8}.{i%8}",
                        "value": False,
                        "description": f"Entrada Digital {i+1} (Error)"
                    })
            
            return inputs
        except Exception as e:
            logger.error(f"Error leyendo entradas digitales: {e}")
            return []
    
    def read_digital_outputs_physical(self):
        """Leer salidas digitales físicas directamente"""
        try:
            if not self.connected:
                return []
            
            outputs = []
            # Intentar leer salidas físicas (Q0.0 a Q1.1)
            for i in range(10):
                try:
                    # Leer byte específico de salida
                    byte_index = i // 8
                    bit_index = i % 8
                    
                    # Leer byte de salida física
                    data = self.client.ab_read(byte_index, 1)  # Leer 1 byte
                    value = get_bool(data, 0, bit_index)
                    
                    outputs.append({
                        "id": f"Q{byte_index}.{bit_index}",
                        "value": value,
                        "description": f"Salida Digital {i+1}"
                    })
                except Exception as e:
                    logger.warning(f"Error leyendo salida {i}: {e}")
                    outputs.append({
                        "id": f"Q{i//8}.{i%8}",
                        "value": False,
                        "description": f"Salida Digital {i+1} (Error)"
                    })
            
            return outputs
        except Exception as e:
            logger.error(f"Error leyendo salidas digitales: {e}")
            return []
    
    def read_analog_inputs_physical(self):
        """Leer entradas analógicas físicas"""
        try:
            if not self.connected:
                return []
            
            inputs = []
            # Intentar leer entradas analógicas físicas
            for i in range(2):
                try:
                    # Leer entrada analógica física
                    data = self.client.eb_read(i * 2, 2)  # 2 bytes por valor
                    value = get_int(data, 0)
                    
                    inputs.append({
                        "id": f"AI{i}",
                        "value": value,
                        "description": f"Entrada Analógica {i+1}"
                    })
                except Exception as e:
                    logger.warning(f"Error leyendo entrada analógica {i}: {e}")
                    inputs.append({
                        "id": f"AI{i}",
                        "value": 0,
                        "description": f"Entrada Analógica {i+1} (Error)"
                    })
            
            return inputs
        except Exception as e:
            logger.error(f"Error leyendo entradas analógicas: {e}")
            return []

# Inicializar componentes
plc = PLCClient()
samita = SAMITAAI()

@app.route('/api/plc/status', methods=['GET'])
def plc_status():
    """Estado del PLC"""
    return jsonify(plc.get_status())

@app.route('/api/plc/real-data', methods=['GET'])
def plc_real_data():
    """Datos reales del PLC"""
    try:
        if not plc.connected:
            plc.connect()
        
        digital_inputs = plc.read_digital_inputs_physical()
        digital_outputs = plc.read_digital_outputs_physical()
        analog_inputs = plc.read_analog_inputs_physical()
        
        data = {
            "digital_inputs": digital_inputs,
            "digital_outputs": digital_outputs,
            "analog_inputs": analog_inputs,
            "timestamp": datetime.now().isoformat(),
            "status": "connected" if plc.connected else "disconnected"
        }
        
        return jsonify(data)
    except Exception as e:
        logger.error(f"Error obteniendo datos: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/samita/chat', methods=['POST'])
def samita_chat():
    """Chat con SAMITA AI"""
    try:
        data = request.get_json()
        message = data.get('message', '')
        
        # Obtener datos del PLC para contexto
        plc_data = None
        try:
            if plc.connected:
                digital_inputs = plc.read_digital_inputs_physical()
                digital_outputs = plc.read_digital_outputs_physical()
                analog_inputs = plc.read_analog_inputs_physical()
                
                plc_data = {
                    "digital_inputs": digital_inputs,
                    "digital_outputs": digital_outputs,
                    "analog_inputs": analog_inputs,
                    "status": "connected"
                }
        except:
            pass
        
        # Obtener respuesta de SAMITA
        response = samita.chat(message, plc_data)
        
        return jsonify({
            "response": response,
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error en chat: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check del sistema"""
    try:
        # Verificar Ollama
        ollama_health = False
        try:
            response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
            ollama_health = response.status_code == 200
        except:
            pass
        
        # Verificar PLC
        plc_health = plc.connected
        
        return jsonify({
            "healthy": ollama_health and plc_health,
            "ollama": ollama_health,
            "plc": plc_health,
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({"healthy": False, "error": str(e)}), 500

if __name__ == '__main__':
    logger.info("🚀 Iniciando SAMITA AI Backend")
    
    # Conectar al PLC
    if plc.connect():
        logger.info("✅ PLC conectado")
    else:
        logger.warning("⚠️ PLC no conectado - modo simulación")
    
    # Iniciar servidor
    app.run(host='0.0.0.0', port=3001, debug=False) 