import SamitaPanel from "../components/ui/SamitaPanel";
import PLCStatus from "../components/ui/PLCStatus";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-black text-white p-8">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-4xl font-bold text-center mb-8">
          SAMABOT INDUSTRIAL
        </h1>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* PLC Status Panel */}
          <div className="bg-gray-800 rounded-lg p-6">
            <PLCStatus />
          </div>
          
          {/* SAMITA Chat Panel */}
          <div className="bg-gray-800 rounded-lg p-6">
            <SamitaPanel />
          </div>
        </div>
        
        <div className="mt-8 text-center text-gray-400">
          <p>Sistema de Monitoreo Industrial con IA</p>
          <p className="text-sm mt-2">Jetson Orin Nano • Siemens S7-1200 • ING. SERGIO M</p>
        </div>
      </div>
    </div>
  );
} 