#!/usr/bin/env python3
"""
Script de prueba para verificar el backend SAMABOT PLC.

Este script prueba:
1. Importación de módulos
2. Creación de cliente PLC
3. Endpoints de la API
4. Funcionalidad básica sin PLC real
"""

import sys
import os
import asyncio
import logging
from unittest.mock import Mock, patch

# Agregar el directorio backend al path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def test_imports():
    """Probar que todos los módulos se importan correctamente."""
    try:
        from plc_backend.plc_client import PLCClient, ConnectionQuality, Alarm
        from plc_backend.snap7_backend import app
        logger.info("✅ Imports exitosos")
        return True
    except ImportError as e:
        logger.error(f"❌ Error en imports: {e}")
        return False


def test_plc_client_creation():
    """Probar creación del cliente PLC."""
    try:
        from plc_backend.plc_client import PLCClient
        
        # Crear cliente con Snap7 mockeado
        with patch('snap7.client.Client') as mock_client_class:
            mock_client = Mock()
            mock_client.get_connected.return_value = True
            mock_client_class.return_value = mock_client
            
            client = PLCClient(ip="192.168.1.5")
            
            # Verificar propiedades
            assert client.ip == "192.168.1.5"
            assert client.rack == 0
            assert client.slot == 1
            assert client.max_reconnect_attempts == 5
            
            logger.info("✅ Cliente PLC creado correctamente")
            return True
            
    except Exception as e:
        logger.error(f"❌ Error creando cliente PLC: {e}")
        return False


def test_connection_quality_enum():
    """Probar enum de calidad de conexión."""
    try:
        from plc_backend.plc_client import ConnectionQuality
        
        # Verificar valores del enum
        assert ConnectionQuality.CONNECTED.value == "connected"
        assert ConnectionQuality.DISCONNECTED.value == "disconnected"
        assert ConnectionQuality.RECONNECTING.value == "reconnecting"
        
        logger.info("✅ Enum ConnectionQuality funciona correctamente")
        return True
        
    except Exception as e:
        logger.error(f"❌ Error en enum ConnectionQuality: {e}")
        return False


def test_alarm_dataclass():
    """Probar dataclass de alarma."""
    try:
        from plc_backend.plc_client import Alarm
        import time
        
        # Crear alarma de prueba
        alarm = Alarm(
            id="TEST_ALARM",
            message="Alarma de prueba",
            timestamp=time.time(),
            severity="warning"
        )
        
        # Verificar propiedades
        assert alarm.id == "TEST_ALARM"
        assert alarm.message == "Alarma de prueba"
        assert alarm.severity == "warning"
        
        logger.info("✅ Dataclass Alarm funciona correctamente")
        return True
        
    except Exception as e:
        logger.error(f"❌ Error en dataclass Alarm: {e}")
        return False


async def test_api_endpoints():
    """Probar endpoints de la API."""
    try:
        from plc_backend.snap7_backend import app
        from httpx import AsyncClient
        
        # Crear cliente de prueba
        async with AsyncClient(app=app, base_url="http://test") as client:
            
            # Probar endpoint raíz
            response = await client.get("/")
            assert response.status_code == 200
            data = response.json()
            assert data["name"] == "SAMABOT PLC API"
            
            # Probar endpoint de health check
            response = await client.get("/healthz")
            assert response.status_code == 200
            data = response.json()
            assert "healthy" in data
            assert "connection_quality" in data
            
            logger.info("✅ Endpoints de API funcionan correctamente")
            return True
            
    except Exception as e:
        logger.error(f"❌ Error probando endpoints: {e}")
        return False


def test_requirements():
    """Verificar que las dependencias están disponibles."""
    try:
        import fastapi
        import uvicorn
        import pydantic
        import snap7
        
        logger.info("✅ Todas las dependencias están disponibles")
        return True
        
    except ImportError as e:
        logger.error(f"❌ Dependencia faltante: {e}")
        return False


async def main():
    """Función principal de pruebas."""
    logger.info("🚀 Iniciando pruebas del backend SAMABOT PLC")
    
    tests = [
        ("Imports", test_imports),
        ("Cliente PLC", test_plc_client_creation),
        ("Enum ConnectionQuality", test_connection_quality_enum),
        ("Dataclass Alarm", test_alarm_dataclass),
        ("Dependencias", test_requirements),
        ("Endpoints API", test_api_endpoints),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        logger.info(f"\n📋 Probando: {test_name}")
        try:
            if asyncio.iscoroutinefunction(test_func):
                result = await test_func()
            else:
                result = test_func()
                
            if result:
                passed += 1
                logger.info(f"✅ {test_name}: PASÓ")
            else:
                logger.error(f"❌ {test_name}: FALLÓ")
                
        except Exception as e:
            logger.error(f"❌ {test_name}: ERROR - {e}")
    
    logger.info(f"\n📊 Resultados: {passed}/{total} pruebas pasaron")
    
    if passed == total:
        logger.info("🎉 ¡Todas las pruebas pasaron!")
        return True
    else:
        logger.error("💥 Algunas pruebas fallaron")
        return False


if __name__ == "__main__":
    success = asyncio.run(main())
    sys.exit(0 if success else 1) 