'use client';

import { useState } from 'react';

interface Message {
  id: string;
  text: string;
  isUser: boolean;
  timestamp: Date;
}

export default function SimpleSamitaPanel() {
  const [messages, setMessages] = useState<Message[]>([
    { 
      id: '1',
      text: "¡Hola! Soy SAMITA, tu asistente de IA industrial especializado en sistemas PLC Siemens. ¿En qué puedo ayudarte hoy?", 
      isUser: false,
      timestamp: new Date()
    }
  ]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const sendMessage = async () => {
    if (!inputMessage.trim() || isLoading) return;

    const userMessage = inputMessage;
    const userMsgId = Date.now().toString();
    
    setInputMessage('');
    setMessages(prev => [...prev, { 
      id: userMsgId,
      text: userMessage, 
      isUser: true,
      timestamp: new Date()
    }]);
    setIsLoading(true);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: userMessage }),
      });

      const data = await response.json();
      
      setMessages(prev => [...prev, { 
        id: (Date.now() + 1).toString(),
        text: data.response || "Lo siento, no pude procesar tu mensaje.", 
        isUser: false,
        timestamp: new Date()
      }]);
    } catch (_error) {
      setMessages(prev => [...prev, { 
        id: (Date.now() + 1).toString(),
        text: "Error en la comunicación con SAMITA. Verifica la conexión.", 
        isUser: false,
        timestamp: new Date()
      }]);
    } finally {
      setIsLoading(false);
    }
  };

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('es-ES', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  return (
    <div className="bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 rounded-xl p-6 h-[600px] flex flex-col shadow-2xl border border-gray-700">
      {/* Header */}
      <div className="flex items-center space-x-3 mb-6">
        <div className="relative">
          <div className="w-4 h-4 bg-gradient-to-r from-green-400 to-blue-500 rounded-full animate-pulse"></div>
          <div className="absolute inset-0 w-4 h-4 bg-gradient-to-r from-green-400 to-blue-500 rounded-full animate-ping opacity-75"></div>
        </div>
        <div>
          <h3 className="text-xl font-bold text-white">SAMITA AI</h3>
          <p className="text-sm text-gray-400">Asistente Industrial Inteligente</p>
        </div>
        <div className="ml-auto">
          <div className="flex space-x-1">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            <div className="w-2 h-2 bg-yellow-500 rounded-full animate-pulse delay-100"></div>
            <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse delay-200"></div>
          </div>
        </div>
      </div>
      
      {/* Messages Container */}
      <div className="flex-1 overflow-y-auto space-y-4 mb-6">
        {messages.map((msg) => (
          <div key={msg.id} className={`flex ${msg.isUser ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-xs lg:max-w-md px-4 py-3 rounded-2xl shadow-lg ${
              msg.isUser 
                ? 'bg-gradient-to-r from-blue-600 to-blue-700 text-white' 
                : 'bg-gradient-to-r from-gray-700 to-gray-600 text-gray-100'
            }`}>
              <div className="text-sm">{msg.text}</div>
              <div className={`text-xs mt-2 opacity-70 ${msg.isUser ? 'text-blue-200' : 'text-gray-400'}`}>
                {formatTime(msg.timestamp)}
              </div>
            </div>
          </div>
        ))}
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-gradient-to-r from-gray-700 to-gray-600 text-gray-100 px-4 py-3 rounded-2xl shadow-lg">
              <div className="flex items-center space-x-2">
                <div className="flex space-x-1">
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-100"></div>
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-200"></div>
                </div>
                <span className="text-sm">SAMITA está pensando...</span>
              </div>
            </div>
          </div>
        )}
      </div>
      
      {/* Input Area */}
      <div className="flex space-x-3">
        <div className="flex-1 relative">
          <input
            type="text"
            value={inputMessage}
            onChange={(e) => setInputMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
            placeholder="Escribe tu mensaje a SAMITA..."
            className="w-full bg-gray-800 text-white px-4 py-3 rounded-xl border border-gray-600 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition-all duration-200 placeholder-gray-400"
            disabled={isLoading}
          />
        </div>
        <button
          onClick={sendMessage}
          disabled={isLoading || !inputMessage.trim()}
          className="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white px-6 py-3 rounded-xl font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-95"
        >
          {isLoading ? (
            <div className="flex items-center space-x-2">
              <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
              <span>Enviando...</span>
            </div>
          ) : (
            <div className="flex items-center space-x-2">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
              <span>Enviar</span>
            </div>
          )}
        </button>
      </div>
      
      {/* Status Bar */}
      <div className="mt-4 pt-4 border-t border-gray-700">
        <div className="flex items-center justify-between text-xs text-gray-400">
          <div className="flex items-center space-x-2">
            <div className="w-2 h-2 bg-green-500 rounded-full"></div>
            <span>Conectado</span>
          </div>
          <div className="flex items-center space-x-4">
            <span>Modelo: samita-es</span>
            <span>v2.0</span>
          </div>
        </div>
      </div>
    </div>
  );
} 