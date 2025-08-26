"use client";
import { useState, useEffect } from "react";

export default function Header() {
  const [currentTime, setCurrentTime] = useState(new Date());
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('es-ES', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    });
  };

  const formatDate = (date: Date) => {
    const options: Intl.DateTimeFormatOptions = {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    };
    return date.toLocaleDateString('es-ES', options).toUpperCase();
  };

  return (
    <header className="w-full flex flex-row items-center justify-start bg-black text-white border-b-8 border-gray-500 h-20 shadow-[0_0_16px_#a21caf] rounded-b-xl select-none" style={{boxSizing: 'border-box', padding: 0}}>
      {/* Logo y línea divisoria izquierda en flex-col */}
      <div className="flex flex-col items-center justify-center" style={{height: '100%'}}>
        <div className="relative flex-shrink-0 flex items-center justify-start" style={{width: '7.2rem', height: '7.2rem', margin: 0, padding: 0, marginLeft: '0px'}}>
          <img src="/LOGO.png" alt="SAMABOT Logo" className="relative z-10" style={{
            height: '5rem',
            width: '5rem',
            filter: 'brightness(1.0) contrast(1.3) drop-shadow(0 0 0.5px #ffffff)',
            animation: 'logoGlow 1s ease-in-out infinite'
          }} />
        </div>
        {/* Línea divisoria izquierda */}
        <div className="w-1 rounded bg-[#a3a3a3]" style={{height: '3.2rem', alignSelf: 'flex-end', marginTop: 0}}></div>
      </div>
      
      {/* Título centrado y pegado al logo */}
      <div className="flex-1 flex items-center h-full" style={{ marginLeft: 0, paddingLeft: 0 }}>
        <div style={{
          width: '100%',
          overflowX: 'auto',
          whiteSpace: 'nowrap',
          textAlign: 'left',
          paddingLeft: 0,
          marginLeft: '-0.5rem' // Ajusta este valor para pegarlo más
        }}>
          <span
            className="font-mono"
            style={{
              color: '#fff',
              fontSize: '2.5rem',
              textShadow: '0 0 8px #60a5fa, 0 0 24px #3b82f6, 2px 2px 0 #000, 0 4px 24px #3b82f6',
              letterSpacing: '0.01em',
              wordSpacing: '0.1em',
              userSelect: 'none',
              textTransform: 'uppercase',
              transform: 'scaleY(4.1) scaleX(0.3)',
              whiteSpace: 'nowrap'
            }}
          >
            <span style={{color: '#c084fc'}}>S</span>mart <span style={{color: '#c084fc'}}>A</span>ssistant for <span style={{color: '#c084fc'}}>M</span>echatronics, <span style={{color: '#c084fc'}}>I</span>nstrumentation, <span style={{color: '#c084fc'}}>T</span>roubleshooting, and <span style={{color: '#c084fc'}}>A</span>utomation
          </span>
        </div>
      </div>
      
      {/* Línea divisoria derecha */}
      <div className="w-1 rounded bg-[#a3a3a3] mx-2" style={{height: '4.5rem', alignSelf: 'center'}}></div>
      
      {/* Bloque hora/fecha */}
      <div className="flex flex-col items-center justify-center h-full flex-shrink-0 pr-2 py-2" style={{height: '100%'}}>
        {mounted ? (
          <>
            <span className="arcade-title-orbitron" style={{textShadow: '0 0 2px #fff', fontSize: '0.74rem', marginRight: '0', color: '#fff', alignSelf: 'center', marginTop: 0, marginBottom: '8px', textAlign: 'center'}}>
              {formatDate(currentTime)}
            </span>
            <span className="arcade-title-orbitron" style={{
              textShadow: '0 0 4px #fff, 0 0 8px #fff',
              minWidth: '135px',
              textAlign: 'center',
              display: 'inline-block',
              fontSize: '2.0rem',
              marginBottom: 0,
              color: '#fff',
              alignSelf: 'center',
              transform: 'scaleX(1.26) scaleY(1.32)',
              fontFamily: 'monospace',
              letterSpacing: '0.1em'
            }}>
              {formatTime(currentTime)}
            </span>
          </>
        ) : (
          <>
            <span className="arcade-title-orbitron" style={{visibility: 'hidden', fontSize: '0.67rem', minHeight: '1em'}}>
              00/00/0000
            </span>
            <span className="arcade-title-orbitron" style={{visibility: 'hidden', fontSize: '2.09rem', minHeight: '1em'}}>
              00:00:00
            </span>
          </>
        )}
      </div>
    </header>
  );
} 