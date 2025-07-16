"""
Backend REST para comunicación con PLC Siemens usando Snap7.

Este módulo proporciona una API REST que expone endpoints para:
- Conectar/desconectar del PLC
- Obtener estado completo del sistema
- Escribir salidas digitales
- Health check de la conexión
"""

import logging
import time
from typing import Dict, Any, Optional
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn

from .plc_client import PLCClient


# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Crear aplicación FastAPI
app = FastAPI(
    title="SAMABOT PLC API",
    description="API REST para comunicación con PLC Siemens S7-1200",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios específicos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Instancia global del cliente PLC
plc_client: Optional[PLCClient] = None


class OutputWriteRequest(BaseModel):
    """Modelo para solicitud de escritura de salida."""
    output_name: str = Field(..., description="Nombre de la salida (ej: Q0)")
    value: bool = Field(..., description="Valor a escribir (True/False)")


class OutputWriteResponse(BaseModel):
    """Modelo para respuesta de escritura de salida."""
    success: bool
    message: str
    output_name: str
    value: bool


class StatusResponse(BaseModel):
    """Modelo para respuesta de estado del sistema."""
    connectionQuality: str
    ip: str
    rack: int
    slot: int
    reconnectAttempts: int
    inputs: Dict[str, bool]
    outputs: Dict[str, bool]
    analogInputs: Dict[str, float]
    alarms: list
    lastUpdate: float


class HealthResponse(BaseModel):
    """Modelo para respuesta de health check."""
    healthy: bool
    connection_quality: str
    message: str


def get_plc_client() -> PLCClient:
    """
    Obtener instancia del cliente PLC, creándola si no existe.
    
    Returns:
        Instancia del cliente PLC
    """
    global plc_client
    if plc_client is None:
        plc_client = PLCClient()
    return plc_client


def background_alarm_check():
    """
    Tarea en background para verificar alarmas periódicamente.
    """
    while True:
        try:
            client = get_plc_client()
            client.check_alarms()
            time.sleep(5)  # Verificar cada 5 segundos
        except Exception as e:
            logger.error(f"Error en verificación de alarmas: {e}")
            time.sleep(10)  # Esperar más tiempo si hay error


@app.on_event("startup")
async def startup_event():
    """Evento de inicio de la aplicación."""
    logger.info("Iniciando SAMABOT PLC API")
    
    # Iniciar verificación de alarmas en background
    import asyncio
    asyncio.create_task(asyncio.to_thread(background_alarm_check))


@app.on_event("shutdown")
async def shutdown_event():
    """Evento de cierre de la aplicación."""
    logger.info("Cerrando SAMABOT PLC API")
    if plc_client:
        plc_client.disconnect()


@app.get("/", response_model=Dict[str, str])
async def root():
    """
    Endpoint raíz con información básica de la API.
    
    Returns:
        Información básica de la API
    """
    return {
        "name": "SAMABOT PLC API",
        "version": "1.0.0",
        "description": "API REST para comunicación con PLC Siemens S7-1200"
    }


@app.post("/connect", response_model=Dict[str, Any])
async def connect():
    """
    Conectar al PLC Siemens.
    
    Returns:
        Estado de la conexión
    """
    try:
        client = get_plc_client()
        success = client.connect()
        
        return {
            "success": success,
            "connectionQuality": client.connection_quality.value,
            "ip": client.ip,
            "rack": client.rack,
            "slot": client.slot,
            "message": "Conectado exitosamente" if success else "Error al conectar"
        }
        
    except Exception as e:
        logger.error(f"Error en endpoint /connect: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")


@app.post("/disconnect", response_model=Dict[str, Any])
async def disconnect():
    """
    Desconectar del PLC Siemens.
    
    Returns:
        Estado de la desconexión
    """
    try:
        client = get_plc_client()
        client.disconnect()
        
        return {
            "success": True,
            "connectionQuality": client.connection_quality.value,
            "message": "Desconectado exitosamente"
        }
        
    except Exception as e:
        logger.error(f"Error en endpoint /disconnect: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")


@app.get("/status", response_model=StatusResponse)
async def get_status():
    """
    Obtener estado completo del sistema PLC.
    
    Returns:
        Estado completo incluyendo I/O, alarmas y calidad de conexión
    """
    try:
        client = get_plc_client()
        status = client.get_status()
        return StatusResponse(**status)
        
    except Exception as e:
        logger.error(f"Error en endpoint /status: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")


@app.post("/output", response_model=OutputWriteResponse)
async def write_output(request: OutputWriteRequest):
    """
    Escribir salida digital específica.
    
    Args:
        request: Solicitud con nombre de salida y valor
        
    Returns:
        Resultado de la operación de escritura
    """
    try:
        client = get_plc_client()
        success = client.write_output(request.output_name, request.value)
        
        if success:
            return OutputWriteResponse(
                success=True,
                message=f"Salida {request.output_name} escrita exitosamente",
                output_name=request.output_name,
                value=request.value
            )
        else:
            raise HTTPException(
                status_code=400,
                detail=f"No se pudo escribir la salida {request.output_name}"
            )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error en endpoint /output: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")


@app.get("/healthz", response_model=HealthResponse)
async def health_check():
    """
    Health check de la conexión PLC.
    
    Returns:
        Estado de salud de la conexión
    """
    try:
        client = get_plc_client()
        healthy = client.health_check()
        
        return HealthResponse(
            healthy=healthy,
            connection_quality=client.connection_quality.value,
            message="Conexión saludable" if healthy else "Conexión no saludable"
        )
        
    except Exception as e:
        logger.error(f"Error en endpoint /healthz: {e}")
        return HealthResponse(
            healthy=False,
            connection_quality="disconnected",
            message=f"Error en health check: {str(e)}"
        )


@app.get("/alarms", response_model=Dict[str, Any])
async def get_alarms():
    """
    Obtener lista de alarmas activas.
    
    Returns:
        Lista de alarmas con timestamps
    """
    try:
        client = get_plc_client()
        alarms = [
            {
                "id": alarm.id,
                "message": alarm.message,
                "timestamp": alarm.timestamp,
                "severity": alarm.severity
            }
            for alarm in client.alarms
        ]
        
        return {
            "alarms": alarms,
            "count": len(alarms),
            "max_alarms": client.max_alarms
        }
        
    except Exception as e:
        logger.error(f"Error en endpoint /alarms: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")


if __name__ == "__main__":
    # Configuración para desarrollo
    uvicorn.run(
        "snap7_backend:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    ) 