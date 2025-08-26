"""
Módulo plc_backend para comunicación con PLC Siemens S7-1200.

Este módulo proporciona:
- PLCClient: Cliente para comunicación con PLC
- snap7_backend: API REST con FastAPI
"""

from .plc_client import PLCClient, ConnectionQuality, Alarm
from .snap7_backend import app

__all__ = ["PLCClient", "ConnectionQuality", "Alarm", "app"]
__version__ = "1.0.0" 