"""
Tests para el endpoint /output de la API PLC.

Este módulo contiene tests que verifican:
- Escritura exitosa de salidas digitales
- Validación de parámetros de entrada
- Manejo de errores de escritura
- Respuestas correctas del endpoint
"""

import pytest
from unittest.mock import patch, Mock
from httpx import AsyncClient


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_success(api_client: AsyncClient):
    """
    Test que verifica escritura exitosa de salida digital.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC
        mock_client = Mock()
        mock_client.write_output.return_value = True
        mock_get_client.return_value = mock_client
        
        # Datos de prueba
        test_data = {
            "output_name": "Q0",
            "value": True
        }
        
        # Hacer request al endpoint
        response = await api_client.post("/output", json=test_data)
        
        # Verificar respuesta exitosa
        assert response.status_code == 200
        
        # Verificar estructura de respuesta
        data = response.json()
        assert data["success"] is True
        assert "message" in data
        assert data["output_name"] == "Q0"
        assert data["value"] is True
        assert "escrita exitosamente" in data["message"]
        
        # Verificar que se llamó al método correcto
        mock_client.write_output.assert_called_once_with("Q0", True)


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_failure(api_client: AsyncClient):
    """
    Test que verifica manejo de fallo en escritura de salida.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC que falla
        mock_client = Mock()
        mock_client.write_output.return_value = False
        mock_get_client.return_value = mock_client
        
        # Datos de prueba
        test_data = {
            "output_name": "Q1",
            "value": False
        }
        
        # Hacer request al endpoint
        response = await api_client.post("/output", json=test_data)
        
        # Verificar error 400
        assert response.status_code == 400
        
        # Verificar mensaje de error
        data = response.json()
        assert "detail" in data
        assert "No se pudo escribir la salida Q1" in data["detail"]


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_invalid_name(api_client: AsyncClient):
    """
    Test que verifica validación de nombre de salida inválido.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    # Datos de prueba con nombre inválido
    test_data = {
        "output_name": "INVALID",
        "value": True
    }
    
    # Hacer request al endpoint
    response = await api_client.post("/output", json=test_data)
    
    # Verificar error 400
    assert response.status_code == 400
    
    # Verificar mensaje de error
    data = response.json()
    assert "detail" in data
    assert "No se pudo escribir la salida INVALID" in data["detail"]


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_out_of_range(api_client: AsyncClient):
    """
    Test que verifica validación de salida fuera de rango.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    # Datos de prueba con salida fuera de rango
    test_data = {
        "output_name": "Q15",  # Fuera del rango Q0-Q9
        "value": True
    }
    
    # Hacer request al endpoint
    response = await api_client.post("/output", json=test_data)
    
    # Verificar error 400
    assert response.status_code == 400
    
    # Verificar mensaje de error
    data = response.json()
    assert "detail" in data
    assert "No se pudo escribir la salida Q15" in data["detail"]


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_missing_fields(api_client: AsyncClient):
    """
    Test que verifica validación de campos faltantes.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    # Datos de prueba incompletos
    test_data = {
        "output_name": "Q0"
        # Falta el campo "value"
    }
    
    # Hacer request al endpoint
    response = await api_client.post("/output", json=test_data)
    
    # Verificar error 422 (Unprocessable Entity)
    assert response.status_code == 422


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_wrong_type(api_client: AsyncClient):
    """
    Test que verifica validación de tipos de datos.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    # Datos de prueba con tipo incorrecto
    test_data = {
        "output_name": 123,  # Debería ser string
        "value": "true"  # Debería ser boolean
    }
    
    # Hacer request al endpoint
    response = await api_client.post("/output", json=test_data)
    
    # Verificar error 422
    assert response.status_code == 422


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_connection_error(api_client: AsyncClient):
    """
    Test que verifica manejo de errores de conexión.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC que lanza excepción
        mock_client = Mock()
        mock_client.write_output.side_effect = Exception("Error de conexión")
        mock_get_client.return_value = mock_client
        
        # Datos de prueba
        test_data = {
            "output_name": "Q2",
            "value": True
        }
        
        # Hacer request al endpoint
        response = await api_client.post("/output", json=test_data)
        
        # Verificar error 500
        assert response.status_code == 500
        
        # Verificar mensaje de error
        data = response.json()
        assert "detail" in data
        assert "Error interno" in data["detail"]


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_multiple_outputs(api_client: AsyncClient):
    """
    Test que verifica escritura de múltiples salidas.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC
        mock_client = Mock()
        mock_client.write_output.return_value = True
        mock_get_client.return_value = mock_client
        
        # Probar diferentes salidas
        test_cases = [
            {"output_name": "Q0", "value": True},
            {"output_name": "Q1", "value": False},
            {"output_name": "Q2", "value": True},
            {"output_name": "Q3", "value": False},
            {"output_name": "Q4", "value": True},
            {"output_name": "Q5", "value": False},
            {"output_name": "Q6", "value": True},
            {"output_name": "Q7", "value": False},
            {"output_name": "Q8", "value": True},
            {"output_name": "Q9", "value": False}
        ]
        
        for test_case in test_cases:
            # Hacer request al endpoint
            response = await api_client.post("/output", json=test_case)
            
            # Verificar respuesta exitosa
            assert response.status_code == 200
            
            # Verificar datos de respuesta
            data = response.json()
            assert data["success"] is True
            assert data["output_name"] == test_case["output_name"]
            assert data["value"] == test_case["value"]
            
            # Verificar que se llamó al método correcto
            mock_client.write_output.assert_called_with(
                test_case["output_name"], 
                test_case["value"]
            )


@pytest.mark.asyncio
@pytest.mark.plc
async def test_write_output_boolean_values(api_client: AsyncClient):
    """
    Test que verifica escritura de valores booleanos.
    
    Args:
        api_client: Cliente HTTP para testing
    """
    with patch('snap7.snap7_backend.get_plc_client') as mock_get_client:
        # Mock del cliente PLC
        mock_client = Mock()
        mock_client.write_output.return_value = True
        mock_get_client.return_value = mock_client
        
        # Probar valores booleanos
        test_cases = [
            {"output_name": "Q0", "value": True},
            {"output_name": "Q1", "value": False},
            {"output_name": "Q2", "value": True},
            {"output_name": "Q3", "value": False}
        ]
        
        for test_case in test_cases:
            # Hacer request al endpoint
            response = await api_client.post("/output", json=test_case)
            
            # Verificar respuesta exitosa
            assert response.status_code == 200
            
            # Verificar tipo de dato
            data = response.json()
            assert isinstance(data["value"], bool)
            assert data["value"] == test_case["value"] 