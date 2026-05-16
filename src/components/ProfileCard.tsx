import { Heart, MapPin, ChevronLeft, MoreVertical } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Profile } from '../types';

interface ProfileCardProps {
  profile: Profile;
  direction?: number;
}

export function ProfileCard({ profile, direction }: ProfileCardProps) {
  return (
    <div className="relative w-full aspect-[3/4] rounded-[40px] overflow-hidden shadow-2xl border border-white/5 bg-secondary">
      <img
        src={profile.imageUrl}
        alt={profile.name}
        className="w-full h-full object-cover"
        referrerPolicy="no-referrer"
      />
      
      {/* Top Controls Overlay */}
      <div className="absolute top-0 inset-x-0 p-6 flex items-center justify-between z-20">
         <ChevronLeft className="w-5 h-5 text-white/70" />
         <MoreVertical className="w-5 h-5 text-white/70" />
      </div>

      {/* Overlay Content */}
      <div className="absolute inset-0 bg-gradient-to-t from-black/95 via-black/10 to-transparent flex flex-col justify-end p-8 sm:p-10">
        <div className="space-y-3">
          {profile.matchPercentage && (
            <motion.div 
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-white/10 backdrop-blur-md border border-white/20 w-fit px-4 py-1.5 rounded-full text-[10px] font-bold uppercase tracking-[0.2em] text-white/90"
            >
              {profile.matchPercentage}% Mutual Match
            </motion.div>
          )}
          <div className="flex items-center gap-3">
            <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tighter">
              {profile.name}, {profile.age}
            </h2>
          </div>
          <div className="flex flex-col gap-1.5">
            <div className="flex items-center gap-2 text-white/50 font-bold uppercase tracking-widest text-[9px] sm:text-[11px]">
              <MapPin className="w-3 h-3 sm:w-4 sm:h-4 opacity-70" />
              <span>{profile.location.toUpperCase()}</span>
            </div>
            {profile.shareLocation && (
              <div className="flex items-center gap-2 text-primary font-bold uppercase tracking-widest text-[9px] sm:text-[11px]">
                <motion.div 
                  initial={{ scale: 0.8, opacity: 0.5 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ repeat: Infinity, duration: 1.5, repeatType: 'reverse' }}
                  className="w-2 h-2 rounded-full bg-primary ml-1"
                />
                <span>Live Location: ~{(parseInt(profile.id, 36) % 5) + 1} km away</span>
              </div>
            )}
          </div>
        </div>
      </div>
      
      {/* Swipe Overlay Indicators */}
      {direction && (
        <motion.div
           initial={{ opacity: 0 }}
           animate={{ opacity: 1 }}
           className={`absolute inset-0 flex items-center justify-center z-10 pointer-events-none ${
             direction > 0 ? 'bg-white/20' : 'bg-white/5'
           }`}
        >
          <div className={`text-4xl font-black uppercase border-4 px-6 py-2 rounded-xl scale-110 ${
            direction > 0 ? 'text-white border-white' : 'text-white/40 border-white/40'
          }`}>
            {direction > 0 ? 'Like' : 'Nope'}
          </div>
        </motion.div>
      )}
    </div>
  );
}
