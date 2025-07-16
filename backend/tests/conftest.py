"""
Configuración de pytest para tests del backend PLC.

Este archivo contiene fixtures comunes para testing de la API
y el cliente PLC, incluyendo mocks para comunicación real.
"""

import pytest
import asyncio
from unittest.mock import Mock, patch, MagicMock
from typing import Dict, Any

from snap7.plc_client import PLCClient, ConnectionQuality, Alarm


@pytest.fixture
def mock_snap7_client():
    """
    Mock del cliente Snap7 para testing sin PLC real.
    
    Returns:
        Mock del cliente Snap7 con métodos simulados
    """
    mock_client = Mock()
    
    # Simular métodos de conexión
    mock_client.get_connected.return_value = True
    mock_client.connect.return_value = None
    mock_client.disconnect.return_value = None
    
    # Simular lectura de datos
    mock_client.db_read.return_value = bytearray([0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    mock_client.db_write.return_value = None
    
    return mock_client


@pytest.fixture
def plc_client_mock(mock_snap7_client):
    """
    Cliente PLC con Snap7 mockeado para testing.
    
    Args:
        mock_snap7_client: Mock del cliente Snap7
        
    Returns:
        Instancia de PLCClient con Snap7 mockeado
    """
    with patch('snap7.client.Client', return_value=mock_snap7_client):
        client = PLCClient(ip="192.168.1.5")
        client.connection_quality = ConnectionQuality.CONNECTED
        return client


@pytest.fixture
def sample_status_response() -> Dict[str, Any]:
    """
    Respuesta de ejemplo para endpoint /status.
    
    Returns:
        Diccionario con datos de ejemplo del estado del sistema
    """
    return {
        "connectionQuality": "connected",
        "ip": "192.168.1.5",
        "rack": 0,
        "slot": 1,
        "reconnectAttempts": 0,
        "inputs": {
            "I0": True,
            "I1": False,
            "I2": True,
            "I3": False,
            "I4": True,
            "I5": False,
            "I6": True,
            "I7": False,
            "I8": True,
            "I9": False,
            "I10": True,
            "I11": False,
            "I12": True,
            "I13": False
        },
        "outputs": {
            "Q0": True,
            "Q1": False,
            "Q2": True,
            "Q3": False,
            "Q4": True,
            "Q5": False,
            "Q6": True,
            "Q7": False,
            "Q8": True,
            "Q9": False
        },
        "analogInputs": {
            "AI0": 25.5,
            "AI1": 2.1
        },
        "alarms": [
            {
                "id": "HIGH_TEMPERATURE",
                "message": "Temperatura alta: 42.5°C",
                "timestamp": 1703123456.789,
                "severity": "warning"
            }
        ],
        "lastUpdate": 1703123456.789
    }


@pytest.fixture
def sample_alarm() -> Alarm:
    """
    Alarma de ejemplo para testing.
    
    Returns:
        Instancia de Alarm con datos de ejemplo
    """
    return Alarm(
        id="TEST_ALARM",
        message="Alarma de prueba",
        timestamp=1703123456.789,
        severity="warning"
    )


@pytest.fixture
def event_loop():
    """
    Event loop para tests asíncronos.
    
    Returns:
        Event loop configurado para testing
    """
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def api_client():
    """
    Cliente HTTP para testing de la API.
    
    Returns:
        Cliente HTTP configurado para testing
    """
    from httpx import AsyncClient
    from snap7.snap7_backend import app
    
    return AsyncClient(app=app, base_url="http://test") 