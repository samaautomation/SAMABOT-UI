'use client';

import { useState, useEffect } from 'react';

interface PLCData {
  connectionQuality: string;
  ip: string;
  rack: number;
  slot: number;
  inputs: Record<string, boolean>;
  outputs: Record<string, boolean>;
  lastUpdate: number;
}

export default function PLCStatus() {
  const [plcData, setPlcData] = useState<PLCData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchPLCStatus = async () => {
      try {
        const response = await fetch('/api/plc/status');
        if (response.ok) {
          const data = await response.json();
          setPlcData(data);
          setError(null);
        } else {
          setError('Error al conectar con el PLC');
        }
      } catch (err) {
        setError('Error de conexión');
      } finally {
        setLoading(false);
      }
    };

    fetchPLCStatus();
    const interval = setInterval(fetchPLCStatus, 5000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="bg-gray-800 rounded-lg p-4">
        <div className="flex items-center space-x-2 mb-4">
          <div className="w-3 h-3 bg-yellow-500 rounded-full animate-pulse"></div>
          <h3 className="text-lg font-semibold text-white">PLC Status</h3>
        </div>
        <div className="text-gray-300">Conectando...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-gray-800 rounded-lg p-4">
        <div className="flex items-center space-x-2 mb-4">
          <div className="w-3 h-3 bg-red-500 rounded-full"></div>
          <h3 className="text-lg font-semibold text-white">PLC Status</h3>
        </div>
        <div className="text-red-400">{error}</div>
      </div>
    );
  }

  return (
    <div className="bg-gray-800 rounded-lg p-4">
      <div className="flex items-center space-x-2 mb-4">
        <div className={`w-3 h-3 rounded-full ${
          plcData?.connectionQuality === 'connected' ? 'bg-green-500' : 'bg-red-500'
        }`}></div>
        <h3 className="text-lg font-semibold text-white">PLC Status</h3>
      </div>
      
      <div className="space-y-2 text-sm">
        <div className="flex justify-between">
          <span className="text-gray-300">Estado:</span>
          <span className={`${
            plcData?.connectionQuality === 'connected' ? 'text-green-400' : 'text-red-400'
          }`}>
            {plcData?.connectionQuality === 'connected' ? 'Conectado' : 'Desconectado'}
          </span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-300">IP:</span>
          <span className="text-white">{plcData?.ip || 'N/A'}</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-300">Rack/Slot:</span>
          <span className="text-white">{plcData?.rack || 0}/{plcData?.slot || 1}</span>
        </div>
      </div>
    </div>
  );
} 