#!/usr/bin/env python3
"""
Script para iniciar el servidor FastAPI del backend SAMABOT PLC.
"""

import uvicorn
from plc_backend.snap7_backend import app

if __name__ == "__main__":
    print("🚀 Iniciando servidor SAMABOT PLC Backend...")
    print("📍 URL: http://localhost:8000")
    print("📊 Health check: http://localhost:8000/healthz")
    print("📋 API docs: http://localhost:8000/docs")
    print("⏹️  Presiona Ctrl+C para detener")
    
    uvicorn.run(
        "plc_backend.snap7_backend:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    ) 