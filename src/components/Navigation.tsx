import { Home, LayoutGrid, Heart, MessageSquare } from 'lucide-react';
import { motion } from 'motion/react';
import { Screen } from '../types';

interface NavigationProps {
  currentScreen: Screen;
  setScreen: (screen: Screen) => void;
}

export function Navigation({ currentScreen, setScreen }: NavigationProps) {
  const navItems = [
    { id: 'profile' as const, icon: Home },
    { id: 'explore' as const, icon: LayoutGrid },
    { id: 'matches' as const, icon: Heart },
    { id: 'chat' as const, icon: MessageSquare },
  ];

  return (
    <nav className="h-24 glass-morphism flex items-center justify-around px-8 pb-6 z-50 rounded-t-[40px] border-t-0 shadow-2xl">
      {navItems.map(({ id, icon: Icon }) => (
        <button
          key={id}
          id={`nav-${id}`}
          onClick={() => setScreen(id)}
          className={`p-3 transition-all duration-300 relative group outline-none ${
            currentScreen === id ? 'text-white' : 'text-white/20 hover:text-white/40'
          }`}
        >
          <Icon className={`w-8 h-8 transition-all duration-300 ${currentScreen === id ? 'scale-110' : 'group-active:scale-90'}`} />
          {currentScreen === id && (
            <motion.div 
              layoutId="nav-dot"
              className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-1 h-1 bg-white rounded-full shadow-[0_0_12px_rgba(255,255,255,1)]"
            />
          )}
        </button>
      ))}
    </nav>
  );
}
