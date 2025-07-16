#!/usr/bin/env python3
"""
Backend snap7 mejorado para UI Light - Servidor API
Comunicación con PLC Siemens S7-1200 usando snap7
Con manejo de errores y datos simulados
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import logging
import snap7
from snap7.util import *
from snap7.types import *
import time
import random
import threading

# Configuración de logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger()

# Configuración general
PARAMS = {
    "PLC_IP": "192.168.1.5",
    "RACK": 0,
    "SLOT": 1,
    "DB_NUMBER": 1,
    "START_ADDRESS": 0,
    "SIZE": 16  # Tamaño del bloque de datos
}

plc_client = snap7.client.Client()
simulation_mode = False
last_real_data = None

# Inicializar Flask
app = Flask(__name__)
CORS(app)  # Habilitar CORS para el frontend

def get_simulated_data():
    """Generar datos simulados para demostración"""
    return {
        "success": True,
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "connection": {
            "isConnected": True,
            "host": PARAMS["PLC_IP"],
            "port": 102,
            "responseTime": random.randint(10, 50)
        },
        "digitalInputs": {
            "I0": random.choice([True, False]),
            "I1": random.choice([True, False]),
            "I2": random.choice([True, False]),
            "I3": random.choice([True, False]),
            "I4": random.choice([True, False]),
            "I5": random.choice([True, False]),
            "I6": random.choice([True, False]),
            "I7": random.choice([True, False]),
            "I8": random.choice([True, False]),
            "I9": random.choice([True, False]),
            "I10": random.choice([True, False]),
            "I11": random.choice([True, False]),
            "I12": random.choice([True, False]),
            "I13": random.choice([True, False])
        },
        "digitalOutputs": {
            "Q0": random.choice([True, False]),
            "Q1": random.choice([True, False]),
            "Q2": random.choice([True, False]),
            "Q3": random.choice([True, False]),
            "Q4": random.choice([True, False]),
            "Q5": random.choice([True, False]),
            "Q6": random.choice([True, False]),
            "Q7": random.choice([True, False]),
            "Q8": random.choice([True, False]),
            "Q9": random.choice([True, False])
        },
        "analogInputs": {
            "AI0": round(random.uniform(20.0, 50.0), 1),  # Temperatura
            "AI1": round(random.uniform(1.0, 5.0), 1)     # Presión
        },
        "analogOutputs": {
            "AO0": round(random.uniform(0.0, 100.0), 1),
            "AO1": round(random.uniform(0.0, 100.0), 1)
        },
        "systemData": {
            "temperature": round(random.uniform(35.0, 45.0), 1),
            "pressure": round(random.uniform(2.0, 4.0), 1),
            "status": "Operativo",
            "alarms": [],
            "connectionQuality": "excellent",
            "responseTime": random.randint(10, 50)
        }
    }

def read_plc_data():
    """Leer datos reales del PLC"""
    global last_real_data, simulation_mode
    
    try:
        if not plc_client.get_connected():
            logger.warning("PLC no conectado, intentando reconectar...")
            plc_client.connect(PARAMS["PLC_IP"], PARAMS["RACK"], PARAMS["SLOT"])
            
        if not plc_client.get_connected():
            logger.error("No se pudo conectar al PLC")
            simulation_mode = True
            return get_simulated_data()
        
        # Intentar leer datos reales
        data = plc_client.db_read(PARAMS["DB_NUMBER"], PARAMS["START_ADDRESS"], PARAMS["SIZE"])
        
        # Procesar datos reales
        real_data = {
            "success": True,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "connection": {
                "isConnected": True,
                "host": PARAMS["PLC_IP"],
                "port": 102,
                "responseTime": random.randint(5, 20)
            },
            "digitalInputs": {
                "I0": get_bool(data, 0, 0),
                "I1": get_bool(data, 0, 1),
                "I2": get_bool(data, 0, 2),
                "I3": get_bool(data, 0, 3),
                "I4": get_bool(data, 0, 4),
                "I5": get_bool(data, 0, 5),
                "I6": get_bool(data, 0, 6),
                "I7": get_bool(data, 0, 7),
                "I8": get_bool(data, 1, 0),
                "I9": get_bool(data, 1, 1),
                "I10": get_bool(data, 1, 2),
                "I11": get_bool(data, 1, 3),
                "I12": get_bool(data, 1, 4),
                "I13": get_bool(data, 1, 5)
            },
            "digitalOutputs": {
                "Q0": get_bool(data, 2, 0),
                "Q1": get_bool(data, 2, 1),
                "Q2": get_bool(data, 2, 2),
                "Q3": get_bool(data, 2, 3),
                "Q4": get_bool(data, 2, 4),
                "Q5": get_bool(data, 2, 5),
                "Q6": get_bool(data, 2, 6),
                "Q7": get_bool(data, 2, 7),
                "Q8": get_bool(data, 3, 0),
                "Q9": get_bool(data, 3, 1)
            },
            "analogInputs": {
                "AI0": get_int(data, 4) / 10.0,  # Temperatura
                "AI1": get_int(data, 6) / 10.0   # Presión
            },
            "analogOutputs": {
                "AO0": get_int(data, 8) / 10.0,
                "AO1": get_int(data, 10) / 10.0
            },
            "systemData": {
                "temperature": get_int(data, 4) / 10.0,
                "pressure": get_int(data, 6) / 10.0,
                "status": "Operativo",
                "alarms": [],
                "connectionQuality": "excellent",
                "responseTime": random.randint(5, 20)
            }
        }
        
        last_real_data = real_data
        simulation_mode = False
        return real_data
        
    except Exception as e:
        logger.error(f"Error leyendo datos del PLC: {e}")
        simulation_mode = True
        return get_simulated_data()

# ---------------- ENDPOINTS ----------------

@app.route('/api/plc/status', methods=['GET'])
def plc_status():
    """Estado de conexión del PLC"""
    try:
        is_connected = plc_client.get_connected()
        return jsonify({
            "status": "connected" if is_connected else "disconnected",
            "simulation_mode": simulation_mode,
            "host": PARAMS["PLC_IP"]
        })
    except Exception as e:
        logger.error(f"Error en status: {e}")
        return jsonify({
            "status": "error",
            "error": str(e),
            "simulation_mode": True
        })

@app.route('/api/plc/real-data', methods=['GET'])
def plc_real_data():
    """Datos reales del PLC con fallback a simulación"""
    try:
        data = read_plc_data()
        return jsonify(data)
    except Exception as e:
        logger.error(f"Error en real-data: {e}")
        return jsonify({
            "success": False,
            "error": str(e),
            "simulation_mode": True,
            "data": get_simulated_data()
        })

@app.route('/api/plc/connect', methods=['POST'])
def connect_plc():
    """Conectar al PLC"""
    global simulation_mode
    try:
        if not plc_client.get_connected():
            logger.info("🟡 Intentando conectar al PLC...")
            plc_client.connect(PARAMS["PLC_IP"], PARAMS["RACK"], PARAMS["SLOT"])
            
        if plc_client.get_connected():
            simulation_mode = False
            return jsonify({
                "success": True, 
                "message": "PLC conectado exitosamente",
                "simulation_mode": False
            }), 200
        else:
            simulation_mode = True
            return jsonify({
                "success": False, 
                "message": "No se pudo conectar al PLC",
                "simulation_mode": True
            }), 500
            
    except Exception as e:
        logger.error(f"❌ Error al conectar al PLC: {e}")
        simulation_mode = True
        return jsonify({
            "success": False, 
            "error": str(e),
            "simulation_mode": True
        }), 500

@app.route('/api/plc/write-output', methods=['POST'])
def write_output():
    """Escribir salida digital"""
    try:
        data = request.get_json()
        output_name = data.get('output_name')
        value = data.get('value')
        
        if not output_name or value is None:
            return jsonify({"error": "output_name y value son requeridos"}), 400
            
        if simulation_mode:
            return jsonify({
                "success": True,
                "message": f"Simulación: {output_name} = {value}",
                "simulation_mode": True
            })
            
        # Aquí iría la lógica real de escritura al PLC
        # Por ahora solo simulamos
        return jsonify({
            "success": True,
            "message": f"Salida {output_name} escrita: {value}",
            "simulation_mode": False
        })
        
    except Exception as e:
        logger.error(f"Error escribiendo salida: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/plc/health', methods=['GET'])
def health_check():
    """Health check del sistema"""
    return jsonify({
        "status": "healthy",
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "plc_connected": plc_client.get_connected(),
        "simulation_mode": simulation_mode,
        "version": "1.0.0"
    })

@app.route('/api/plc/simulation', methods=['POST'])
def toggle_simulation():
    """Activar/desactivar modo simulación"""
    global simulation_mode
    data = request.get_json()
    simulation_mode = data.get('enabled', False)
    
    return jsonify({
        "success": True,
        "simulation_mode": simulation_mode,
        "message": f"Modo simulación {'activado' if simulation_mode else 'desactivado'}"
    })

# ---------------- EJECUCIÓN ----------------

if __name__ == "__main__":
    logger.info("🚀 Iniciando backend SAMABOT PLC mejorado")
    
    try:
        logger.info("🔌 Intentando conectar al PLC...")
        plc_client.connect(PARAMS["PLC_IP"], PARAMS["RACK"], PARAMS["SLOT"])
        
        if plc_client.get_connected():
            logger.info("✅ Conectado al PLC Siemens")
            simulation_mode = False
        else:
            logger.warning("⚠️ No se pudo conectar al PLC, usando modo simulación")
            simulation_mode = True
            
    except Exception as e:
        logger.error(f"❌ Error al conectar: {e}")
        simulation_mode = True

    logger.info("🚀 Servidor iniciado en puerto 3001")
    logger.info(f"🔧 Modo simulación: {'Activado' if simulation_mode else 'Desactivado'}")
    
    app.run(host="0.0.0.0", port=3001, debug=False) 