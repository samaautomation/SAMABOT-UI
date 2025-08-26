import * as React from "react";

export default function SamitaPanel() {
  return (
    <div className="flex flex-col w-full h-full p-1 sm:p-2 md:p-4 overflow-hidden">
      {/* GIF de Samita grande, alineado abajo */}
      <div className="flex-1 flex items-end justify-center w-full overflow-hidden">
        <img
          src="/samita.gif"
          alt="Samita"
          className="object-contain w-auto"
          style={{
            maxHeight: '140%',
            maxWidth: '140%',
            boxShadow: 'none',
            border: 'none',
            background: 'none',
            display: 'block',
            margin: '0 auto'
          }}
          onError={(e) => {
            const target = e.currentTarget as HTMLImageElement;
            target.style.display = 'none';
            const fallback = target.nextElementSibling as HTMLElement;
            if (fallback) fallback.style.display = 'flex';
          }}
        />
        {/* Fallback emoji responsivo */}
        <div className="w-full h-full flex items-center justify-center text-2xl sm:text-4xl md:text-5xl hidden">
          🤖
        </div>
      </div>
      {/* Texto de estado ABAJO */}
      <div className="text-center mt-2 sm:mt-3 md:mt-4">
        <div className="text-base sm:text-lg md:text-xl lg:text-2xl font-vt323 text-purple-400">
          SAMITA AI
        </div>
        <div className="text-xs sm:text-sm md:text-base lg:text-lg text-gray-300 px-1 sm:px-2">
          Sistema de Monitoreo Industrial
        </div>
      </div>
    </div>
  );
} 