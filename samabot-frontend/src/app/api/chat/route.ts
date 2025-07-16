import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { message } = body;

    // Intentar conectar con el backend SAMITA
    const response = await fetch('http://localhost:3001/api/samita/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message }),
    });

    if (response.ok) {
      const data = await response.json();
      return NextResponse.json(data);
    } else {
      // Si el backend no responde, devolver mensaje de fallback
      return NextResponse.json({
        response: "Samita está offline. Por favor, verifica que el backend esté ejecutándose.",
        timestamp: new Date().toISOString(),
        status: "offline"
      });
    }
  } catch (error) {
    console.error('Error en /api/chat:', error);
    return NextResponse.json({
      response: "Error en la comunicación con SAMITA. Verifica la conexión al backend.",
      timestamp: new Date().toISOString(),
      status: "error"
    });
  }
} 