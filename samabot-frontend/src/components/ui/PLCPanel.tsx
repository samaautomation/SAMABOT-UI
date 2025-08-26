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
      console.log('🔄 Conectando a backend del Jetson...');
      // CAMBIO CRÍTICO: Conectar al Jetson en lugar de localhost
      const response = await fetch('http://192.168.1.7:8000/status');
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      console.log('✅ Datos reales del PLC recibidos:', data);
      
      setPlcData({
        connected: data.connectionQuality === 'excellent' || data.connectionQuality === 'good',
        status: `Conectado - ${data.connectionQuality}`,
        data: data
      });
    } catch (error) {
      console.error('❌ Error al conectar con backend del Jetson:', error);
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
    console.log('🚀 PLCPanel montado, iniciando conexión con PLC real...');
    fetchPLCData();
    
    // Actualizar cada 5 segundos
    const interval = setInterval(fetchPLCData, 5000);
    return () => clearInterval(interval);
  }, []);

  const renderInputs = () => {
    if (!plcData.data?.inputs) return null;
    
    return (
      <div className="bg-green-50 p-4 rounded-lg border border-green-200">
        <h3 className="font-semibold text-green-800 mb-3">📥 Entradas Digitales</h3>
        <div className="grid grid-cols-2 gap-3">
          {Object.entries(plcData.data.inputs).map(([input, value]) => (
            <div key={input} className="flex items-center justify-between p-2 bg-white rounded border">
              <span className="font-mono text-sm">{input}</span>
              <div className={`w-4 h-4 rounded-full ${value ? 'bg-green-500' : 'bg-gray-300'}`}></div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  const renderOutputs = () => {
    if (!plcData.data?.outputs) return null;
    
    return (
      <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
        <h3 className="font-semibold text-blue-800 mb-3">📤 Salidas Digitales</h3>
        <div className="grid grid-cols-2 gap-3">
          {Object.entries(plcData.data.outputs).map(([output, value]) => (
            <div key={output} className="flex items-center justify-between p-2 bg-white rounded border">
              <span className="font-mono text-sm">{output}</span>
              <div className={`w-4 h-4 rounded-full ${value ? 'bg-blue-500' : 'bg-gray-300'}`}></div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  const renderAnalogInputs = () => {
    if (!plcData.data?.analogInputs) return null;
    
    return (
      <div className="bg-purple-50 p-4 rounded-lg border border-purple-200">
        <h3 className="font-semibold text-purple-800 mb-3">📊 Entradas Analógicas</h3>
        <div className="grid grid-cols-1 gap-3">
          {Object.entries(plcData.data.analogInputs).map(([input, value]) => (
            <div key={input} className="flex items-center justify-between p-2 bg-white rounded border">
              <span className="font-mono text-sm">{input}</span>
              <span className="font-semibold text-purple-600">{value}</span>
            </div>
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="bg-gradient-to-br from-gray-50 to-white rounded-xl shadow-lg p-6 border border-gray-200">
      <div className="flex items-center space-x-3 mb-6">
        <div className={`w-4 h-4 rounded-full ${plcData.connected ? 'bg-green-500' : 'bg-red-500'}`}></div>
        <h2 className="text-2xl font-bold text-gray-800">
          PLC Siemens S7-1200
        </h2>
      </div>
      
      <div className="space-y-4">
        {/* Estado de conexión */}
        <div className="bg-gray-50 p-4 rounded-lg">
          <div className="flex items-center justify-between">
            <span className="font-semibold text-gray-700">
              Estado: {plcData.status}
            </span>
            {plcData.data?.ip && (
              <span className="text-sm text-gray-500">IP: {plcData.data.ip}</span>
            )}
          </div>
        </div>
        
        {loading && (
          <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
            <div className="flex items-center space-x-2">
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
              <span className="text-blue-700">Conectando con PLC real...</span>
            </div>
          </div>
        )}
        
        {plcData.error && (
          <div className="bg-red-50 p-4 rounded-lg border border-red-200">
            <div className="flex items-center space-x-2">
              <span className="text-red-600">❌ Error: {plcData.error}</span>
            </div>
          </div>
        )}
        
        {/* Datos del PLC */}
        {plcData.data && (
          <div className="space-y-4">
            {renderInputs()}
            {renderOutputs()}
            {renderAnalogInputs()}
            
            {/* Información adicional */}
            <div className="bg-gray-50 p-4 rounded-lg">
              <h3 className="font-semibold text-gray-700 mb-2">📋 Información del Sistema</h3>
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span className="text-gray-500">Calidad de conexión:</span>
                  <span className="ml-2 font-semibold text-green-600">{plcData.data.connectionQuality}</span>
                </div>
                <div>
                  <span className="text-gray-500">Rack/Slot:</span>
                  <span className="ml-2 font-semibold">{plcData.data.rack}/{plcData.data.slot}</span>
                </div>
                <div>
                  <span className="text-gray-500">Última actualización:</span>
                  <span className="ml-2 font-semibold">{new Date(plcData.data.lastUpdate).toLocaleTimeString()}</span>
                </div>
                <div>
                  <span className="text-gray-500">Reconexiones:</span>
                  <span className="ml-2 font-semibold">{plcData.data.reconnectAttempts}</span>
                </div>
              </div>
            </div>
          </div>
        )}
        
        <button
          onClick={fetchPLCData}
          disabled={loading}
          className="w-full bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 disabled:from-gray-400 disabled:to-gray-500 text-white font-bold py-3 px-6 rounded-lg transition-all duration-200 shadow-lg"
        >
          {loading ? '🔄 Conectando...' : '🔄 Actualizar Datos PLC'}
        </button>
      </div>
    </div>
  );
} 