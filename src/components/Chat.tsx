import React, { useState, useRef } from 'react';
import { ChevronLeft, MoreVertical, Camera, Image as ImageIcon, Loader2, Flag, Ban, X } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Message } from '../types';

const INITIAL_MESSAGES: Message[] = [
  { id: '1', text: 'Hello! How are you doing? 😊', sender: 'me', timestamp: 'Today, 12:30 AM' },
  { id: '2', text: 'Hi! Great! 💫', sender: 'them', timestamp: '30 mins' },
];

export function Chat({ onBack }: { onBack: () => void }) {
  const [messages, setMessages] = useState<Message[]>(INITIAL_MESSAGES);
  const [inputText, setInputText] = useState('');
  const [isUploading, setIsUploading] = useState(false);
  const [showMenu, setShowMenu] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleCameraClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    
    // Simulate upload and conversion to base64
    const reader = new FileReader();
    reader.onloadend = () => {
      const newMessage: Message = {
        id: Date.now().toString(),
        image: reader.result as string,
        sender: 'me',
        timestamp: 'Just now'
      };
      setMessages(prev => [...prev, newMessage]);
      setIsUploading(false);
      
      // Clear input
      if (fileInputRef.current) fileInputRef.current.value = '';

      // Simulate reply
      setTimeout(() => {
        setMessages(prev => [...prev, {
          id: Date.now().toString() + 'reply',
          text: 'Wow, nice photo! 😍',
          sender: 'them',
          timestamp: 'Just now'
        }]);
      }, 1500);
    };
    reader.readAsDataURL(file);
  };

  const handleSend = () => {
    if (!inputText.trim()) return;
    const newMessage: Message = {
      id: Date.now().toString(),
      text: inputText.trim(),
      sender: 'me',
      timestamp: 'Just now'
    };
    setMessages([...messages, newMessage]);
    setInputText('');
    
    // Simulate reply
    setTimeout(() => {
      setMessages(prev => [...prev, {
        id: Date.now().toString() + 'reply',
        text: 'That sounds awesome! 🤩',
        sender: 'them',
        timestamp: 'Just now'
      }]);
    }, 1500);
  };

  return (
    <div className="flex flex-col h-full bg-app-bg animate-in slide-in-from-right duration-300">
      {/* Header */}
      <header className="flex items-center justify-between p-6 px-8 border-b border-white/5 bg-app-bg/8 backdrop-blur-xl sticky top-0 z-10">
        <div className="flex items-center gap-5">
          <button onClick={onBack} className="p-2.5 -ml-2 bg-white/5 rounded-xl hover:bg-white/10 transition-colors active:scale-95">
            <ChevronLeft className="w-6 h-6" />
          </button>
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full overflow-hidden border border-white/10 shadow-xl">
              <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format" alt="Jenna" className="w-full h-full object-cover" />
            </div>
            <div className="flex items-center gap-2">
              <span className="font-extrabold text-base uppercase tracking-widest italic leading-tight">Jenna</span>
              <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse shadow-[0_0_8px_rgba(34,197,94,0.5)]" />
            </div>
          </div>
        </div>
        <button onClick={() => setShowMenu(true)} className="p-3 bg-white/5 rounded-xl hover:bg-white/10 transition-colors active:scale-95">
          <MoreVertical className="w-6 h-6 text-white/50" />
        </button>
      </header>

      <AnimatePresence>
        {showMenu && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-6"
            onClick={() => setShowMenu(false)}
          >
            <motion.div
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              className="bg-secondary w-full max-w-sm rounded-[32px] overflow-hidden border border-white/10 shadow-2xl"
              onClick={e => e.stopPropagation()}
            >
              <div className="p-6">
                <button 
                  onClick={() => setShowMenu(false)}
                  className="w-full flex items-center gap-4 p-4 rounded-2xl hover:bg-white/5 text-left transition-colors"
                >
                  <Ban className="w-5 h-5 text-red-500" />
                  <div className="flex-1">
                    <p className="font-bold text-white">Block Jenna</p>
                    <p className="text-sm text-white/50">Stop all communication.</p>
                  </div>
                </button>
                <button 
                  onClick={() => setShowMenu(false)}
                  className="w-full flex items-center gap-4 p-4 rounded-2xl hover:bg-white/5 text-left transition-colors"
                >
                  <Flag className="w-5 h-5 text-yellow-500" />
                  <div className="flex-1">
                    <p className="font-bold text-white">Report Jenna</p>
                    <p className="text-sm text-white/50">Report inappropriate behavior.</p>
                  </div>
                </button>
                <div className="pt-4 mt-4 border-t border-white/10">
                  <button 
                    onClick={() => setShowMenu(false)}
                    className="w-full text-center py-3 font-bold text-white/50 hover:text-white"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-6 flex flex-col gap-6 no-scrollbar pb-10">
        {messages.map((msg, idx) => {
          const isMe = msg.sender === 'me';
          return (
            <div key={msg.id} className={`flex flex-col ${isMe ? 'items-end' : 'items-start'}`}>
              <motion.div
                initial={{ y: 12, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: idx * 0.05 }}
                className={`max-w-[80%] overflow-hidden rounded-[24px] text-sm font-medium shadow-xl ${
                  isMe 
                  ? 'bg-gradient-to-br from-secondary to-secondary/80 text-white border border-white/10 rounded-tr-none' 
                  : 'bg-white/10 backdrop-blur-md text-white border border-white/5 rounded-tl-none'
                }`}
              >
                {msg.image && (
                  <img src={msg.image} alt="Sent" className="w-full h-auto max-h-[300px] object-cover" />
                )}
                {msg.text && (
                  <div className="px-5 py-3.5">
                    {msg.text}
                  </div>
                )}
              </motion.div>
              <span className="text-[8px] font-black text-white/20 mt-2 px-1 uppercase tracking-widest leading-none">
                {msg.timestamp}
              </span>
            </div>
          );
        })}
      </div>

      {/* Input Area */}
      <div className="p-6">
        <div className="flex items-center gap-3 bg-white/5 border border-white/5 backdrop-blur-2xl rounded-[28px] p-2 pl-5 shadow-2xl">
          <input 
            type="file" 
            ref={fileInputRef} 
            className="hidden" 
            accept="image/*" 
            capture="environment"
            onChange={handleFileChange}
          />
          <button 
            onClick={handleCameraClick}
            disabled={isUploading}
            className="text-white/30 hover:text-white transition-colors disabled:opacity-50"
          >
            {isUploading ? <Loader2 className="w-5 h-5 animate-spin" /> : <Camera className="w-5 h-5" />}
          </button>
          <input 
            type="text" 
            placeholder="Express..." 
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            className="flex-1 bg-transparent text-sm focus:outline-none placeholder:text-white/20 py-3"
          />
          <button 
            onClick={handleSend}
            disabled={!inputText.trim()}
            className={`w-11 h-11 rounded-full flex items-center justify-center transition-all active:scale-90 shadow-lg ${
              inputText.trim() ? 'bg-white text-black' : 'bg-white/5 text-white/20'
            }`}
          >
            <ChevronLeft className="w-5 h-5 rotate-180 -mr-0.5" />
          </button>
        </div>
      </div>
    </div>
  );
}
