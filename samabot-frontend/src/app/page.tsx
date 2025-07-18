'use client';

import dynamic from 'next/dynamic';

// Importar componentes simplificados para evitar errores
const SamitaPanel = dynamic(() => import("../components/ui/SimpleSamitaPanel"), {
  loading: () => <div className="bg-gray-800 rounded-xl p-6 h-[600px] flex items-center justify-center">
    <div className="text-gray-400">Cargando SAMITA AI...</div>
  </div>
});

const PLCStatus = dynamic(() => import("../components/ui/SimplePLCStatus"), {
  loading: () => <div className="bg-gray-800 rounded-xl p-6 flex items-center justify-center">
    <div className="text-gray-400">Cargando estado del PLC...</div>
  </div>
});

const Header = dynamic(() => import("../components/ui/Header"), {
  loading: () => <div className="bg-gradient-to-r from-blue-900 via-blue-800 to-indigo-900 text-white shadow-lg p-4">
    <div className="text-center">Cargando SAMABOT...</div>
  </div>
});

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-black text-white">
      {/* Header moderno */}
      <Header />
      
      {/* Contenido principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Panel de estado del PLC */}
          <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl shadow-2xl border border-gray-700">
            <div className="p-6">
              <div className="flex items-center space-x-3 mb-6">
                <div className="w-8 h-8 bg-gradient-to-br from-green-400 to-green-600 rounded-lg flex items-center justify-center">
                  <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <h2 className="text-2xl font-bold bg-gradient-to-r from-green-400 to-blue-400 bg-clip-text text-transparent">
                  Estado del PLC
                </h2>
              </div>
              <PLCStatus />
            </div>
          </div>
          
          {/* Panel de SAMITA AI */}
          <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-xl shadow-2xl border border-gray-700">
            <div className="p-6">
              <div className="flex items-center space-x-3 mb-6">
                <div className="w-8 h-8 bg-gradient-to-br from-blue-400 to-indigo-600 rounded-lg flex items-center justify-center">
                  <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                </div>
                <h2 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
                  SAMITA AI
                </h2>
              </div>
              <SamitaPanel />
            </div>
          </div>
        </div>
        
        {/* Footer informativo */}
        <div className="mt-12 text-center">
          <div className="bg-gradient-to-r from-gray-800 to-gray-900 rounded-xl p-6 border border-gray-700">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-sm">
              <div>
                <h3 className="text-blue-400 font-semibold mb-2">Sistema</h3>
                <p className="text-gray-300">SAMABOT Industrial v2.1.0</p>
                <p className="text-gray-400">Monitoreo Avanzado con IA</p>
              </div>
              <div>
                <h3 className="text-green-400 font-semibold mb-2">Hardware</h3>
                <p className="text-gray-300">Jetson Orin Nano</p>
                <p className="text-gray-400">Siemens S7-1200 PLC</p>
              </div>
              <div>
                <h3 className="text-purple-400 font-semibold mb-2">IA</h3>
                <p className="text-gray-300">SAMITA AI (Ollama)</p>
                <p className="text-gray-400">Modelo: samita-es</p>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
