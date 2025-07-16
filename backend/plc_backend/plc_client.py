"""
PLC Client para comunicación con PLC Siemens S7-1200 usando Snap7.

Este módulo proporciona una clase PLCClient que maneja la conexión,
reconexión automática y operaciones de lectura/escritura con el PLC.
"""

import time
import logging
from typing import Optional, List, Dict, Any, Tuple
from dataclasses import dataclass
from enum import Enum
import snap7
from snap7.util import get_bool, set_bool, get_int, set_int


class ConnectionQuality(Enum):
    """Estados de calidad de conexión."""
    CONNECTED = "connected"
    DISCONNECTED = "disconnected"
    RECONNECTING = "reconnecting"


@dataclass
class Alarm:
    """Estructura para alarmas del sistema."""
    id: str
    message: str
    timestamp: float
    severity: str = "warning"


class PLCClient:
    """
    Cliente para comunicación con PLC Siemens S7-1200.
    
    Maneja conexión automática, reconexión exponencial y operaciones
    de lectura/escritura de I/O y valores analógicos.
    """
    
    def __init__(
        self,
        ip: str = "192.168.1.5",
        rack: int = 0,
        slot: int = 1,
        max_reconnect_attempts: int = 5,
        base_delay: float = 1.0
    ):
        """
        Inicializar cliente PLC.
        
        Args:
            ip: IP del PLC Siemens
            rack: Número de rack (0 para S7-1200)
            slot: Número de slot (1 para S7-1200)
            max_reconnect_attempts: Máximo intentos de reconexión
            base_delay: Delay base para reconexión exponencial
        """
        self.ip = ip
        self.rack = rack
        self.slot = slot
        self.max_reconnect_attempts = max_reconnect_attempts
        self.base_delay = base_delay
        
        self.client = snap7.client.Client()
        self.connection_quality = ConnectionQuality.DISCONNECTED
        self.last_connection_attempt = 0
        self.reconnect_attempts = 0
        self.alarms: List[Alarm] = []
        self.max_alarms = 50
        
        # Configurar logging
        self.logger = logging.getLogger(__name__)
        
    def connect(self) -> bool:
        """
        Conectar al PLC con reconexión automática.
        
        Returns:
            True si la conexión fue exitosa
        """
        try:
            if self.client.get_connected():
                self.connection_quality = ConnectionQuality.CONNECTED
                self.reconnect_attempts = 0
                self.logger.info(f"Conectado al PLC en {self.ip}")
                return True
                
            self.client.connect(self.ip, self.rack, self.slot)
            
            if self.client.get_connected():
                self.connection_quality = ConnectionQuality.CONNECTED
                self.reconnect_attempts = 0
                self.logger.info(f"Conectado exitosamente al PLC en {self.ip}")
                return True
            else:
                self.connection_quality = ConnectionQuality.DISCONNECTED
                self.logger.error(f"No se pudo conectar al PLC en {self.ip}")
                return False
                
        except Exception as e:
            self.connection_quality = ConnectionQuality.DISCONNECTED
            self.logger.error(f"Error conectando al PLC: {e}")
            return False
    
    def disconnect(self) -> None:
        """Desconectar del PLC."""
        if self.client.get_connected():
            self.client.disconnect()
        self.connection_quality = ConnectionQuality.DISCONNECTED
        self.logger.info("Desconectado del PLC")
    
    def _attempt_reconnect(self) -> bool:
        """
        Intentar reconexión con delay exponencial.
        
        Returns:
            True si la reconexión fue exitosa
        """
        if self.reconnect_attempts >= self.max_reconnect_attempts:
            self.logger.error("Máximo intentos de reconexión alcanzado")
            return False
            
        self.connection_quality = ConnectionQuality.RECONNECTING
        delay = self.base_delay * (2 ** self.reconnect_attempts)
        
        self.logger.info(f"Intentando reconexión #{self.reconnect_attempts + 1} en {delay}s")
        time.sleep(delay)
        
        if self.connect():
            self.logger.info("Reconexión exitosa")
            return True
        else:
            self.reconnect_attempts += 1
            return False
    
    def ensure_connection(self) -> bool:
        """
        Asegurar conexión activa, intentando reconexión si es necesario.
        
        Returns:
            True si hay conexión activa
        """
        if self.client.get_connected():
            self.connection_quality = ConnectionQuality.CONNECTED
            return True
            
        return self._attempt_reconnect()
    
    def read_inputs(self) -> Dict[str, bool]:
        """
        Leer entradas digitales I0-I13.
        
        Returns:
            Diccionario con estado de entradas {I0: True, I1: False, ...}
        """
        if not self.ensure_connection():
            return {}
            
        try:
            # Leer área de entradas (I) - 2 bytes (I0-I15)
            data = self.client.db_read(0, 0, 2)  # DB0, offset 0, 2 bytes
            
            inputs = {}
            for i in range(14):  # I0-I13
                bit_position = i % 8
                byte_index = i // 8
                if byte_index < len(data):
                    inputs[f"I{i}"] = get_bool(data, byte_index, bit_position)
                else:
                    inputs[f"I{i}"] = False
                    
            return inputs
            
        except Exception as e:
            self.logger.error(f"Error leyendo entradas: {e}")
            return {}
    
    def read_outputs(self) -> Dict[str, bool]:
        """
        Leer salidas digitales Q0-Q9.
        
        Returns:
            Diccionario con estado de salidas {Q0: True, Q1: False, ...}
        """
        if not self.ensure_connection():
            return {}
            
        try:
            # Leer área de salidas (Q) - 2 bytes (Q0-Q15)
            data = self.client.db_read(0, 2, 2)  # DB0, offset 2, 2 bytes
            
            outputs = {}
            for i in range(10):  # Q0-Q9
                bit_position = i % 8
                byte_index = i // 8
                if byte_index < len(data):
                    outputs[f"Q{i}"] = get_bool(data, byte_index, bit_position)
                else:
                    outputs[f"Q{i}"] = False
                    
            return outputs
            
        except Exception as e:
            self.logger.error(f"Error leyendo salidas: {e}")
            return {}
    
    def write_output(self, output_name: str, value: bool) -> bool:
        """
        Escribir salida digital específica.
        
        Args:
            output_name: Nombre de la salida (ej: "Q0")
            value: Valor a escribir (True/False)
            
        Returns:
            True si la escritura fue exitosa
        """
        if not self.ensure_connection():
            return False
            
        try:
            # Validar nombre de salida
            if not output_name.startswith("Q") or not output_name[1:].isdigit():
                self.logger.error(f"Nombre de salida inválido: {output_name}")
                return False
                
            output_num = int(output_name[1:])
            if output_num < 0 or output_num > 9:
                self.logger.error(f"Número de salida fuera de rango: {output_num}")
                return False
            
            # Leer estado actual de salidas
            data = self.client.db_read(0, 2, 2)
            
            # Modificar bit específico
            byte_index = output_num // 8
            bit_position = output_num % 8
            
            if byte_index < len(data):
                set_bool(data, byte_index, bit_position, value)
                
                # Escribir datos modificados
                self.client.db_write(0, 2, data)
                self.logger.info(f"Salida {output_name} escrita: {value}")
                return True
            else:
                self.logger.error(f"Índice de byte fuera de rango: {byte_index}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error escribiendo salida {output_name}: {e}")
            return False
    
    def read_analog_inputs(self) -> Dict[str, float]:
        """
        Leer entradas analógicas AI0-AI1.
        
        Returns:
            Diccionario con valores analógicos {AI0: 25.5, AI1: 2.1}
        """
        if not self.ensure_connection():
            return {}
            
        try:
            # Leer valores analógicos - 4 bytes (2 words)
            data = self.client.db_read(0, 4, 4)  # DB0, offset 4, 4 bytes
            
            analog_inputs = {}
            
            # AI0 (primeros 2 bytes)
            if len(data) >= 2:
                ai0_raw = get_int(data, 0)
                # Convertir a valor real (ajustar según calibración del PLC)
                analog_inputs["AI0"] = ai0_raw / 10.0  # Ejemplo: dividir por 10
            else:
                analog_inputs["AI0"] = 0.0
                
            # AI1 (siguientes 2 bytes)
            if len(data) >= 4:
                ai1_raw = get_int(data, 2)
                analog_inputs["AI1"] = ai1_raw / 10.0
            else:
                analog_inputs["AI1"] = 0.0
                
            return analog_inputs
            
        except Exception as e:
            self.logger.error(f"Error leyendo entradas analógicas: {e}")
            return {}
    
    def check_alarms(self) -> None:
        """
        Verificar condiciones de alarma y actualizar lista de alarmas.
        """
        analog_inputs = self.read_analog_inputs()
        
        current_time = time.time()
        
        # Verificar temperatura alta (AI0 > 40°C)
        if "AI0" in analog_inputs and analog_inputs["AI0"] > 40:
            self._add_alarm("HIGH_TEMPERATURE", f"Temperatura alta: {analog_inputs['AI0']:.1f}°C")
        
        # Verificar presión alta (AI1 > 3 bar)
        if "AI1" in analog_inputs and analog_inputs["AI1"] > 3:
            self._add_alarm("HIGH_PRESSURE", f"Presión alta: {analog_inputs['AI1']:.1f} bar")
    
    def _add_alarm(self, alarm_id: str, message: str) -> None:
        """
        Agregar alarma a la lista (FIFO, máximo 50).
        
        Args:
            alarm_id: Identificador único de la alarma
            message: Mensaje descriptivo
        """
        # Verificar si ya existe una alarma similar reciente (últimos 30 segundos)
        current_time = time.time()
        for alarm in self.alarms:
            if (alarm.id == alarm_id and 
                current_time - alarm.timestamp < 30):
                return  # No agregar alarma duplicada
        
        # Agregar nueva alarma
        new_alarm = Alarm(
            id=alarm_id,
            message=message,
            timestamp=current_time,
            severity="warning"
        )
        
        self.alarms.append(new_alarm)
        
        # Mantener solo las últimas 50 alarmas
        if len(self.alarms) > self.max_alarms:
            self.alarms = self.alarms[-self.max_alarms:]
        
        self.logger.warning(f"Nueva alarma: {message}")
    
    def get_status(self) -> Dict[str, Any]:
        """
        Obtener estado completo del sistema.
        
        Returns:
            Diccionario con estado de conexión, I/O, alarmas, etc.
        """
        return {
            "connectionQuality": self.connection_quality.value,
            "ip": self.ip,
            "rack": self.rack,
            "slot": self.slot,
            "reconnectAttempts": self.reconnect_attempts,
            "inputs": self.read_inputs(),
            "outputs": self.read_outputs(),
            "analogInputs": self.read_analog_inputs(),
            "alarms": [
                {
                    "id": alarm.id,
                    "message": alarm.message,
                    "timestamp": alarm.timestamp,
                    "severity": alarm.severity
                }
                for alarm in self.alarms
            ],
            "lastUpdate": time.time()
        }
    
    def health_check(self) -> bool:
        """
        Verificar salud de la conexión.
        
        Returns:
            True si la conexión está saludable
        """
        try:
            if not self.client.get_connected():
                return False
            
            # Intentar una lectura simple para verificar conectividad
            self.client.db_read(0, 0, 1)
            return True
            
        except Exception as e:
            self.logger.error(f"Health check falló: {e}")
            return False 