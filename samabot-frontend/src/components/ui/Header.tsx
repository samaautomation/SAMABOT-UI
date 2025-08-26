'use client';

import { useState, useEffect } from 'react';

export default function Header() {
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('es-ES', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('es-ES', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  return (
    <header className="bg-gradient-to-r from-blue-900 via-blue-800 to-indigo-900 text-white shadow-lg">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center py-4">
          {/* Logo y título */}
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-400 to-indigo-500 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" />
                </svg>
              </div>
              <div>
                <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-200 to-indigo-200 bg-clip-text text-transparent">
                  SAMABOT Industrial
                </h1>
                <p className="text-blue-200 text-sm">Sistema de Monitoreo Avanzado</p>
              </div>
            </div>
          </div>

          {/* Estado del sistema */}
          <div className="flex items-center space-x-6">
            <div className="text-center">
              <div className="text-xs text-blue-200 uppercase tracking-wide">Estado</div>
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                <span className="text-sm font-medium">Operativo</span>
              </div>
            </div>

            {/* Tiempo */}
            <div className="text-center">
              <div className="text-xs text-blue-200 uppercase tracking-wide">Tiempo</div>
              <div className="text-sm font-mono font-medium">
                {formatTime(currentTime)}
              </div>
            </div>

            {/* Fecha */}
            <div className="text-center hidden md:block">
              <div className="text-xs text-blue-200 uppercase tracking-wide">Fecha</div>
              <div className="text-sm font-medium capitalize">
                {formatDate(currentTime)}
              </div>
            </div>

            {/* Versión */}
            <div className="text-center">
              <div className="text-xs text-blue-200 uppercase tracking-wide">Versión</div>
              <div className="text-sm font-medium">v2.1.0</div>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
} 