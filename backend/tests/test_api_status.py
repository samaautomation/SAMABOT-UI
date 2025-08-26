"""
Tests para el endpoint /status de la API PLC.

Este módulo contiene tests que verifican:
- Respuesta correcta del endpoint /status
- Estructura de datos válida
- Manejo de errores de conexión
"""

import pytest
from unittest.mock import patch, Mock
from httpx import AsyncClient

from snap7.snap7_backend import app


@pytest.mark.asyncio
@pytest.mark.plc
async def test_status_endpoint_success(api_client: AsyncClient, sample_status_response):
    """
    Test que verifica respuesta exitosa del endpoint /status.
    
    Args:
        api_client: Cliente HTTP para testing
        sample_status_response: Datos de ejemplo del estado
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC
        mock_client = Mock()
        mock_client.get_status.return_value = sample_status_response
        mock_get_client.return_value = mock_client
        
        # Hacer request al endpoint
        response = await api_client.get("/status")
        
        # Verificar respuesta exitosa
        assert response.status_code == 200
        
        # Verificar estructura de datos
        data = response.json()
        assert "connectionQuality" in data
        assert "ip" in data
        assert "rack" in data
        assert "slot" in data
        assert "reconnectAttempts" in data
        assert "inputs" in data
        assert "outputs" in data
        assert "analogInputs" in data
        assert "alarms" in data
        assert "lastUpdate" in data
        
        # Verificar valores específicos
        assert data["connectionQuality"] == "connected"
        assert data["ip"] == "192.168.1.5"
        assert data["rack"] == 0
        assert data["slot"] == 1
        assert data["reconnectAttempts"] == 0
        
        # Verificar entradas digitales
        assert len(data["inputs"]) == 14  # I0-I13
        assert data["inputs"]["I0"] is True
        assert data["inputs"]["I1"] is False
        
        # Verificar salidas digitales
        assert len(data["outputs"]) == 10  # Q0-Q9
        assert data["outputs"]["Q0"] is True
        assert data["outputs"]["Q1"] is False
        
        # Verificar entradas analógicas
        assert len(data["analogInputs"]) == 2  # AI0-AI1
        assert data["analogInputs"]["AI0"] == 25.5
        assert data["analogInputs"]["AI1"] == 2.1
        
        # Verificar alarmas
        assert isinstance(data["alarms"], list)
        if data["alarms"]:
            alarm = data["alarms"][0]
            assert "id" in alarm
            assert "message" in alarm
            assert "timestamp" in alarm
            assert "severity" in alarm


@pytest.mark.asyncio
@pytest.mark.plc
async def test_status_endpoint_connection_error(api_client: AsyncClient):
    """
    Test que verifica manejo de errores de conexión en /status.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC que lanza excepción
        mock_client = Mock()
        mock_client.get_status.side_effect = Exception("Error de conexión")
        mock_get_client.return_value = mock_client
        
        # Hacer request al endpoint
        response = await api_client.get("/status")
        
        # Verificar error 500
        assert response.status_code == 500
        
        # Verificar mensaje de error
        data = response.json()
        assert "detail" in data
        assert "Error interno" in data["detail"]


@pytest.mark.asyncio
@pytest.mark.plc
async def test_status_endpoint_empty_data(api_client: AsyncClient):
    """
    Test que verifica respuesta con datos vacíos del PLC.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC con datos vacíos
        mock_client = Mock()
        mock_client.get_status.return_value = {
            "connectionQuality": "disconnected",
            "ip": "192.168.1.5",
            "rack": 0,
            "slot": 1,
            "reconnectAttempts": 3,
            "inputs": {},
            "outputs": {},
            "analogInputs": {},
            "alarms": [],
            "lastUpdate": 1703123456.789
        }
        mock_get_client.return_value = mock_client
        
        # Hacer request al endpoint
        response = await api_client.get("/status")
        
        # Verificar respuesta exitosa
        assert response.status_code == 200
        
        # Verificar datos vacíos
        data = response.json()
        assert data["connectionQuality"] == "disconnected"
        assert data["inputs"] == {}
        assert data["outputs"] == {}
        assert data["analogInputs"] == {}
        assert data["alarms"] == []


@pytest.mark.asyncio
@pytest.mark.plc
async def test_status_endpoint_reconnecting_state(api_client: AsyncClient):
    """
    Test que verifica estado de reconexión en /status.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC en estado de reconexión
        mock_client = Mock()
        mock_client.get_status.return_value = {
            "connectionQuality": "reconnecting",
            "ip": "192.168.1.5",
            "rack": 0,
            "slot": 1,
            "reconnectAttempts": 2,
            "inputs": {},
            "outputs": {},
            "analogInputs": {},
            "alarms": [],
            "lastUpdate": 1703123456.789
        }
        mock_get_client.return_value = mock_client
        
        # Hacer request al endpoint
        response = await api_client.get("/status")
        
        # Verificar respuesta exitosa
        assert response.status_code == 200
        
        # Verificar estado de reconexión
        data = response.json()
        assert data["connectionQuality"] == "reconnecting"
        assert data["reconnectAttempts"] == 2


@pytest.mark.asyncio
@pytest.mark.plc
async def test_status_endpoint_with_alarms(api_client: AsyncClient):
    """
    Test que verifica respuesta con alarmas activas.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC con alarmas
        mock_client = Mock()
        mock_client.get_status.return_value = {
            "connectionQuality": "connected",
            "ip": "192.168.1.5",
            "rack": 0,
            "slot": 1,
            "reconnectAttempts": 0,
            "inputs": {"I0": True, "I1": False},
            "outputs": {"Q0": True, "Q1": False},
            "analogInputs": {"AI0": 45.0, "AI1": 3.5},
            "alarms": [
                {
                    "id": "HIGH_TEMPERATURE",
                    "message": "Temperatura alta: 45.0°C",
                    "timestamp": 1703123456.789,
                    "severity": "warning"
                },
                {
                    "id": "HIGH_PRESSURE",
                    "message": "Presión alta: 3.5 bar",
                    "timestamp": 1703123457.123,
                    "severity": "warning"
                }
            ],
            "lastUpdate": 1703123456.789
        }
        mock_get_client.return_value = mock_client
        
        # Hacer request al endpoint
        response = await api_client.get("/status")
        
        # Verificar respuesta exitosa
        assert response.status_code == 200
        
        # Verificar alarmas
        data = response.json()
        assert len(data["alarms"]) == 2
        
        # Verificar primera alarma
        alarm1 = data["alarms"][0]
        assert alarm1["id"] == "HIGH_TEMPERATURE"
        assert "Temperatura alta" in alarm1["message"]
        assert alarm1["severity"] == "warning"
        
        # Verificar segunda alarma
        alarm2 = data["alarms"][1]
        assert alarm2["id"] == "HIGH_PRESSURE"
        assert "Presión alta" in alarm2["message"]
        assert alarm2["severity"] == "warning" 