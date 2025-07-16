import logging
import json
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS
import snap7
from snap7.util import *
import threading
import time
import sqlite3
from datetime import datetime

# Configurar logging
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
MODEL_NAME = "mistral:7b"

class SAMITAAI:
    def __init__(self):
        self.conversation_history = []
        self.db_path = "samita_conversations.db"
        self.init_database()
    
    def init_database(self):
        """Inicializar base de datos para conversaciones"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                user_message TEXT,
                ai_response TEXT,
                plc_data TEXT,
                feedback INTEGER
            )
        ''')
        conn.commit()
        conn.close()
    
    def get_plc_context(self, plc_data):
        """Crear contexto del PLC para SAMITA"""
        context = f"""
        Estado del PLC SAMABOT:
        - Conectado: {plc_data.get('connected', False)}
        - Entradas Digitales: {plc_data.get('digital_inputs', [])}
        - Salidas Digitales: {plc_data.get('digital_outputs', [])}
        - Entradas Analógicas: {plc_data.get('analog_inputs', [])}
        - Salidas Analógicas: {plc_data.get('analog_outputs', [])}
        """
        return context
    
    def chat_with_samita(self, user_message, plc_data=None):
        """Chat con SAMITA AI usando Ollama"""
        try:
            # Crear contexto del PLC
            plc_context = self.get_plc_context(plc_data) if plc_data else ""
            
            # Construir prompt
            system_prompt = f"""Eres SAMITA AI, un asistente inteligente para el sistema SAMABOT Industrial. 
            Tu función es ayudar a monitorear y controlar el PLC Siemens S7-1200.
            
            {plc_context}
            
            Responde de manera clara y técnica en español. Si te preguntan sobre el estado del PLC, 
            usa la información proporcionada. Si no tienes información actualizada, indícalo."""
            
            # Preparar mensaje para Ollama
            payload = {
                "model": MODEL_NAME,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_message}
                ],
                "stream": False
            }
            
            # Llamar a Ollama
            response = requests.post(f"{OLLAMA_URL}/api/chat", json=payload, timeout=30)
            
            if response.status_code == 200:
                ai_response = response.json()["message"]["content"]
                
                # Guardar conversación
                self.save_conversation(user_message, ai_response, plc_data)
                
                return {
                    "success": True,
                    "response": ai_response,
                    "timestamp": datetime.now().isoformat()
                }
            else:
                logger.error(f"Error en Ollama: {response.status_code}")
                return {
                    "success": False,
                    "response": "Error al comunicarse con SAMITA AI",
                    "timestamp": datetime.now().isoformat()
                }
                
        except Exception as e:
            logger.error(f"Error en chat con SAMITA: {e}")
            return {
                "success": False,
                "response": f"Error: {str(e)}",
                "timestamp": datetime.now().isoformat()
            }
    
    def save_conversation(self, user_message, ai_response, plc_data):
        """Guardar conversación en base de datos"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO conversations (user_message, ai_response, plc_data)
                VALUES (?, ?, ?)
            ''', (user_message, ai_response, json.dumps(plc_data) if plc_data else None))
            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"Error guardando conversación: {e}")
    
    def get_conversation_history(self, limit=10):
        """Obtener historial de conversaciones"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute('''
                SELECT timestamp, user_message, ai_response 
                FROM conversations 
                ORDER BY timestamp DESC 
                LIMIT ?
            ''', (limit,))
            conversations = cursor.fetchall()
            conn.close()
            
            return [
                {
                    "timestamp": conv[0],
                    "user_message": conv[1],
                    "ai_response": conv[2]
                }
                for conv in conversations
            ]
        except Exception as e:
            logger.error(f"Error obteniendo historial: {e}")
            return []

# Inicializar SAMITA AI
samita_ai = SAMITAAI()

class PLCClient:
    def __init__(self):
        self.client = None
        self.connected = False
        self.simulation_mode = False
        
    def connect(self):
        """Conectar al PLC"""
        try:
            if self.simulation_mode:
                logger.info("🔧 Modo simulación activado")
                self.connected = True
                return True
                
            logger.info(f"connecting to {PLC_IP}:102 rack {PLC_RACK} slot {PLC_SLOT}")
            self.client = snap7.client.Client()
            self.client.connect(PLC_IP, PLC_RACK, PLC_SLOT)
            self.connected = True
            logger.info("✅ Conectado al PLC Siemens")
            return True
        except Exception as e:
            logger.error(f"❌ Error conectando al PLC: {e}")
            self.connected = False
            return False
    
    def read_digital_inputs(self):
        """Leer entradas digitales"""
        try:
            if self.simulation_mode:
                return [random.choice([True, False]) for _ in range(14)]
            
            # Leer área de entradas (I)
            data = self.client.db_read(0, 0, 2)  # Leer 2 bytes
            inputs = []
            for i in range(14):
                inputs.append(get_bool(data, 0, i))
            return inputs
        except Exception as e:
            logger.error(f"Error leyendo entradas digitales: {e}")
            return [False] * 14
    
    def read_digital_outputs(self):
        """Leer salidas digitales"""
        try:
            if self.simulation_mode:
                return [random.choice([True, False]) for _ in range(10)]
            
            # Leer área de salidas (Q)
            data = self.client.db_read(0, 0, 2)
            outputs = []
            for i in range(10):
                outputs.append(get_bool(data, 0, i))
            return outputs
        except Exception as e:
            logger.error(f"Error leyendo salidas digitales: {e}")
            return [False] * 10
    
    def read_analog_inputs(self):
        """Leer entradas analógicas"""
        try:
            if self.simulation_mode:
                return [random.uniform(0, 10) for _ in range(2)]
            
            # Leer entradas analógicas (IW)
            data = self.client.db_read(0, 0, 4)
            analog_inputs = []
            for i in range(2):
                value = get_int(data, i * 2)
                # Convertir a voltaje (0-10V)
                voltage = (value / 27648.0) * 10.0
                analog_inputs.append(round(voltage, 2))
            return analog_inputs
        except Exception as e:
            logger.error(f"Error leyendo entradas analógicas: {e}")
            return [0.0, 0.0]
    
    def get_plc_data(self):
        """Obtener todos los datos del PLC"""
        try:
            if not self.connected:
                if not self.connect():
                    return {"error": "No se pudo conectar al PLC"}
            
            data = {
                "connected": self.connected,
                "digital_inputs": self.read_digital_inputs(),
                "digital_outputs": self.read_digital_outputs(),
                "analog_inputs": self.read_analog_inputs(),
                "timestamp": datetime.now().isoformat()
            }
            
            return data
        except Exception as e:
            logger.error(f"Error obteniendo datos del PLC: {e}")
            return {"error": str(e)}

# Inicializar cliente PLC
plc_client = PLCClient()

@app.route('/api/plc/status', methods=['GET'])
def plc_status():
    """Endpoint para verificar estado del PLC"""
    try:
        connected = plc_client.connect()
        return jsonify({
            "connected": connected,
            "timestamp": datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/plc/real-data', methods=['GET'])
def plc_real_data():
    """Endpoint para obtener datos reales del PLC"""
    try:
        data = plc_client.get_plc_data()
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/samita/chat', methods=['POST'])
def samita_chat():
    """Endpoint para chat con SAMITA AI"""
    try:
        data = request.get_json()
        user_message = data.get('message', '')
        
        if not user_message:
            return jsonify({"error": "Mensaje requerido"}), 400
        
        # Obtener datos actuales del PLC
        plc_data = plc_client.get_plc_data()
        
        # Chat con SAMITA
        response = samita_ai.chat_with_samita(user_message, plc_data)
        
        return jsonify(response)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/samita/history', methods=['GET'])
def samita_history():
    """Endpoint para obtener historial de conversaciones"""
    try:
        limit = request.args.get('limit', 10, type=int)
        history = samita_ai.get_conversation_history(limit)
        return jsonify({"history": history})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/samita/feedback', methods=['POST'])
def samita_feedback():
    """Endpoint para feedback de conversaciones"""
    try:
        data = request.get_json()
        conversation_id = data.get('conversation_id')
        feedback = data.get('feedback')  # 1 para positivo, 0 para negativo
        
        # Aquí podrías implementar el guardado de feedback
        # para mejorar el modelo en el futuro
        
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    logger.info("🚀 Iniciando backend SAMABOT con SAMITA AI")
    logger.info("🔌 Intentando conectar al PLC...")
    
    # Intentar conectar al PLC
    plc_client.connect()
    
    logger.info("🚀 Servidor iniciado en puerto 3001")
    logger.info("🔧 Modo simulación: Desactivado")
    
    app.run(host='0.0.0.0', port=3001, debug=False) 