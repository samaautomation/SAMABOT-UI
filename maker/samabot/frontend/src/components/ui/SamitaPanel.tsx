import * as React from "react";

export default function SamitaPanel() {
  return (
    <div className="flex flex-col w-full h-full">
      {/* Texto de estado arriba */}
      <div className="text-center mt-4 mb-2">
        <div className="text-2xl font-vt323 text-purple-400 mb-2">SAMITA AI</div>
        <div className="text-sm text-gray-300">Sistema de Monitoreo Industrial</div>
      </div>
      {/* GIF de Samita alineado completamente abajo */}
      <div className="flex-1 flex items-end justify-center w-full">
        <img
          src="/samita.gif"
          alt="Samita"
          className="w-auto max-h-full object-contain"
          style={{ boxShadow: 'none', border: 'none', background: 'none' }}
          onError={(e) => {
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
    </div>
  );
} 