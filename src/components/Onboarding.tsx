import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronLeft, ArrowRight, Music, Plane, Coffee, Gamepad, Film, Palette, Camera, Check } from 'lucide-react';
import { doc, setDoc, serverTimestamp } from 'firebase/firestore';
import { auth, db, handleFirestoreError, OperationType } from '../lib/firebase';

interface OnboardingProps {
  onComplete: (data: any) => void;
}

const INTEREST_MAP: Record<string, { icon: React.ReactNode, label: string }> = {
  music: { icon: <Music className="w-5 h-5" />, label: 'Music' },
  travel: { icon: <Plane className="w-5 h-5" />, label: 'Travel' },
  coffee: { icon: <Coffee className="w-5 h-5" />, label: 'Coffee' },
  gaming: { icon: <Gamepad className="w-5 h-5" />, label: 'Gaming' },
  movies: { icon: <Film className="w-5 h-5" />, label: 'Movies' },
  art: { icon: <Palette className="w-5 h-5" />, label: 'Art' },
};

export function Onboarding({ onComplete }: OnboardingProps) {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    gender: 'Woman',
    bio: '',
    interests: [] as string[],
    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1000&auto=format&fit=crop'
  });

  const [loading, setLoading] = useState(false);
  const totalSteps = 5;

  const nextStep = async () => {
    if (step < totalSteps) {
      setStep(step + 1);
    } else {
      if (!auth.currentUser) return;
      setLoading(true);
      const userPath = `users/${auth.currentUser.uid}`;
      try {
        const profileData = {
          ...formData,
          uid: auth.currentUser.uid,
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp(),
          verified: false,
          profileCompletion: 100,
          location: 'Thimphu', // Default for now
          bhutaneseZodiac: 'Tiger', // Default for now
          zodiacSign: 'Leo', // Default for now
          occupation: 'Student' // Default for now
        };
        await setDoc(doc(db, 'users', auth.currentUser.uid), profileData);
        onComplete(profileData);
      } catch (error) {
        handleFirestoreError(error, OperationType.WRITE, userPath);
      } finally {
        setLoading(false);
      }
    }
  };

  const prevStep = () => {
    if (step > 1) setStep(step - 1);
  };

  const toggleInterest = (key: string) => {
    setFormData(prev => ({
      ...prev,
      interests: prev.interests.includes(key) 
        ? prev.interests.filter(i => i !== key)
        : [...prev.interests, key]
    }));
  };

  const isStepValid = () => {
    if (step === 1) return formData.name.length >= 2;
    if (step === 2) return formData.age !== '' && parseInt(formData.age) >= 18;
    if (step === 3) return formData.gender !== '';
    if (step === 4) return formData.interests.length >= 1;
    if (step === 5) return formData.bio.length >= 10;
    return true;
  };

  return (
    <div className="flex flex-col h-full bg-app-bg text-white relative overflow-hidden font-sans">
      {/* Progress Bar */}
      <div className="absolute top-0 left-0 w-full flex h-1.5 z-50">
        {[...Array(totalSteps)].map((_, i) => (
          <div 
            key={i} 
            className={`flex-1 transition-all duration-500 ${i + 1 <= step ? 'bg-primary' : 'bg-white/10'}`}
          />
        ))}
      </div>

      <div className="flex-1 flex flex-col px-6 py-10 sm:p-8 z-10 pt-16 sm:pt-20">
        <div className="flex items-center justify-between mb-8 sm:mb-12">
          {step > 1 ? (
            <button onClick={prevStep} className="p-3 -ml-3 rounded-full hover:bg-white/5 transition-colors">
              <ChevronLeft className="w-8 h-8" />
            </button>
          ) : (
            <div className="w-8 h-8" />
          )}
          <span className="text-grey-text font-black text-xs sm:text-sm uppercase tracking-widest">{step} / {totalSteps}</span>
          <div className="w-8 h-8" />
        </div>

        <AnimatePresence mode="wait">
          {step === 1 && (
            <motion.div 
              key="step1"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="flex-1 flex flex-col"
            >
              <h1 className="text-3xl sm:text-4xl font-black mb-2">My name is</h1>
              <p className="text-grey-text font-medium mb-8 sm:mb-12 text-sm sm:text-base">This is how it will appear on your profile.</p>
              
              <input 
                autoFocus
                type="text"
                placeholder="Name"
                className="bg-transparent border-b-[3px] border-primary pb-3 sm:pb-4 text-3xl sm:text-4xl font-black outline-none placeholder:text-white/5"
                value={formData.name}
                onChange={e => setFormData({...formData, name: e.target.value})}
              />
            </motion.div>
          )}

          {step === 2 && (
            <motion.div 
              key="step2"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="flex-1 flex flex-col"
            >
              <h1 className="text-3xl sm:text-4xl font-black mb-2">My age is</h1>
              <p className="text-grey-text font-medium mb-8 sm:mb-12 text-sm sm:text-base">You must be at least 18 years old.</p>
              
              <input 
                autoFocus
                type="number"
                placeholder="Age"
                className="bg-transparent border-b-[3px] border-primary pb-3 sm:pb-4 text-3xl sm:text-4xl font-black outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none placeholder:text-white/5"
                value={formData.age}
                onChange={e => setFormData({...formData, age: e.target.value})}
              />
            </motion.div>
          )}

          {step === 3 && (
            <motion.div 
              key="step3"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="flex-1 flex flex-col"
            >
              <h1 className="text-3xl sm:text-4xl font-black mb-2">I am a</h1>
              <p className="text-grey-text font-medium mb-8 sm:mb-12 text-sm sm:text-base">Select your gender.</p>
              
              <div className="flex flex-col gap-3 sm:gap-4">
                {['Woman', 'Man', 'Non-binary'].map((g) => (
                  <button
                    key={g}
                    onClick={() => setFormData({...formData, gender: g})}
                    className={`w-full py-4 sm:py-5 rounded-2xl text-lg sm:text-xl font-bold border-2 transition-all ${
                      formData.gender === g 
                        ? 'border-primary bg-primary text-black shadow-[0_0_20px_rgba(255,255,255,0.15)]' 
                        : 'border-white/10 text-grey-text hover:border-white/20'
                    }`}
                  >
                    {g}
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          {step === 4 && (
            <motion.div 
              key="step4"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="flex-1 flex flex-col"
            >
              <h1 className="text-3xl sm:text-4xl font-black mb-2">I'm into</h1>
              <p className="text-grey-text font-medium mb-8 sm:mb-12 text-sm sm:text-base">Select at least one interest.</p>
              
              <div className="grid grid-cols-2 gap-2.5 sm:gap-3">
                {Object.entries(INTEREST_MAP).map(([key, item]) => {
                  const isSelected = formData.interests.includes(key);
                  return (
                    <button
                      key={key}
                      onClick={() => toggleInterest(key)}
                      className={`flex flex-col items-center justify-center p-4 sm:p-6 rounded-2xl border-2 transition-all gap-2 sm:gap-3 ${
                        isSelected 
                          ? 'border-primary bg-primary/10 text-white' 
                          : 'border-white/5 bg-secondary/30 text-grey-text hover:border-white/20'
                      }`}
                    >
                      <div className={`${isSelected ? 'text-primary' : 'text-grey-text'}`}>
                        {item.icon}
                      </div>
                      <span className="font-bold text-sm sm:text-base">{item.label}</span>
                    </button>
                  );
                })}
              </div>
            </motion.div>
          )}

          {step === 5 && (
            <motion.div 
              key="step5"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="flex-1 flex flex-col"
            >
              <h1 className="text-3xl sm:text-4xl font-black mb-2">About me</h1>
              <p className="text-grey-text font-medium mb-8 sm:mb-12 text-sm sm:text-base">Write a short bio to introduce yourself.</p>
              
              <div className="relative flex-1">
                <textarea 
                  autoFocus
                  placeholder="Tell us something interesting..."
                  className="w-full h-40 sm:h-48 bg-secondary/30 rounded-3xl p-5 sm:p-6 text-lg sm:text-xl font-bold outline-none border-2 border-white/5 focus:border-primary/50 transition-all resize-none placeholder:text-white/10"
                  value={formData.bio}
                  onChange={e => setFormData({...formData, bio: e.target.value})}
                />
                <div className="absolute bottom-5 right-5 text-[10px] sm:text-xs font-bold text-grey-text uppercase tracking-widest">
                  {formData.bio.length} / 500
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        <button 
          disabled={!isStepValid() || loading}
          onClick={nextStep}
          className="mt-auto w-full bg-primary disabled:opacity-50 disabled:grayscale py-5 rounded-full text-black font-black text-lg shadow-xl shadow-primary/20 flex items-center justify-center gap-2 group transition-all"
        >
          {loading ? (
            <div className="w-6 h-6 border-2 border-black border-t-transparent rounded-full animate-spin" />
          ) : (
            <>
              {step === totalSteps ? 'Complete' : 'Continue'}
              <ArrowRight className="w-6 h-6 group-hover:translate-x-1 transition-transform" />
            </>
          )}
        </button>
      </div>
    </div>
  );
}
