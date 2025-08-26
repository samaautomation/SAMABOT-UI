import { NextRequest, NextResponse } from 'next/server';

export async function GET(_request: NextRequest) {
  try {
    // Conectar con el backend SAMABOT
    const response = await fetch('http://localhost:3001/api/plc/real-data', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (response.ok) {
      const data = await response.json();
      return NextResponse.json(data);
    } else {
      // Si el backend no responde, devolver datos simulados
      return NextResponse.json({
        success: false,
        error: "Backend no disponible",
        simulation_mode: true,
        data: {
          success: true,
          timestamp: new Date().toISOString(),
          connection: {
            isConnected: false,
            host: "192.168.1.5",
            port: 102,
            responseTime: 0
          },
          digitalInputs: {},
          digitalOutputs: {},
          analogInputs: {},
          analogOutputs: {},
          systemData: {
            temperature: 0,
            pressure: 0,
            status: "Desconectado",
            alarms: ["Backend no disponible"],
            connectionQuality: "poor",
            responseTime: 0
          }
        }
      });
    }
  } catch (error) {
    console.error('Error en /api/plc/real-data:', error);
    return NextResponse.json({
      success: false,
      error: "Error de conexión al backend",
      simulation_mode: true,
      data: {
        success: true,
        timestamp: new Date().toISOString(),
        connection: {
          isConnected: false,
          host: "192.168.1.5",
          port: 102,
          responseTime: 0
        },
        digitalInputs: {},
        digitalOutputs: {},
        analogInputs: {},
        analogOutputs: {},
        systemData: {
          temperature: 0,
          pressure: 0,
          status: "Error de conexión",
          alarms: ["Error de comunicación"],
          connectionQuality: "poor",
          responseTime: 0
        }
      }
    });
  }
} 