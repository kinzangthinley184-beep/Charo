import { Settings2 } from 'lucide-react';
import { Profile } from '../types';

const DEFAULT_PROPS = {
  gender: 'Woman',
  location: 'New York',
  photos: [],
  verified: false,
  occupation: 'Professional',
  education: 'University',
  height: "5'6\"",
  zodiacSign: 'Leo',
  bhutaneseZodiac: 'Tiger',
  religion: 'Spiritual',
  ethnicity: 'Mixed',
  languages: ['English'],
  hometown: 'Global',
  latitude: 0,
  longitude: 0,
  drinkingHabit: 'Socially',
  smokingHabit: 'Never',
  lookingFor: 'Relationship',
  profileCompletion: 80,
};

const LIKES: Profile[] = [
  { ...DEFAULT_PROPS, id: 'l1', name: 'Pema', age: 22, location: 'Thimphu', matchPercentage: 95, imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop' },
  { ...DEFAULT_PROPS, id: 'l2', name: 'Dechen', age: 24, location: 'Paro', matchPercentage: 88, imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200&auto=format&fit=crop' },
  { ...DEFAULT_PROPS, id: 'l3', name: 'Tashi', age: 23, location: 'Punakha', matchPercentage: 92, imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=200&auto=format&fit=crop' },
  { ...DEFAULT_PROPS, id: 'l4', name: 'Karma', age: 21, location: 'Wangdue', matchPercentage: 91, imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?q=80&w=200&auto=format&fit=crop' },
  { ...DEFAULT_PROPS, id: 'l5', name: 'Sonam', age: 25, location: 'Thimphu', matchPercentage: 85, imageUrl: 'https://images.unsplash.com/photo-1517365830460-955ce3ccd263?q=80&w=200&auto=format&fit=crop' },
];

const MATCHES: Profile[] = [
  { ...DEFAULT_PROPS, id: 'm1', name: 'Rigzin', age: 26, location: 'Thimphu', matchPercentage: 95, imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=400&auto=format&fit=crop' },
  { ...DEFAULT_PROPS, id: 'm2', name: 'Thinley', age: 29, location: 'Trongsa', matchPercentage: 81, imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400&auto=format&fit=crop' },
  { ...DEFAULT_PROPS, id: 'm3', name: 'Kinley', age: 24, location: 'Chukha', matchPercentage: 79, imageUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=400&auto=format&fit=crop' },
  { ...DEFAULT_PROPS, id: 'm4', name: 'Dawa', age: 27, location: 'Thimphu', matchPercentage: 98, imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?q=80&w=400&auto=format&fit=crop' },
];

interface MatchesProps {
  onOpenChat?: () => void;
  onOpenProfile?: () => void;
}

export function Matches({ onOpenChat, onOpenProfile }: MatchesProps) {
  const userImageUrl = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=100&auto=format&fit=crop";

  return (
    <div className="flex flex-col gap-12 p-8 pb-32">
      <div className="flex justify-between items-center glass-morphism p-5 rounded-[32px] shadow-2xl">
        <button onClick={onOpenProfile} className="p-2.5 bg-white/5 rounded-2xl hover:bg-white/10 transition-colors">
          <Settings2 className="w-5 h-5 text-white/50" />
        </button>
        <button onClick={onOpenProfile} className="w-12 h-12 rounded-2xl overflow-hidden border border-white/10 shadow-lg p-0 active:scale-95 transition-transform">
          <img src={userImageUrl} alt="Profile" className="w-full h-full object-cover" />
        </button>
      </div>

      <section>
        <div className="flex justify-between items-center mb-8 px-1">
          <h2 className="text-[10px] font-black uppercase tracking-[0.3em] text-white/30">Temporal Pulse</h2>
          <div className="flex items-center gap-2">
             <span className="w-1.5 h-1.5 bg-white rounded-full animate-pulse shadow-[0_0_8px_rgba(255,255,255,1)]"></span>
             <span className="text-[10px] font-black tracking-widest text-white/80">{LIKES.length * 5} POTENTIALS</span>
          </div>
        </div>
        <div className="flex gap-6 overflow-x-auto no-scrollbar pb-4 -mx-8 px-8">
          {LIKES.map((profile) => (
            <button key={profile.id} onClick={onOpenChat} className="flex flex-col items-center gap-4 flex-shrink-0 group">
              <div className="relative p-[2px] rounded-full bg-white/10 group-hover:bg-white/30 transition-colors shadow-2xl">
                <div className="w-20 h-20 rounded-full overflow-hidden border-[4px] border-app-bg shadow-inner transition-transform duration-500 group-hover:scale-105">
                  <img src={profile.imageUrl} alt={profile.name} className="w-full h-full object-cover" />
                </div>
              </div>
              <span className="text-[10px] font-bold uppercase tracking-[0.15em] text-white/40 group-hover:text-white transition-colors">{profile.name}</span>
            </button>
          ))}
        </div>
      </section>

      <section>
        <div className="flex justify-between items-center mb-8 px-1">
          <h2 className="text-[10px] font-black uppercase tracking-[0.3em] text-white/30">Established Bonds</h2>
        </div>
        <div className="grid grid-cols-2 gap-6">
          {MATCHES.map((profile, i) => (
            <button 
              key={profile.id} 
              onClick={onOpenChat} 
              className="relative aspect-[4/5] rounded-[40px] overflow-hidden group border border-white/5 active:scale-95 transition-all shadow-2xl bg-secondary"
            >
              <img 
                 src={profile.imageUrl} 
                 alt={profile.name} 
                 className="w-full h-full object-cover grayscale-[40%] group-hover:grayscale-0 group-hover:scale-110 transition-all duration-700 ease-out" 
              />
              <div className="absolute top-5 right-5 bg-black/60 backdrop-blur-md px-3 py-1.5 rounded-full text-[9px] font-black tracking-widest border border-white/10 text-white shadow-lg">
                {profile.matchPercentage}%
              </div>
              <div className="absolute inset-x-0 bottom-0 p-6 bg-gradient-to-t from-black/95 via-black/40 to-transparent text-left">
                <div className="flex items-center gap-2 mb-1">
                   <span className="text-xl font-black text-white tracking-tight">{profile.name}</span>
                </div>
                <p className="text-[9px] font-bold text-white/40 tracking-[0.2em] uppercase">{profile.age} • {profile.location}</p>
              </div>
            </button>
          ))}
        </div>
      </section>
    </div>
  );
}
