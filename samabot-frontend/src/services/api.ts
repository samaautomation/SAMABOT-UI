// Servicio de API para conectar con el backend del Jetson Nano

const API_BASE_URL = process.env.NEXT_PUBLIC_PLC_API_URL || 'http://192.168.1.148:3001';

export interface PLCStatus {
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

export interface OutputWriteRequest {
  output_name: string;
  value: boolean;
}

export interface OutputWriteResponse {
  success: boolean;
  message: string;
  output_name: string;
  value: boolean;
}

export interface HealthResponse {
  healthy: boolean;
  connection_quality: string;
  message: string;
}

class APIService {
  private baseURL: string;

  constructor(baseURL: string = API_BASE_URL) {
    this.baseURL = baseURL;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    
    try {
      const response = await fetch(url, {
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
        ...options,
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error(`API Error (${endpoint}):`, error);
      throw error;
    }
  }

  // Obtener estado completo del PLC
  async getStatus(): Promise<PLCStatus> {
    return this.request<PLCStatus>('/api/plc/status');
  }

  // Escribir salida digital
  async writeOutput(outputName: string, value: boolean): Promise<OutputWriteResponse> {
    return this.request<OutputWriteResponse>('/api/plc/write-output', {
      method: 'POST',
      body: JSON.stringify({
        output_name: outputName,
        value: value,
      }),
    });
  }

  // Health check
  async getHealth(): Promise<HealthResponse> {
    return this.request<HealthResponse>('/api/plc/status');
  }

  // Conectar al PLC
  async connect(): Promise<{ success: boolean; message: string }> {
    return this.request<{ success: boolean; message: string }>('/api/plc/connect', {
      method: 'POST',
    });
  }

  // Desconectar del PLC
  async disconnect(): Promise<{ success: boolean; message: string }> {
    return this.request<{ success: boolean; message: string }>('/api/plc/disconnect', {
      method: 'POST',
    });
  }

  // Obtener información básica
  async getInfo(): Promise<{ version: string; status: string }> {
    return this.request<{ version: string; status: string }>('/api/plc/status');
  }
}

// Instancia global del servicio API
export const apiService = new APIService();

// Hook personalizado para usar el API
export const useAPI = () => {
  return {
    getStatus: apiService.getStatus.bind(apiService),
    writeOutput: apiService.writeOutput.bind(apiService),
    getHealth: apiService.getHealth.bind(apiService),
    connect: apiService.connect.bind(apiService),
    disconnect: apiService.disconnect.bind(apiService),
    getInfo: apiService.getInfo.bind(apiService),
  };
}; 