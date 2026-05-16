import { X, Heart, MessageCircle } from 'lucide-react';
import { motion } from 'motion/react';

interface ActionButtonsProps {
  onLike: () => void;
  onDislike: () => void;
  onViewProfile?: () => void;
  onMessage?: () => void;
}

export function ActionButtons({ onLike, onDislike, onViewProfile, onMessage }: ActionButtonsProps) {
  return (
    <div className="flex flex-col items-center gap-8 w-full px-10 pb-12 mt-auto">
      <div className="flex items-center gap-8">
        <motion.button
          id="btn-dislike"
          whileHover={{ scale: 1.1, rotate: -5 }}
          whileTap={{ scale: 0.9 }}
          onClick={onDislike}
          className="w-16 h-16 rounded-full glass-morphism flex items-center justify-center text-white/30 hover:text-white/80 transition-all group"
        >
          <X className="w-8 h-8 group-hover:rotate-90 transition-transform duration-500" />
        </motion.button>
        
        <motion.button
          id="btn-like"
          whileHover={{ scale: 1.15 }}
          whileTap={{ scale: 0.9 }}
          onClick={onLike}
          className="w-20 h-20 rounded-full bg-white flex items-center justify-center text-black shadow-[0_10px_40px_rgba(255,255,255,0.2)] transition-all group"
        >
          <Heart className="w-10 h-10 fill-current group-hover:scale-110 transition-transform duration-300" />
        </motion.button>

        <motion.button
          id="btn-message"
          whileHover={{ scale: 1.1, rotate: 5 }}
          whileTap={{ scale: 0.9 }}
          onClick={onMessage}
          className="w-16 h-16 rounded-full glass-morphism flex items-center justify-center text-white/30 hover:text-white/80 transition-all group"
        >
          <MessageCircle className="w-8 h-8 group-hover:scale-110 transition-transform duration-300" />
        </motion.button>
      </div>
    </div>
  );
}
