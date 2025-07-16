import * as React from "react";
import SamitaPanel from "../components/ui/SamitaPanel";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-black text-white overflow-hidden flex flex-col">
      {/* Header con estilo industrial */}
      <header className="bg-black/50 backdrop-blur-sm border-b border-gray-700 p-2 sm:p-4">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center space-x-2 sm:space-x-4">
            <div className="w-2 h-2 sm:w-3 sm:h-3 bg-red-500 rounded-full animate-pulse"></div>
            <h1 
              className="text-base sm:text-xl md:text-2xl font-bold text-gray-100"
              style={{
                marginLeft: '-0.5rem',
                fontSize: '1.25rem',
                transform: 'scaleY(1.1) scaleX(0.9)',
                letterSpacing: '0.05em',
                fontFamily: 'monospace'
              }}
            >
              SAMABOT INDUSTRIAL
            </h1>
          </div>
          <div className="hidden sm:flex items-center space-x-1 sm:space-x-2 text-xs sm:text-sm text-gray-400">
            <span className="px-1 py-0.5 sm:px-2 sm:py-1 bg-green-900/30 border border-green-500/50 rounded animate-pulse">
              ONLINE
            </span>
            <span className="px-1 py-0.5 sm:px-2 sm:py-1 bg-blue-900/30 border border-blue-500/50 rounded animate-pulse-slow">
              PLC CONNECTED
            </span>
          </div>
        </div>
      </header>

      {/* Contenido principal */}
      <main className="flex-1 flex items-center justify-center p-1 sm:p-4 md:p-8 overflow-hidden">
        <div className="w-full max-w-md sm:max-w-2xl md:max-w-3xl lg:max-w-4xl h-[60vh] sm:h-[70vh] md:h-[80vh] 
  bg-gray-800/50 backdrop-blur-sm border border-gray-600 rounded-lg shadow-2xl overflow-hidden
  ring-2 ring-purple-500/30 hover:ring-purple-400/60 transition-all duration-300"
>
  <SamitaPanel />
</div>
      </main>

      {/* Footer con información del sistema */}
      <footer className="bg-black/50 backdrop-blur-sm border-t border-gray-700 p-2 sm:p-4">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between text-xs sm:text-sm text-gray-400">
          <div className="flex items-center space-x-2 sm:space-x-4 mb-1 sm:mb-0">
            <span>JETSON NANO</span>
            <span>•</span>
            <span>UBUNTU 22.04</span>
            <span>•</span>
            <span>NODE.JS</span>
          </div>
          <div className="flex items-center space-x-2 sm:space-x-4">
            <span className="px-1 py-0.5 sm:px-2 sm:py-1 bg-gray-700/50 border border-gray-600 rounded">
              v2.1.0
            </span>
            <span className="px-1 py-0.5 sm:px-2 sm:py-1 bg-purple-900/30 border border-purple-500/50 rounded">
              SAMITA AI
            </span>
          </div>
        </div>
      </footer>
    </div>
  );
} 