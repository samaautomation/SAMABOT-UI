'use client';

import React, { useState, useEffect } from 'react';

interface PLCData {
  connected: boolean;
  status: string;
  data?: any;
  error?: string;
}

export default function PLCPanel() {
  const [plcData, setPlcData] = useState<PLCData>({
    connected: false,
    status: 'Desconectado'
  });
  const [loading, setLoading] = useState(false);

  const fetchPLCData = async () => {
    setLoading(true);
    try {
      console.log('🔄 Haciendo fetch a backend...');
      const response = await fetch('http://localhost:8000/plc/status');
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      console.log('✅ Datos recibidos:', data);
      
      setPlcData({
        connected: data.connected || false,
        status: data.status || 'Desconocido',
        data: data
      });
    } catch (error) {
      console.error('❌ Error al conectar con backend:', error);
      setPlcData({
        connected: false,
        status: 'Error de conexión',
        error: error instanceof Error ? error.message : 'Error desconocido'
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    console.log('🚀 PLCPanel montado, iniciando fetch...');
    fetchPLCData();
    
    // Actualizar cada 5 segundos
    const interval = setInterval(fetchPLCData, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-2xl font-bold mb-4 text-gray-800">
        Estado del PLC
      </h2>
      
      <div className="space-y-4">
        <div className="flex items-center space-x-2">
          <div className={`w-3 h-3 rounded-full ${
            plcData.connected ? 'bg-green-500' : 'bg-red-500'
          }`}></div>
          <span className="font-semibold">
            Estado: {plcData.status}
          </span>
        </div>
        
        {loading && (
          <div className="text-blue-600">
             Conectando con PLC...
          </div>
        )}
        
        {plcData.error && (
          <div className="text-red-600 bg-red-100 p-3 rounded">
            ❌ Error: {plcData.error}
          </div>
        )}
        
        {plcData.data && (
          <div className="bg-gray-100 p-4 rounded">
            <h3 className="font-semibold mb-2">Datos del PLC:</h3>
            <pre className="text-sm overflow-auto">
              {JSON.stringify(plcData.data, null, 2)}
            </pre>
          </div>
        )}
        
        <button
          onClick={fetchPLCData}
          disabled={loading}
          className="bg-blue-500 hover:bg-blue-700 disabled:bg-gray-400 text-white font-bold py-2 px-4 rounded"
        >
          {loading ? 'Conectando...' : 'Actualizar Datos'}
        </button>
      </div>
    </div>
  );
} 