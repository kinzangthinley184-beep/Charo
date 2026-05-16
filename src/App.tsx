/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Navigation } from './components/Navigation';
import { Discover } from './components/Discover';
import { UserProfile } from './components/UserProfile';
import { Matches } from './components/Matches';
import { Chat } from './components/Chat';
import { Screen } from './types';
import { APIProvider } from '@vis.gl/react-google-maps';

const API_KEY =
  process.env.GOOGLE_MAPS_PLATFORM_KEY ||
  (import.meta as any).env?.VITE_GOOGLE_MAPS_PLATFORM_KEY ||
  (globalThis as any).GOOGLE_MAPS_PLATFORM_KEY ||
  '';
const hasValidKey = Boolean(API_KEY) && API_KEY !== 'YOUR_API_KEY';

export default function App() {
  const [currentScreen, setScreen] = useState<Screen>('explore');

  if (!hasValidKey) {
    return (
      <div style={{display:'flex',alignItems:'center',justifyContent:'center',height:'100vh',backgroundColor:'#0A0A0A',color:'#fff',fontFamily:'sans-serif'}}>
        <div style={{textAlign:'center',maxWidth:520}}>
          <h2>Google Maps API Key Required</h2>
          <p><strong>Step 1:</strong> <a href="https://console.cloud.google.com/google/maps-apis/start?utm_campaign=gmp-code-assist-ais" target="_blank" rel="noopener" style={{color:'#D4AF37'}}>Get an API Key</a></p>
          <p><strong>Step 2:</strong> Add your key as a secret in AI Studio:</p>
          <ul style={{textAlign:'left',lineHeight:'1.8'}}>
            <li>Open <strong>Settings</strong> (⚙️ gear icon, <strong>top-right corner</strong>)</li>
            <li>Select <strong>Secrets</strong></li>
            <li>Type <code>GOOGLE_MAPS_PLATFORM_KEY</code> as the secret name, press <strong>Enter</strong></li>
            <li>Paste your API key as the value, press <strong>Enter</strong></li>
          </ul>
          <p>The app rebuilds automatically after you add the secret.</p>
        </div>
      </div>
    );
  }

  return (
    <APIProvider apiKey={API_KEY} version="weekly">
      <div className="flex flex-col h-screen bg-app-bg text-white max-w-lg mx-auto overflow-hidden shadow-2xl relative">
        {/* Background Atmosphere */}
        <div className="absolute inset-0 pointer-events-none z-0">
          <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary/10 rounded-full blur-[100px]" />
          <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-primary/5 rounded-full blur-[100px]" />
        </div>

        {/* Main Content */}
        <main className="flex-1 relative z-10 overflow-hidden">
          <AnimatePresence mode="wait">
            {currentScreen === 'profile' && (
              <motion.div 
                key="profile" 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.98 }}
                className="h-full overflow-y-auto"
              >
                <UserProfile onLogout={() => {}} />
              </motion.div>
            )}
            {currentScreen === 'explore' && (
              <motion.div 
                key="explore" 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="h-full"
              >
                <Discover onOpenChat={() => setScreen('chat')} onOpenProfile={() => setScreen('profile')} />
              </motion.div>
            )}
            {currentScreen === 'matches' && (
              <motion.div 
                key="matches" 
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="h-full overflow-y-auto"
              >
                <Matches onOpenChat={() => setScreen('chat')} onOpenProfile={() => setScreen('profile')} />
              </motion.div>
            )}
            {currentScreen === 'chat' && (
              <motion.div 
                key="chat" 
                initial={{ opacity: 0, x: 50 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 50 }}
                className="h-full"
              >
                <Chat onBack={() => setScreen('matches')} />
              </motion.div>
            )}
          </AnimatePresence>
        </main>

        {/* Navigation - Hidden in Chat */}
        {currentScreen !== 'chat' && (
          <div className="relative z-20">
            <Navigation currentScreen={currentScreen} setScreen={setScreen} />
          </div>
        )}
      </div>
    </APIProvider>
  );
}

