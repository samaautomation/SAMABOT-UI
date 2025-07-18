import { NextRequest, NextResponse } from 'next/server';

export async function GET(_request: NextRequest) {
  try {
    // Conectar con el backend SAMABOT
    const response = await fetch('http://localhost:3001/api/plc/status', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (response.ok) {
      const data = await response.json();
      return NextResponse.json(data);
    } else {
      // Si el backend no responde, devolver estado de desconexión
      return NextResponse.json({
        status: "disconnected",
        simulation_mode: true,
        host: "192.168.1.5",
        error: "Backend no disponible"
      });
    }
  } catch (error) {
    console.error('Error en /api/plc/status:', error);
    return NextResponse.json({
      status: "disconnected",
      simulation_mode: true,
      host: "192.168.1.5",
      error: "Error de conexión al backend"
    });
  }
} 