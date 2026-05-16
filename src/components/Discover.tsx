import { useState, useCallback, useRef, forwardRef, useEffect } from 'react';
import { animate, motion, AnimatePresence, useMotionValue, useTransform } from 'motion/react';
import { Profile } from '../types';
import { ProfileCard } from './ProfileCard';
import { ActionButtons } from './ActionButtons';
import { LayoutGrid } from 'lucide-react';
import { Map, AdvancedMarker } from '@vis.gl/react-google-maps';

const DEFAULT_PROPS = {
  gender: 'Woman',
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

const MOCK_PROFILES: Profile[] = [
  {
    ...DEFAULT_PROPS,
    id: '1',
    name: 'Sonam Wangmo',
    age: 22,
    location: 'Thimphu, Bhutan',
    imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop',
    matchPercentage: 95,
    verified: true,
    latitude: 27.4728,
    longitude: 89.6393,
    shareLocation: true,
  },
  {
    ...DEFAULT_PROPS,
    id: '2',
    name: 'Tandin Dorji',
    age: 25,
    location: 'Paro, Bhutan',
    imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1000&auto=format&fit=crop',
    matchPercentage: 88,
    shareLocation: true,
    latitude: 27.4305,
    longitude: 89.4133,
  },
  {
    ...DEFAULT_PROPS,
    id: '3',
    name: 'Dechen Choden',
    age: 24,
    location: 'Punakha, Bhutan',
    imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=1000&auto=format&fit=crop',
    matchPercentage: 92,
    verified: true,
    latitude: 27.5857,
    longitude: 89.8767,
    shareLocation: true,
  },
  {
    ...DEFAULT_PROPS,
    id: '4',
    name: 'Karma Yangzom',
    age: 23,
    location: 'Wangdue, Bhutan',
    imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1000&auto=format&fit=crop',
    matchPercentage: 85,
    latitude: 27.4891,
    longitude: 89.8970,
    shareLocation: true,
  },
  {
    ...DEFAULT_PROPS,
    id: '5',
    name: 'Nima Wangchuk',
    age: 27,
    location: 'Phuentsholing, Bhutan',
    imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop',
    matchPercentage: 82,
    gender: 'Man',
    latitude: 26.8615,
    longitude: 89.3820,
    shareLocation: true,
  },
  {
    ...DEFAULT_PROPS,
    id: '6',
    name: 'Pema Lhaden',
    age: 24,
    location: 'Thimphu, Bhutan',
    imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?q=80&w=1000&auto=format&fit=crop',
    matchPercentage: 89,
    latitude: 27.4500,
    longitude: 89.6500,
    shareLocation: true,
  }
];

const DraggableCard = forwardRef<HTMLDivElement, { 
  profile: Profile, 
  swipeDirection: number | null,
  onDrag: any,
  onDragEnd: any
}>(({ 
  profile, 
  swipeDirection, 
  onDrag, 
  onDragEnd 
}, ref) => {
  const x = useMotionValue(0);
  const rotate = useTransform(x, [-200, 200], [-15, 15]);
  const opacity = useTransform(x, [-300, -200, 0, 200, 300], [0, 1, 1, 1, 0]);
  
  const likeOpacity = useTransform(x, [50, 150], [0, 1]);
  const nopeOpacity = useTransform(x, [-50, -150], [0, 1]);
  
  const lastSwipeDirection = useRef(swipeDirection);
  if (swipeDirection !== null) {
    lastSwipeDirection.current = swipeDirection;
  }
  
  useEffect(() => {
    if (swipeDirection !== null) {
      animate(x, swipeDirection * 500, { duration: 0.3, ease: 'easeOut' });
    }
  }, [swipeDirection, x]);

  // Remember the last known non-null swipe direction for the exit animation
  const exitDirection = lastSwipeDirection.current || (x.get() > 0 ? 1 : -1);

  return (
    <motion.div
       ref={ref}
       style={{ x, rotate, opacity }}
       drag="x"
       dragConstraints={{ left: 0, right: 0 }}
       dragElastic={0.7}
       onDrag={onDrag}
       onDragEnd={onDragEnd}
       className="absolute inset-0 w-full h-full z-10 cursor-grab active:cursor-grabbing flex items-center justify-center"
       initial={{ scale: 0.9, opacity: 0 }}
       animate={{ scale: 1, opacity: 1 }}
       exit={{ x: exitDirection * 500, opacity: 0, transition: { duration: 0.3 } }}
       transition={{ type: 'spring', damping: 20, stiffness: 300 }}
    >
      <div className="relative w-full h-full rounded-[40px] overflow-hidden">
        <ProfileCard profile={profile} direction={swipeDirection !== null ? swipeDirection : undefined} />
        
        {/* Hardware-accelerated Swipe Overlays using Motion Values */}
        {swipeDirection === null && (
          <>
            <motion.div style={{ opacity: likeOpacity }} className="absolute inset-0 flex items-center justify-center z-10 pointer-events-none bg-white/20">
              <div className="text-4xl font-black uppercase border-4 px-6 py-2 rounded-xl scale-110 text-white border-white">
                Like
              </div>
            </motion.div>
            <motion.div style={{ opacity: nopeOpacity }} className="absolute inset-0 flex items-center justify-center z-10 pointer-events-none bg-white/5">
              <div className="text-4xl font-black uppercase border-4 px-6 py-2 rounded-xl scale-110 text-white/40 border-white/40">
                Nope
              </div>
            </motion.div>
          </>
        )}
      </div>
    </motion.div>
  );
});

interface DiscoverProps {
  onOpenChat?: () => void;
  onOpenProfile?: () => void;
}

export function Discover({ onOpenChat, onOpenProfile }: DiscoverProps) {
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [swipeDirection, setSwipeDirection] = useState<number | null>(null);
  const [activeTab, setActiveTab] = useState<'for-you' | 'nearby'>('for-you');
  
  const fetchProfiles = async () => {
    setLoading(true);
    try {
      setProfiles(MOCK_PROFILES);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProfiles();
  }, []);

  const currentProfile = profiles[0];
  const nextProfile = profiles[1];

  const handleJump = (profile: Profile) => {
    // Reorder profiles to put selected one at the top
    setProfiles(prev => {
      const filtered = prev.filter(p => p.id !== profile.id);
      return [profile, ...filtered];
    });
    setActiveTab('for-you');
  };

  const handleSwipe = useCallback(async (direction: 'left' | 'right', profile: Profile) => {
    // Optimistic UI update
    setProfiles((prev) => prev.slice(1));
    setSwipeDirection(null);
  }, []);

  const swipeOut = useCallback((direction: 'left' | 'right', profile: Profile) => {
    setSwipeDirection(direction === 'right' ? 1 : -1);
    setTimeout(() => handleSwipe(direction, profile), 200);
  }, [handleSwipe]);

  const onDragEnd = (_e: any, info: any) => {
    if (activeTab !== 'for-you' || !currentProfile) return;
    
    // Check velocity as well as distance for better UX
    const velocityX = info.velocity.x;
    const isSwipingFast = Math.abs(velocityX) > 500;
    
    if (info.offset.x > 80 || (isSwipingFast && info.offset.x > 30)) {
      swipeOut('right', currentProfile);
    } else if (info.offset.x < -80 || (isSwipingFast && info.offset.x < -30)) {
      swipeOut('left', currentProfile);
    } else {
      setSwipeDirection(null);
    }
  };

  const onDrag = (_e: any, info: any) => {
    // No-op to prevent state spam. Motion values handle the visual updates.
  };

  return (
    <div className="flex flex-col h-full bg-app-bg text-white">
      {/* Tabs */}
      <div className="flex justify-center gap-12 py-6 z-20 sticky top-0 bg-app-bg/50 backdrop-blur-md">
        <button 
          onClick={() => setActiveTab('for-you')}
          className={`text-sm font-black uppercase tracking-[0.3em] transition-all relative pb-2 ${activeTab === 'for-you' ? 'text-white' : 'text-white/20'}`}
        >
          Curated
          {activeTab === 'for-you' && <motion.div layoutId="tab-underline" className="absolute bottom-0 left-0 right-0 h-0.5 bg-white rounded-full shadow-[0_0_10px_rgba(255,255,255,0.5)]" />}
        </button>
        <button 
          onClick={() => setActiveTab('nearby')}
          className={`text-sm font-black uppercase tracking-[0.3em] transition-all relative pb-2 ${activeTab === 'nearby' ? 'text-white' : 'text-white/20'}`}
        >
          Proximity
          {activeTab === 'nearby' && <motion.div layoutId="tab-underline" className="absolute bottom-0 left-0 right-0 h-0.5 bg-white rounded-full shadow-[0_0_10px_rgba(255,255,255,0.5)]" />}
        </button>
      </div>

      <div className="flex-1 overflow-hidden relative">
        <AnimatePresence mode="wait">
          {activeTab === 'for-you' ? (
            <motion.div 
              key="for-you"
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.02 }}
              transition={{ duration: 0.4, ease: [0.22, 1, 0.36, 1] }}
              className="h-full flex flex-col pt-4"
            >
              {!currentProfile ? (
                 <div className="flex flex-col items-center justify-center p-12 h-full text-center">
                   <div className="w-20 h-20 rounded-full border border-white/10 flex items-center justify-center mb-8">
                      <LayoutGrid className="w-8 h-8 text-white/20" />
                   </div>
                   <h2 className="text-xl font-bold mb-3 text-white tracking-tight">The Horizon is Clear</h2>
                   <p className="text-grey-text text-sm max-w-[240px] leading-relaxed">You've explored all current possibilities. Patterns will emerge again soon.</p>
                   <button 
                     onClick={() => setProfiles(MOCK_PROFILES)}
                     className="mt-10 text-xs font-black uppercase tracking-[0.3em] text-white/40 hover:text-white transition-colors"
                   >
                     Reload Experience
                   </button>
                 </div>
              ) : (
                <>
                  <div className="flex-1 w-full flex flex-col items-center justify-center px-6 overflow-hidden">
                    <div className="relative w-full max-w-[420px] aspect-[10/14] flex items-center justify-center">
                      {/* Next Card (Background) */}
                      <AnimatePresence>
                        {nextProfile && (
                          <div className="absolute inset-0 scale-[0.88] opacity-20 pointer-events-none translate-y-8 transition-all duration-700">
                            <ProfileCard profile={nextProfile} />
                          </div>
                        )}
                      </AnimatePresence>

                      {/* Current Card (Front) */}
                      <AnimatePresence>
                        <DraggableCard 
                           key={currentProfile.id}
                           profile={currentProfile}
                           swipeDirection={swipeDirection}
                           onDrag={onDrag}
                           onDragEnd={onDragEnd}
                        />
                      </AnimatePresence>
                    </div>
                  </div>

                  <ActionButtons 
                    onLike={() => {
                      if (!currentProfile) return;
                      swipeOut('right', currentProfile);
                    }}
                    onDislike={() => {
                      if (!currentProfile) return;
                      swipeOut('left', currentProfile);
                    }}
                    onViewProfile={onOpenProfile}
                    onMessage={onOpenChat}
                  />
                </>
              )}
            </motion.div>
          ) : (
            <motion.div 
              key="nearby"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
              className="h-full relative overflow-hidden"
            >
              <Map
                defaultCenter={{lat: 27.4728, lng: 89.6393}} /* Thimphu */
                defaultZoom={8}
                mapId="DEMO_MAP_ID"
                internalUsageAttributionIds={['gmp_mcp_codeassist_v1_aistudio']}
                style={{width: '100%', height: '100%'}}
                disableDefaultUI={true}
                colorScheme="DARK"
              >
                {MOCK_PROFILES.filter(p => p.shareLocation).map((profile, i) => (
                  <AdvancedMarker 
                    onClick={() => handleJump(profile)}
                    key={profile.id} 
                    position={{lat: profile.latitude!, lng: profile.longitude!}} 
                    title={profile.name}
                    className="group"
                  >
                    <motion.div 
                      initial={{ scale: 0, y: 50 }}
                      animate={{ scale: 1, y: 0 }}
                      transition={{ 
                        type: 'spring', 
                        damping: 12, 
                        stiffness: 100, 
                        delay: i * 0.1 
                      }}
                      className="relative flex flex-col items-center cursor-pointer"
                    >
                      {/* Floating container */}
                      <motion.div
                        animate={{ y: [0, -6, 0] }}
                        transition={{ 
                          repeat: Infinity, 
                          duration: 2 + i * 0.2, 
                          ease: "easeInOut" 
                        }}
                        className="relative z-10"
                      >
                         {/* Status Bubble (like Snapchat) */}
                         <div className="absolute -top-7 left-1/2 -translate-x-1/2 bg-white text-black text-[10px] font-black uppercase tracking-wider px-3 py-1 rounded-2xl whitespace-nowrap shadow-[0_4px_15px_rgba(0,0,0,0.5)] opacity-0 group-hover:opacity-100 transition-all duration-300 transform group-hover:-translate-y-1">
                            Say hi to {profile.name.split(' ')[0]}
                            <div className="absolute -bottom-[5px] left-1/2 -translate-x-1/2 border-t-[6px] border-t-white border-l-[6px] border-l-transparent border-r-[6px] border-r-transparent" />
                         </div>

                         {/* Avatar Pin */}
                         <div className="w-[64px] h-[64px] rounded-[24px] bg-gradient-to-tr from-primary via-primary/90 to-[#FFD700] p-[3px] shadow-[0_8px_20px_rgba(212,175,55,0.4)] relative transform transition-transform group-hover:scale-105">
                           <div className="w-full h-full rounded-[21px] overflow-hidden bg-black/80 backdrop-blur">
                             <img 
                               src={profile.imageUrl} 
                               alt={profile.name} 
                               className="w-full h-full object-cover"
                               referrerPolicy="no-referrer"
                             />
                           </div>
                           <div className="absolute -bottom-1.5 -right-1.5 w-5 h-5 bg-[#00FF00] rounded-full border-[3px] border-[#1a1a1a] z-20">
                             <motion.div 
                               initial={{ scale: 0.8, opacity: 0.8 }}
                               animate={{ scale: 2.2, opacity: 0 }}
                               transition={{ repeat: Infinity, duration: 2 }}
                               className="absolute inset-0 rounded-full bg-[#00FF00]"
                             />
                           </div>
                         </div>
                      </motion.div>
                      
                      {/* Shadow Drop (simulating 3D float) */}
                      <motion.div 
                        className="w-12 h-2.5 bg-black/50 blur-[3px] rounded-[100%] mt-2"
                        animate={{ scale: [1, 0.7, 1], opacity: [0.6, 0.3, 0.6] }}
                        transition={{ 
                          repeat: Infinity, 
                          duration: 2 + i * 0.2, 
                          ease: "easeInOut" 
                        }}
                      />
                    </motion.div>
                  </AdvancedMarker>
                ))}
              </Map>
              
              {/* Overlay gradient so map fades in to bottom */}
              <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-app-bg to-transparent pointer-events-none" />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
