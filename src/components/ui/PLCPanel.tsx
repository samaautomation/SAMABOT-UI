import React, { useState, useEffect } from "react";

interface PLCStatus {
  connectionQuality: string;
  ip: string;
  rack: number;
  slot: number;
  reconnectAttempts: number;
  inputs: Record<string, boolean>;
  outputs: Record<string, boolean>;
  analogInputs: Record<string, number>;
  alarms: Array<{
    id: string;
    message: string;
    timestamp: number;
    severity: string;
  }>;
  lastUpdate: number;
}

interface HealthStatus {
  healthy: boolean;
  connection_quality: string;
  message: string;
}

const BACKEND_URL = 'http://192.168.1.7:8000';

export default function PLCPanel() {
  const [status, setStatus] = useState<PLCStatus | null>(null);
  const [health, setHealth] = useState<HealthStatus | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdate, setLastUpdate] = useState<Date | null>(null);

  const fetchStatus = async () => {
    try {
      setError(null);
      const response = await fetch(`${BACKEND_URL}/status`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      setStatus(data);
      setLastUpdate(new Date());
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
      console.error('Error fetching status:', err);
    }
  };

  const fetchHealth = async () => {
    try {
      const response = await fetch(`${BACKEND_URL}/healthz`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      setHealth(data);
    } catch (err) {
      console.error('Error fetching health:', err);
    }
  };

  const writeOutput = async (outputName: string, value: boolean) => {
    try {
      setLoading(true);
      const response = await fetch(`${BACKEND_URL}/output`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          output_name: outputName,
          value: value
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Error escribiendo salida');
      }

      const data = await response.json();
      console.log('Salida escrita:', data);
      
      // Actualizar estado después de escribir
      await fetchStatus();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
      console.error('Error writing output:', err);
    } finally {
      setLoading(false);
    }
  };

  const connectPLC = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${BACKEND_URL}/connect`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log('PLC conectado:', data);
      
      // Actualizar estado después de conectar
      await fetchStatus();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error desconocido');
      console.error('Error connecting PLC:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // Cargar estado inicial
    fetchStatus();
    fetchHealth();

    // Actualizar cada 5 segundos
    const interval = setInterval(() => {
      fetchStatus();
      fetchHealth();
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  const getConnectionColor = (quality: string) => {
    switch (quality) {
      case 'connected':
        return 'text-green-400';
      case 'disconnected':
        return 'text-red-400';
      case 'reconnecting':
        return 'text-yellow-400';
      default:
        return 'text-gray-400';
    }
  };

  const getConnectionIcon = (quality: string) => {
    switch (quality) {
      case 'connected':
        return '🟢';
      case 'disconnected':
        return '🔴';
      case 'reconnecting':
        return '🟡';
      default:
        return '⚪';
    }
  };

  return (
    <div className="flex flex-col w-full h-full p-2 sm:p-3 md:p-4 overflow-hidden bg-gray-900 text-white">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div>
          <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-purple-400">
            SAMABOT PLC Control
          </h1>
          <p className="text-xs sm:text-sm text-gray-400">
            Sistema de Monitoreo Industrial
          </p>
        </div>
        
        {/* Estado de conexión */}
        <div className="text-right">
          <div className={`text-sm font-mono ${getConnectionColor(status?.connectionQuality || 'disconnected')}`}>
            {getConnectionIcon(status?.connectionQuality || 'disconnected')} {status?.connectionQuality || 'disconnected'}
          </div>
          <div className="text-xs text-gray-500">
            {status?.ip || 'N/A'}
          </div>
        </div>
      </div>

      {/* Botones de control */}
      <div className="flex gap-2 mb-4">
        <button
          onClick={connectPLC}
          disabled={loading}
          className="px-3 py-1 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white text-sm rounded"
        >
          {loading ? 'Conectando...' : 'Conectar PLC'}
        </button>
        
        <button
          onClick={fetchStatus}
          disabled={loading}
          className="px-3 py-1 bg-green-600 hover:bg-green-700 disabled:bg-gray-600 text-white text-sm rounded"
        >
          {loading ? 'Actualizando...' : 'Actualizar'}
        </button>
      </div>

      {/* Error display */}
      {error && (
        <div className="mb-4 p-2 bg-red-900 border border-red-600 rounded text-sm">
          ❌ Error: {error}
        </div>
      )}

      {/* Health status */}
      {health && (
        <div className="mb-4 p-2 bg-gray-800 rounded">
          <div className="text-sm">
            <span className="font-semibold">Health Check:</span>
            <span className={`ml-2 ${health.healthy ? 'text-green-400' : 'text-red-400'}`}>
              {health.healthy ? '✅ Saludable' : '❌ No saludable'}
            </span>
          </div>
          <div className="text-xs text-gray-400 mt-1">
            {health.message}
          </div>
        </div>
      )}

      {/* I/O Status */}
      {status && (
        <div className="flex-1 overflow-auto">
          {/* Digital Inputs */}
          <div className="mb-4">
            <h3 className="text-sm font-semibold text-blue-400 mb-2">Entradas Digitales</h3>
            <div className="grid grid-cols-7 gap-1">
              {Array.from({ length: 14 }, (_, i) => `I${i}`).map((input) => (
                <div key={input} className="text-center p-1 bg-gray-800 rounded text-xs">
                  <div className="font-mono">{input}</div>
                  <div className={status.inputs[input] ? 'text-green-400' : 'text-red-400'}>
                    {status.inputs[input] ? 'ON' : 'OFF'}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Digital Outputs */}
          <div className="mb-4">
            <h3 className="text-sm font-semibold text-green-400 mb-2">Salidas Digitales</h3>
            <div className="grid grid-cols-5 gap-1">
              {Array.from({ length: 10 }, (_, i) => `Q${i}`).map((output) => (
                <div key={output} className="text-center p-1 bg-gray-800 rounded text-xs">
                  <div className="font-mono">{output}</div>
                  <div className={status.outputs[output] ? 'text-green-400' : 'text-red-400'}>
                    {status.outputs[output] ? 'ON' : 'OFF'}
                  </div>
                  <button
                    onClick={() => writeOutput(output, !status.outputs[output])}
                    disabled={loading}
                    className="mt-1 px-2 py-1 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 text-white text-xs rounded"
                  >
                    {status.outputs[output] ? 'OFF' : 'ON'}
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Analog Inputs */}
          {Object.keys(status.analogInputs).length > 0 && (
            <div className="mb-4">
              <h3 className="text-sm font-semibold text-yellow-400 mb-2">Entradas Analógicas</h3>
              <div className="grid grid-cols-2 gap-2">
                {Object.entries(status.analogInputs).map(([input, value]) => (
                  <div key={input} className="p-2 bg-gray-800 rounded text-xs">
                    <div className="font-mono">{input}</div>
                    <div className="text-yellow-400">{(value as number).toFixed(2)}</div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Alarms */}
          {status.alarms.length > 0 && (
            <div className="mb-4">
              <h3 className="text-sm font-semibold text-red-400 mb-2">Alarmas ({status.alarms.length})</h3>
              <div className="space-y-1">
                {status.alarms.slice(-5).map((alarm, index) => (
                  <div key={index} className="p-2 bg-red-900 border border-red-600 rounded text-xs">
                    <div className="font-semibold">{alarm.id}</div>
                    <div className="text-red-300">{alarm.message}</div>
                    <div className="text-gray-400 text-xs">
                      {new Date(alarm.timestamp * 1000).toLocaleTimeString()}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Footer */}
      <div className="text-xs text-gray-500 text-center mt-2">
        {lastUpdate && `Última actualización: ${lastUpdate.toLocaleTimeString()}`}
      </div>
    </div>
  );
} 