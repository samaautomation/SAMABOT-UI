import * as React from "react";

export default function SamitaPanel() {
  return (
    <div className="flex flex-col items-center justify-center w-full h-full p-4">
      {/* GIF de Samita sin animaciones, ocupa el 70% del alto */}
      <div className="flex justify-center items-center w-full" style={{height: '70%'}}>
        <img
          src="/samita.gif"
          alt="Samita"
          className="w-auto h-full max-h-full rounded-lg object-contain"
          style={{ boxShadow: 'none', border: 'none', background: 'none' }}
          onError={(e) => {
            // Fallback si no hay GIF
            const target = e.currentTarget as HTMLImageElement;
            target.style.display = 'none';
            const fallback = target.nextElementSibling as HTMLElement;
            if (fallback) fallback.style.display = 'flex';
          }}
        />
        {/* Fallback emoji si no hay GIF */}
        <div className="w-full h-full flex items-center justify-center text-6xl hidden">
          🤖
        </div>
      </div>
      {/* Texto de estado */}
      <div className="text-center mt-4">
        <div className="text-2xl font-vt323 text-purple-400 mb-2">SAMITA AI</div>
        <div className="text-sm text-gray-300">Sistema de Monitoreo Industrial</div>
      </div>
    </div>
  );
} 