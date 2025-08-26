import { NextRequest, NextResponse } from 'next/server';

const BACKEND_URL = process.env.NEXT_PUBLIC_API_URL || 'http://192.168.1.7:3001';

export async function GET() {
  try {
    console.log('🔌 Leyendo datos del backend Flask...');
    
    const response = await fetch(`${BACKEND_URL}/api/plc/real-data`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    
    return NextResponse.json(data);

  } catch (error) {
    console.error('❌ Error leyendo datos del backend:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'Error conectando al backend',
        details: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const { action, output_name, value } = await request.json();

    switch (action) {
      case 'writeDigital':
        if (!output_name || typeof value !== 'boolean') {
          return NextResponse.json(
            { error: 'output_name y valor booleano requeridos' },
            { status: 400 }
          );
        }
        
        const writeResponse = await fetch(`${BACKEND_URL}/api/plc/write-output`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ output_name, value }),
        });

        const writeData = await writeResponse.json();
        return NextResponse.json(writeData);

      case 'connect':
        const connectResponse = await fetch(`${BACKEND_URL}/api/plc/connect`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        });

        const connectData = await connectResponse.json();
        return NextResponse.json(connectData);

      default:
        return NextResponse.json(
          { error: 'Acción no válida' },
          { status: 400 }
        );
    }

  } catch (error) {
    console.error('Error en operación PLC:', error);
    return NextResponse.json(
      { 
        error: 'Error en operación PLC',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
} 