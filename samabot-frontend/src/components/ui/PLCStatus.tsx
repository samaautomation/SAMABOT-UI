'use client';

import { useState, useEffect } from 'react';

interface PLCData {
  status: string;
  host: string;
  simulation_mode: boolean;
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
      } catch (_err) {
        setError('Error de conexión');
      } finally {
        setLoading(false);
      }
    };

    fetchPLCStatus();
    const interval = setInterval(fetchPLCStatus, 5000);
    return () => clearInterval(interval);
  }, []);

  const getStatusColor = () => {
    if (loading) return 'from-yellow-500 to-orange-500';
    if (error) return 'from-red-500 to-pink-500';
    if (plcData?.status === 'connected') return 'from-green-500 to-emerald-500';
    return 'from-red-500 to-pink-500';
  };

  const getStatusText = () => {
    if (loading) return 'Conectando...';
    if (error) return 'Error';
    if (plcData?.status === 'connected') return 'Conectado';
    return 'Desconectado';
  };

  const getStatusIcon = () => {
    if (loading) return (
      <div className="w-4 h-4 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-full animate-pulse"></div>
    );
    if (error) return (
      <div className="w-4 h-4 bg-gradient-to-r from-red-500 to-pink-500 rounded-full"></div>
    );
    if (plcData?.status === 'connected') return (
      <div className="relative">
        <div className="w-4 h-4 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full animate-pulse"></div>
        <div className="absolute inset-0 w-4 h-4 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full animate-ping opacity-75"></div>
      </div>
    );
    return (
      <div className="w-4 h-4 bg-gradient-to-r from-red-500 to-pink-500 rounded-full"></div>
    );
  };

  return (
    <div className="bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 rounded-xl p-6 shadow-2xl border border-gray-700">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-3">
          {getStatusIcon()}
          <div>
            <h3 className="text-xl font-bold text-white">PLC Siemens S7-1200</h3>
            <p className="text-sm text-gray-400">Estado de Conexión</p>
          </div>
        </div>
        <div className="text-right">
          <div className={`text-sm font-medium bg-gradient-to-r ${getStatusColor()} bg-clip-text text-transparent`}>
            {getStatusText()}
          </div>
          <div className="text-xs text-gray-400">Actualizado en tiempo real</div>
        </div>
      </div>

      {/* Status Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        {/* Connection Status */}
        <div className="bg-gradient-to-br from-gray-800 to-gray-700 rounded-lg p-4 border border-gray-600">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-300">Estado de Conexión</span>
            <div className={`w-2 h-2 rounded-full ${
              plcData?.status === 'connected' ? 'bg-green-500' : 'bg-red-500'
            }`}></div>
          </div>
          <div className={`text-lg font-bold ${
            plcData?.status === 'connected' ? 'text-green-400' : 'text-red-400'
          }`}>
            {plcData?.status === 'connected' ? 'ONLINE' : 'OFFLINE'}
          </div>
        </div>

        {/* Simulation Mode */}
        <div className="bg-gradient-to-br from-gray-800 to-gray-700 rounded-lg p-4 border border-gray-600">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-300">Modo de Operación</span>
            <div className={`w-2 h-2 rounded-full ${
              plcData?.simulation_mode ? 'bg-yellow-500' : 'bg-green-500'
            }`}></div>
          </div>
          <div className={`text-lg font-bold ${
            plcData?.simulation_mode ? 'text-yellow-400' : 'text-green-400'
          }`}>
            {plcData?.simulation_mode ? 'SIMULACIÓN' : 'REAL'}
          </div>
        </div>
      </div>

      {/* Connection Details */}
      <div className="bg-gradient-to-br from-gray-800 to-gray-700 rounded-lg p-4 border border-gray-600">
        <h4 className="text-sm font-medium text-gray-300 mb-3">Detalles de Conexión</h4>
        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <span className="text-xs text-gray-400">Dirección IP:</span>
            <span className="text-sm font-mono text-white">{plcData?.host || '192.168.1.5'}</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-xs text-gray-400">Puerto:</span>
            <span className="text-sm font-mono text-white">102</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-xs text-gray-400">Rack/Slot:</span>
            <span className="text-sm font-mono text-white">0/1</span>
          </div>
        </div>
      </div>

      {/* Error Display */}
      {error && (
        <div className="mt-4 bg-gradient-to-r from-red-900 to-red-800 border border-red-600 rounded-lg p-4">
          <div className="flex items-center space-x-2">
            <svg className="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span className="text-red-300 font-medium">Error de Conexión</span>
          </div>
          <p className="text-red-200 text-sm mt-2">{error}</p>
        </div>
      )}

      {/* Loading State */}
      {loading && (
        <div className="mt-4 bg-gradient-to-r from-yellow-900 to-orange-800 border border-yellow-600 rounded-lg p-4">
          <div className="flex items-center space-x-2">
            <div className="w-5 h-5 border-2 border-yellow-400 border-t-transparent rounded-full animate-spin"></div>
            <span className="text-yellow-300 font-medium">Conectando al PLC...</span>
          </div>
          <p className="text-yellow-200 text-sm mt-2">Estableciendo comunicación con Siemens S7-1200</p>
        </div>
      )}

      {/* Status Bar */}
      <div className="mt-6 pt-4 border-t border-gray-700">
        <div className="flex items-center justify-between text-xs text-gray-400">
          <div className="flex items-center space-x-2">
            <div className="w-2 h-2 bg-blue-500 rounded-full animate-pulse"></div>
            <span>PLC Backend</span>
          </div>
          <div className="flex items-center space-x-4">
            <span>Protocolo: S7</span>
            <span>v1.0</span>
          </div>
        </div>
      </div>
    </div>
  );
} 