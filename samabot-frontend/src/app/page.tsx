import SamitaPanel from "../components/ui/SamitaPanel";
import PLCStatus from "../components/ui/PLCStatus";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-black text-white p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-center mb-8">
          SAMABOT INDUSTRIAL
        </h1>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* PLC Status */}
          <div className="bg-gray-800 rounded-lg p-6">
            <h2 className="text-xl font-semibold mb-4">Estado del PLC</h2>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span>Estado:</span>
                <span className="text-green-400">Conectado</span>
              </div>
              <div className="flex justify-between">
                <span>IP:</span>
                <span>192.168.1.5</span>
              </div>
            </div>
          </div>
          
          {/* SAMITA Chat */}
          <div className="bg-gray-800 rounded-lg p-6">
            <h2 className="text-xl font-semibold mb-4">SAMITA AI</h2>
            <div className="space-y-3">
              <div className="bg-gray-700 p-3 rounded">
                <p className="text-sm">¡Hola! Soy SAMITA, tu asistente de IA industrial.</p>
              </div>
              <div className="flex space-x-2">
                <input
                  type="text"
                  placeholder="Escribe tu mensaje..."
                  className="flex-1 bg-gray-700 text-white px-3 py-2 rounded border border-gray-600"
                />
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  Enviar
                </button>
              </div>
            </div>
          </div>
        </div>
        
        <div className="mt-8 text-center text-gray-400">
          <p>Sistema de Monitoreo Industrial con IA</p>
          <p className="text-sm mt-2">Jetson Orin Nano • Siemens S7-1200</p>
        </div>
      </div>
    </div>
  );
}
