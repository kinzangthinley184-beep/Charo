import { Settings, MapPin, Edit3, Check, X, Ruler, GraduationCap, Wine, Cigarette, Briefcase, Camera, User as UserIcon, HelpCircle, CheckCircle2, Share2, Sparkles, ChevronRight, ChevronDown, Grid, Music, Plane, Coffee, Gamepad, Film, Palette, Plus, ShieldAlert, Languages, Home, Heart, Globe, Users, Star } from 'lucide-react';
import { motion, AnimatePresence, Reorder } from 'motion/react';
import React, { useState, useRef, useEffect } from 'react';
import { Profile } from '../types';

const getZodiacIcon = (sign: string) => {
  const signs: Record<string, string> = {
    Aries: '♈',
    Taurus: '♉',
    Gemini: '♊',
    Cancer: '♋',
    Leo: '♌',
    Virgo: '♍',
    Libra: '♎',
    Scorpio: '♏',
    Sagittarius: '♐',
    Capricorn: '♑',
    Aquarius: '♒',
    Pisces: '♓'
  };
  return signs[sign] || '🌙';
};

const INITIAL_USER_DATA: ExtendedUserData = {
  id: 'me',
  nickname: 'alex_rvr',
  name: 'Alex Rivera',
  age: 25,
  gender: 'Non-binary',
  location: 'Manhattan, NY',
  imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1000&auto=format&fit=crop',
  bio: 'Just a creative soul traveling the world. ✨\nLover of high-quality coffee and jazz music.',
  zodiacSign: '',
  bhutaneseZodiac: 'Tiger',
  height: "5'10\"",
  education: 'NYU',
  occupation: '',
  hometown: 'San Francisco, CA',
  religion: 'Spiritual',
  ethnicity: 'Mixed',
  languages: ['English', 'Spanish'],
  drinkingHabit: 'Socially',
  smokingHabit: 'Never',
  lookingFor: 'Long-term relationship',
  verified: true,
  profileCompletion: 85,
  latitude: 40.7128,
  longitude: -74.0060,
  matchPercentage: 0,
  photos: [
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=400&auto=format',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=400&auto=format',
    'https://images.unsplash.com/photo-1488161628813-04466f872be2?q=80&w=400&auto=format',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=400&auto=format'
  ],
  interests: ['music', 'travel'],
  shareLocation: false
};

const HEIGHT_OPTIONS = Array.from({ length: 101 }, (_, i) => 130 + i);

const HeightPicker = ({ value, onChange, onDismiss }: { value: string, onChange: (val: string) => void, onDismiss: () => void }) => {
  const currentVal = parseInt(value) || 170;
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = document.getElementById(`height-${currentVal}`);
    if (element && scrollRef.current) {
      scrollRef.current.scrollTop = element.offsetTop - scrollRef.current.offsetHeight / 2 + element.offsetHeight / 2;
    }
  }, []);

  return (
    <div className="fixed inset-0 z-[60] bg-black/60 backdrop-blur-md flex items-end justify-center">
      <motion.div 
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        className="bg-app-bg w-full rounded-t-[40px] p-8 pb-12 border-t border-white/10 shadow-2xl"
      >
        <div className="flex justify-between items-center mb-8">
           <h3 className="text-lg font-black uppercase tracking-widest italic">Height</h3>
           <button onClick={onDismiss} className="text-sm font-bold text-white/50 hover:text-white uppercase tracking-widest">Done</button>
        </div>
        
        <div className="relative h-64 overflow-hidden">
          {/* Centering overlay */}
          <div className="absolute inset-0 pointer-events-none z-10 flex flex-col justify-center">
            <div className="h-14 border-y border-white/10 bg-white/5" />
          </div>
          
          <div 
            ref={scrollRef}
            className="h-full overflow-y-auto no-scrollbar snap-y snap-mandatory py-24"
            onScroll={(e) => {
              const target = e.currentTarget;
              const center = target.scrollTop + target.offsetHeight / 2;
              const items = target.getElementsByTagName('button');
              let closest = items[0];
              let minDiff = Math.abs(items[0].offsetTop + items[0].offsetHeight / 2 - center);
              
              for (let i = 1; i < items.length; i++) {
                const diff = Math.abs(items[i].offsetTop + items[i].offsetHeight / 2 - center);
                if (diff < minDiff) {
                  minDiff = diff;
                  closest = items[i];
                }
              }
              
              const newVal = closest.getAttribute('data-value');
              if (newVal && newVal !== value) {
                onChange(`${newVal} cm`);
              }
            }}
          >
            {HEIGHT_OPTIONS.map((h) => (
              <button
                key={h}
                id={`height-${h}`}
                data-value={h}
                onClick={() => onChange(`${h} cm`)}
                className={`w-full py-4 text-3xl font-black transition-all snap-center flex items-center justify-center gap-2 ${
                  value.includes(h.toString()) ? 'text-white opacity-100' : 'text-white/20 opacity-50 scale-75'
                }`}
              >
                {h} <span className="text-xs uppercase tracking-widest opacity-40">cm</span>
              </button>
            ))}
          </div>
        </div>
        
        <button 
          onClick={onDismiss}
          className="w-full mt-8 bg-white text-black py-4 rounded-[20px] font-black text-xs uppercase tracking-[0.3em] shadow-xl"
        >
          Confirm
        </button>
      </motion.div>
    </div>
  );
};

interface ExtendedUserData extends Profile {
  nickname: string;
}

const INTEREST_MAP: Record<string, { icon: React.ReactNode, label: string }> = {
  music: { icon: <Music className="w-4 h-4" />, label: 'Music' },
  travel: { icon: <Plane className="w-4 h-4" />, label: 'Travel' },
  coffee: { icon: <Coffee className="w-4 h-4" />, label: 'Coffee' },
  gaming: { icon: <Gamepad className="w-4 h-4" />, label: 'Gaming' },
  movies: { icon: <Film className="w-4 h-4" />, label: 'Movies' },
  photography: { icon: <Camera className="w-4 h-4" />, label: 'Photography' },
  art: { icon: <Palette className="w-4 h-4" />, label: 'Art' },
};

const EditPill = ({ icon, label, value, options, onChange, type = 'select' }: any) => {
  const isSelected = !!value;
  return (
    <div className={`relative flex items-center gap-1.5 px-4 py-2 rounded-full border transition-all ${isSelected ? 'bg-primary text-black border-primary shadow-sm' : 'bg-transparent border-white/20 text-white'}`}>
      <span className={isSelected ? 'text-black' : 'text-grey-text'}>{icon}</span>
      {type === 'select' ? (
        <>
          <span className="text-sm font-semibold">{value || label}</span>
          <select 
             value={value}
             onChange={onChange}
             className="absolute inset-0 opacity-0 cursor-pointer w-full h-full"
          >
             <option value="" disabled>{label}</option>
             {options.map((o: string) => <option key={o} value={o} className="bg-app-bg text-white">{o}</option>)}
          </select>
        </>
      ) : (
        <input 
          type="text"
          value={value}
          onChange={onChange}
          placeholder={label}
          className="bg-transparent outline-none w-16 text-sm font-semibold placeholder:text-grey-text text-inherit"
        />
      )}
    </div>
  );
};

export function UserProfile({ onLogout }: { onLogout?: () => void }) {
  const [isEditing, setIsEditing] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [showHeightPicker, setShowHeightPicker] = useState(false);
  const [showReportConfirm, setShowReportConfirm] = useState(false);
  const [showBlockConfirm, setShowBlockConfirm] = useState(false);
  const [reportSuccess, setReportSuccess] = useState(false);
  const [blockSuccess, setBlockSuccess] = useState(false);
  const [isBasicsExpanded, setIsBasicsExpanded] = useState(true);
  const [isMoreAboutMeExpanded, setIsMoreAboutMeExpanded] = useState(true);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [userData, setUserData] = useState<ExtendedUserData>(INITIAL_USER_DATA as ExtendedUserData);
  const [editedData, setEditedData] = useState<ExtendedUserData>(INITIAL_USER_DATA as ExtendedUserData);
  const [draggedIdx, setDraggedIdx] = useState<number | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const fetchUserData = async () => {
    setLoading(true);
    try {
      const data = { ...INITIAL_USER_DATA } as ExtendedUserData;
      setUserData(data);
      setEditedData(data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUserData();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    try {
      setUserData(editedData);
      setIsEditing(false);
    } catch (error) {
      console.error(error);
    } finally {
      setSaving(false);
    }
  };

  const handleLogout = async () => {
    try {
      if (onLogout) onLogout();
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const [targetPhotoIndex, setTargetPhotoIndex] = useState<number | null>(null);
  const [isChangingAvatar, setIsChangingAvatar] = useState(false);

  const triggerUpload = (index: number | null = null, isAvatar = false) => {
    setTargetPhotoIndex(index);
    setIsChangingAvatar(isAvatar);
    fileInputRef.current?.click();
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files ?? []) as File[];
    if (!files.length) return;

    if (isChangingAvatar) {
      const file = files[0];
      const reader = new FileReader();
      reader.onloadend = () => {
        setEditedData(prev => ({ ...prev, imageUrl: reader.result as string }));
      };
      reader.readAsDataURL(file);
    } else {
      const readFilesAsDataURLs = files.map(file => {
        return new Promise<string>((resolve) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result as string);
          reader.readAsDataURL(file);
        });
      });

      const dataUrls = await Promise.all(readFilesAsDataURLs);
      
      setEditedData(prev => {
        const newPhotos = [...prev.photos];
        if (targetPhotoIndex !== null && targetPhotoIndex < newPhotos.length) {
          newPhotos[targetPhotoIndex] = dataUrls[0];
          newPhotos.push(...dataUrls.slice(1));
        } else {
          newPhotos.push(...dataUrls);
        }
        return { ...prev, photos: newPhotos.slice(0, 6) };
      });
    }

    setTargetPhotoIndex(null);
    setIsChangingAvatar(false);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleDragStart = (e: React.DragEvent<HTMLDivElement>, index: number) => {
    setDraggedIdx(index);
    e.dataTransfer.effectAllowed = 'move';
    const target = e.currentTarget;
    setTimeout(() => {
      target.style.opacity = '0.4';
    }, 0);
  };

  const handleDragEnd = (e: React.DragEvent<HTMLDivElement>) => {
    setDraggedIdx(null);
    e.currentTarget.style.opacity = '1';
  };

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>, index: number) => {
    e.preventDefault();
    if (draggedIdx === null || draggedIdx === index) return;
    
    setEditedData(prev => {
      const newPhotos = [...prev.photos];
      const draggedPhoto = newPhotos[draggedIdx];
      newPhotos.splice(draggedIdx, 1);
      newPhotos.splice(index, 0, draggedPhoto);
      return { ...prev, photos: newPhotos };
    });
    setDraggedIdx(index);
  };

  const handleCancel = () => {
    setEditedData(userData);
    setIsEditing(false);
  };

  return (
    <div className="flex flex-col min-h-full bg-app-bg text-white pb-32">
      {/* Header */}
      <div className="flex items-center justify-end p-6 pb-2">
        <div className="flex gap-3">
        </div>
      </div>

      <div className="px-6 flex flex-col pt-1">
        {/* Profile Card Header */}
        <div className="bg-secondary/40 border border-white/5 rounded-[32px] py-4 px-6 mb-6 shadow-2xl relative group">
          <div className="absolute top-4 right-6 z-10">
            <button 
               onClick={() => { console.log('Settings clicked'); setShowSettings(true); }}
               className="w-10 h-10 glass-morphism rounded-xl flex items-center justify-center text-white/50 hover:text-white transition-all active:scale-95"
            >
              <Settings className="w-5 h-5" />
            </button>
          </div>
          <div className="relative flex flex-col items-center sm:items-start sm:flex-row gap-4">
            <div className="w-24 h-24 rounded-full p-[2px] border-[2px] border-white/20 shadow-2xl flex-shrink-0">
               <img 
                 src={userData.imageUrl} 
                 alt={userData.name} 
                 className="w-full h-full object-cover rounded-full"
               />
            </div>
            
            <div className="flex flex-col justify-center text-center sm:text-left">
              <div className="flex items-center justify-center sm:justify-start gap-2 mb-1">
                <h2 className="text-2xl font-black tracking-tighter">{userData.name}, {userData.age}</h2>
                {userData.verified && <CheckCircle2 className="w-4 h-4 text-white fill-white" color="#000" />}
              </div>
              
              <div className="flex items-center justify-center sm:justify-start gap-2 text-white/40 font-bold uppercase tracking-widest text-[9px]">
                <MapPin className="w-3 h-3" />
                <span>{userData.location.toUpperCase()}</span>
              </div>
            </div>
          </div>
        </div>

        
        {/* Details Grid (Bento Style) */}
        <div className="grid grid-cols-2 gap-3 mb-6">
          {userData.zodiacSign && (
            <div className="glass-morphism rounded-[24px] py-3 px-4 flex flex-col justify-center gap-1.5">
              <Star className="w-4 h-4 text-white/30" />
              <div>
                <p className="text-[8px] font-black text-white/20 uppercase tracking-widest">Zodiac</p>
                <p className="text-sm font-bold text-white/80">{userData.zodiacSign}</p>
              </div>
            </div>
          )}
          {userData.lookingFor && (
            <div className="glass-morphism rounded-[24px] py-3 px-4 flex flex-col justify-center gap-1.5 border-white/20">
              <Heart className="w-4 h-4 text-white/60" />
              <div>
                <p className="text-[8px] font-black text-white/20 uppercase tracking-widest">Intent</p>
                <p className="text-sm font-bold text-white/80">{userData.lookingFor}</p>
              </div>
            </div>
          )}
        </div>

        <div className="mb-8">
          <h3 className="text-[9px] font-black uppercase tracking-[0.3em] text-white/20 mb-4 px-2">Resonance</h3>
          <div className="flex flex-wrap gap-2 px-1">
            {userData.interests?.map((interestKey: string) => {
              const interest = INTEREST_MAP[interestKey];
              if (!interest) return null;
              return (
                <div key={interestKey} className="flex items-center gap-2 px-4 py-2.5 bg-secondary/50 rounded-full border border-white/5 text-[10px] font-bold text-white/70 hover:text-white hover:bg-white/10 transition-all cursor-default">
                  <span className="text-white/40">{interest.icon}</span>
                  {interest.label.toUpperCase()}
                </div>
              );
            })}
          </div>
        </div>
        
        <button 
          onClick={() => setIsEditing(true)}
          className="w-full bg-white text-black py-4 rounded-[20px] font-black text-[10px] uppercase tracking-[0.3em] shadow-2xl hover:scale-[1.01] transition-transform active:scale-95 mb-8"
        >
          Refine Identity
        </button>
      </div>

      {/* Visual Narrative Grid */}
      <div className="px-4 grid grid-cols-6 gap-3">
        {userData.photos.map((photo, i) => {
          let layoutClass = 'col-span-3 aspect-[4/5]';
          if (i === 0) layoutClass = 'col-span-6 aspect-[4/3]';
          else if (i === 3) layoutClass = 'col-span-6 aspect-video';
          
          return (
            <motion.div 
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              className={`bg-secondary overflow-hidden rounded-[32px] shadow-2xl border border-white/5 relative group ${layoutClass}`}
            >
              <img 
                src={photo} 
                alt={`Fragment ${i}`} 
                className="w-full h-full object-cover transition-all duration-1000 scale-105 group-hover:scale-110 grayscale-[50%] group-hover:grayscale-0" 
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            </motion.div>
          );
        })}
      </div>

      <AnimatePresence>
        {isEditing && (
          <motion.div 
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed inset-0 z-50 bg-app-bg flex flex-col h-full overflow-hidden"
          >
            <header className="flex items-center justify-between p-4 px-6 border-b border-white/5 bg-app-bg/90 backdrop-blur-md z-10 sticky top-0">
              <button onClick={handleCancel} className="text-grey-text font-semibold p-2 -ml-2">Cancel</button>
              <h1 className="font-bold text-lg text-white">Edit Profile</h1>
              <button onClick={handleSave} className="text-white font-bold p-2 -mr-2">Done</button>
            </header>

            <div className="flex-1 overflow-y-auto pb-32">
              {/* Profile Image Edit */}
              <section className="p-6 flex flex-col items-center">
                <div className="relative group cursor-pointer" onClick={() => triggerUpload(null, true)}>
                  <div className="w-32 h-32 rounded-full p-[3px] border-[3px] border-white overflow-hidden relative">
                    <img 
                      src={editedData.imageUrl} 
                      className="w-full h-full object-cover rounded-full" 
                      alt="Avatar" 
                    />
                    <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                      <Camera className="w-8 h-8 text-white" />
                    </div>
                  </div>
                  <div className="absolute bottom-1 right-1 bg-white text-black p-2 rounded-full border-2 border-app-bg shadow-lg">
                    <Camera className="w-4 h-4" />
                  </div>
                </div>
                <p className="text-[10px] uppercase tracking-widest font-bold text-grey-text mt-3">Change Profile Photo</p>
              </section>

              <section className="px-4 py-2 grid grid-cols-3 gap-3">
                 <input 
                   type="file" 
                   accept="image/*" 
                   multiple={!isChangingAvatar}
                   ref={fileInputRef} 
                   onChange={handleFileChange} 
                   className="hidden" 
                 />
                 {editedData.photos.map((photo: string, i: number) => (
                    <motion.div 
                      layout
                      draggable
                      onDragStart={(e) => handleDragStart(e, i)}
                      onDragEnd={handleDragEnd}
                      onDragOver={(e) => handleDragOver(e, i)}
                      key={photo} 
                      onClick={() => triggerUpload(i)}
                      className="aspect-[3/4] rounded-xl overflow-hidden relative group cursor-grab active:cursor-grabbing"
                    >
                      <img src={photo} className="w-full h-full object-cover pointer-events-none" draggable={false} alt="" />
                      <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors pointer-events-none" />
                      
                      <button 
                        onPointerDown={(e) => e.stopPropagation()}
                        onClick={(e) => {
                          e.stopPropagation();
                          const newPhotos = [...editedData.photos];
                          newPhotos.splice(i, 1);
                          setEditedData(prev => ({...prev, photos: newPhotos}));
                        }} 
                        className="absolute bottom-2 right-2 w-7 h-7 bg-black/40 backdrop-blur-md rounded-full flex items-center justify-center border border-white/20 text-white hover:bg-black/60 transition-colors z-10"
                      >
                        <X className="w-4 h-4" />
                      </button>
                      
                      {i === 0 && (
                         <div className="absolute top-2 left-2 px-2 py-0.5 bg-white text-black text-[10px] font-bold rounded-sm tracking-widest uppercase pointer-events-none">
                           Best
                         </div>
                      )}
                      <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 pointer-events-none">
                         <Edit3 className="w-6 h-6 text-white drop-shadow-lg" />
                      </div>
                    </motion.div>
                 ))}
                 
                 {Array.from({ length: Math.max(0, 6 - editedData.photos.length) }).map((_, i) => (
                    <button 
                      key={`empty-${i}`} 
                      onClick={() => triggerUpload()} 
                      className="aspect-[3/4] rounded-xl border-2 border-dashed border-white/20 bg-secondary/30 flex items-center justify-center text-white/50 cursor-pointer hover:border-primary hover:bg-primary/5 transition-all w-full h-full"
                    >
                      <Plus className="w-6 h-6" />
                    </button>
                 ))}
              </section>

              <section className="p-4 pt-2">
                 <h3 className="text-xs font-bold text-grey-text uppercase tracking-wider mb-2">About Me</h3>
                 <div className="bg-secondary/40 border border-white/5 rounded-xl p-3 relative focus-within:border-white/50 transition-colors">
                    <textarea
                       value={editedData.bio}
                       onChange={(e) => setEditedData({...editedData, bio: e.target.value})}
                       className="w-full bg-transparent text-white outline-none min-h-[100px] resize-none text-sm placeholder:text-grey-text/50 font-medium"
                       placeholder="Write something fun about yourself..."
                       maxLength={300}
                    />
                    <div className="text-right text-[10px] text-grey-text font-semibold absolute bottom-3 right-3">
                      {300 - editedData.bio.length} characters left
                    </div>
                 </div>
              </section>

              <section className="p-4">
                  <h3 className="text-xs font-bold text-grey-text uppercase tracking-wider mb-3 px-1">Interests</h3>
                  <div className="bg-secondary/40 border border-white/5 rounded-xl p-4">
                    <div className="flex flex-wrap gap-2 mb-4">
                      {editedData.interests?.map((interestKey: string) => {
                        const interest = INTEREST_MAP[interestKey];
                        if (!interest) return null;
                        return (
                          <div key={interestKey} className="flex items-center gap-2 px-3 py-1.5 bg-white text-black rounded-full text-xs font-bold shadow-lg animate-in zoom-in-95">
                            {interest.icon}
                            {interest.label}
                            <button 
                              onClick={() => {
                                const newInterests = editedData.interests.filter((k: string) => k !== interestKey);
                                setEditedData({...editedData, interests: newInterests});
                              }}
                              className="ml-1 hover:text-black/70 transition-colors"
                            >
                              <X className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        );
                      })}
                      {(!editedData.interests || editedData.interests.length === 0) && (
                        <p className="text-grey-text text-sm italic font-medium px-1">No interests added yet...</p>
                      )}
                    </div>
                    
                    <div className="pt-4 border-t border-white/5">
                      <p className="text-[10px] font-bold text-grey-text uppercase tracking-widest mb-3 px-1">Suggested</p>
                      <div className="flex flex-wrap gap-2">
                        {Object.entries(INTEREST_MAP).map(([key, interest]) => {
                          const isSelected = editedData.interests?.includes(key);
                          if (isSelected) return null;
                          return (
                            <button
                              key={key}
                              onClick={() => {
                                const newInterests = [...(editedData.interests || []), key];
                                setEditedData({...editedData, interests: newInterests});
                              }}
                              className="flex items-center gap-2 px-3 py-1.5 bg-secondary/30 hover:bg-secondary/60 rounded-full border border-white/5 text-xs font-bold text-white transition-all active:scale-95"
                            >
                              <Plus className="w-3.5 h-3.5 text-white" />
                              {interest.label}
                            </button>
                          );
                        })}
                      </div>
                    </div>
                  </div>
               </section>

              <section className="p-4">
                 <button 
                   onClick={() => setIsBasicsExpanded(!isBasicsExpanded)}
                   className="w-full flex items-center justify-between mb-2 text-xs font-bold text-grey-text uppercase tracking-wider group"
                 >
                   My Basics
                   <ChevronDown className={`w-4 h-4 transition-transform duration-300 ${isBasicsExpanded ? 'rotate-180' : ''}`} />
                 </button>
                 <AnimatePresence initial={false}>
                   {isBasicsExpanded && (
                     <motion.div
                       initial={{ height: 0, opacity: 0 }}
                       animate={{ height: 'auto', opacity: 1 }}
                       exit={{ height: 0, opacity: 0 }}
                       transition={{ duration: 0.3, ease: 'easeInOut' }}
                       className="overflow-hidden"
                     >
                       <div className="bg-secondary/40 border border-white/5 rounded-xl flex flex-col overflow-hidden mt-1">
                          <div className="flex items-center px-4 py-3.5 border-b border-white/5 bg-secondary/20">
                             <UserIcon className="w-5 h-5 text-grey-text mr-3" />
                             <span className="text-sm text-white font-medium w-24">Full Name</span>
                             <input type="text" value={editedData.name} onChange={e => setEditedData({...editedData, name: e.target.value})} className="flex-1 bg-transparent text-right text-sm text-grey-text font-semibold outline-none placeholder:text-grey-text/50" placeholder="Your name" />
                          </div>
                          <div className="flex items-center px-4 py-3.5 border-b border-white/5 bg-secondary/20">
                             <Grid className="w-5 h-5 text-grey-text mr-3" />
                             <span className="text-sm text-white font-medium w-24">Age</span>
                             <input type="number" value={editedData.age} onChange={e => setEditedData({...editedData, age: parseInt(e.target.value) || 0})} className="flex-1 bg-transparent text-right text-sm text-grey-text font-semibold outline-none placeholder:text-grey-text/50" placeholder="Your age" />
                          </div>
                          <div className="flex items-center px-4 py-3.5 border-b border-white/5 bg-secondary/20">
                             <UserIcon className="w-5 h-5 text-grey-text mr-3" />
                             <span className="text-sm text-white font-medium w-24">Gender</span>
                             <select value={editedData.gender} onChange={e => setEditedData({...editedData, gender: e.target.value})} className="flex-1 bg-transparent text-right text-sm text-grey-text font-semibold outline-none appearance-none cursor-pointer">
                                <option value="Man" className="bg-app-bg">Man</option>
                                <option value="Woman" className="bg-app-bg">Woman</option>
                                <option value="Non-binary" className="bg-app-bg">Non-binary</option>
                             </select>
                          </div>
                          <div className="flex items-center px-4 py-3.5 border-b border-white/5 bg-secondary/20">
                             <Briefcase className="w-5 h-5 text-grey-text mr-3" />
                             <span className="text-sm text-white font-medium w-24">Occupation</span>
                             <input type="text" value={editedData.occupation} onChange={e => setEditedData({...editedData, occupation: e.target.value})} className="flex-1 bg-transparent text-right text-sm text-grey-text font-semibold outline-none placeholder:text-grey-text/50" placeholder="Add job" />
                          </div>
                          <div className="flex items-center px-4 py-3.5 border-b border-white/5 bg-secondary/20">
                             <GraduationCap className="w-5 h-5 text-grey-text mr-3" />
                             <span className="text-sm text-white font-medium w-24">Education</span>
                             <input type="text" value={editedData.education} onChange={e => setEditedData({...editedData, education: e.target.value})} className="flex-1 bg-transparent text-right text-sm text-grey-text font-semibold outline-none placeholder:text-grey-text/50" placeholder="Add school" />
                          </div>
                          <div className="flex items-center px-4 py-3.5 border-b border-white/5 bg-secondary/20">
                             <Home className="w-5 h-5 text-grey-text mr-3" />
                             <span className="text-sm text-white font-medium w-24">Hometown</span>
                             <input type="text" value={editedData.hometown} onChange={e => setEditedData({...editedData, hometown: e.target.value})} className="flex-1 bg-transparent text-right text-sm text-grey-text font-semibold outline-none placeholder:text-grey-text/50" placeholder="Add hometown" />
                          </div>
                          <div className="flex items-center px-4 py-3.5 bg-secondary/20">
                             <UserIcon className="w-5 h-5 text-grey-text mr-3" />
                             <span className="text-sm text-white font-medium w-24">Nickname</span>
                             <input type="text" value={editedData.nickname} onChange={e => setEditedData({...editedData, nickname: e.target.value})} className="flex-1 bg-transparent text-right text-sm text-grey-text font-semibold outline-none placeholder:text-grey-text/50" placeholder="Nickname" />
                          </div>
                       </div>
                     </motion.div>
                   )}
                 </AnimatePresence>
              </section>

              <section className="p-4">
                 <button 
                   onClick={() => setIsMoreAboutMeExpanded(!isMoreAboutMeExpanded)}
                   className="w-full flex items-center justify-between mb-2 text-xs font-bold text-grey-text uppercase tracking-wider group"
                 >
                   More About Me
                   <ChevronDown className={`w-4 h-4 transition-transform duration-300 ${isMoreAboutMeExpanded ? 'rotate-180' : ''}`} />
                 </button>
                 <AnimatePresence initial={false}>
                   {isMoreAboutMeExpanded && (
                     <motion.div
                       initial={{ height: 0, opacity: 0 }}
                       animate={{ height: 'auto', opacity: 1 }}
                       exit={{ height: 0, opacity: 0 }}
                       transition={{ duration: 0.3, ease: 'easeInOut' }}
                       className="overflow-hidden"
                     >
                        <div className="flex flex-wrap gap-2.5 mt-1 pb-1">
                            <button 
                              onClick={() => setShowHeightPicker(true)}
                              className={`relative flex items-center gap-1.5 px-4 py-2 rounded-full border transition-all ${editedData.height ? 'bg-primary text-black border-primary shadow-sm' : 'bg-transparent border-white/20 text-white'}`}
                            >
                              <Ruler className={`w-4 h-4 ${editedData.height ? 'text-black' : 'text-grey-text'}`} />
                              <span className="text-sm font-semibold">{editedData.height || 'Height'}</span>
                            </button>
                           <EditPill 
                             icon={<Wine className="w-4 h-4" />} 
                             label="Drinking" 
                             value={editedData.drinkingHabit} 
                             options={['Socially', 'Never', 'Frequently']}
                             onChange={(e: any) => setEditedData({...editedData, drinkingHabit: e.target.value})}
                           />
                           <EditPill 
                             icon={<Cigarette className="w-4 h-4" />} 
                             label="Smoking" 
                             value={editedData.smokingHabit} 
                             options={['Socially', 'Never', 'Regularly']}
                             onChange={(e: any) => setEditedData({...editedData, smokingHabit: e.target.value})}
                           />
                           <EditPill 
                             icon={<Heart className="w-4 h-4" />} 
                             label="Looking For" 
                             value={editedData.lookingFor} 
                             options={['Commitment', 'Long-term relationship', 'Short-term relationship', 'Casual', 'New friends']}
                             onChange={(e: any) => setEditedData({...editedData, lookingFor: e.target.value})}
                           />
                           <EditPill 
                             icon={<span className="text-base leading-none mb-[2px]">{getZodiacIcon(editedData.zodiacSign)}</span>} 
                             label="Zodiac" 
                             value={editedData.zodiacSign} 
                             options={['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces']}
                             onChange={(e: any) => setEditedData({...editedData, zodiacSign: e.target.value})}
                           />
                           <EditPill 
                             icon={<Star className="w-4 h-4" />} 
                             label="Bhutanese Zodiac" 
                             value={editedData.bhutaneseZodiac} 
                             options={['Rat', 'Ox', 'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Sheep', 'Monkey', 'Bird', 'Dog', 'Pig']}
                             onChange={(e: any) => setEditedData({...editedData, bhutaneseZodiac: e.target.value})}
                           />
                           <EditPill 
                             icon={<HelpCircle className="w-4 h-4" />} 
                             label="Religion" 
                             value={editedData.religion} 
                             options={['Buddhism', 'Hinduism', 'Christianity', 'Islam', 'Spiritual', 'Atheist', 'Other']}
                             onChange={(e: any) => setEditedData({...editedData, religion: e.target.value})}
                           />
                           <EditPill 
                             icon={<Users className="w-4 h-4" />} 
                             label="Ethnicity" 
                             value={editedData.ethnicity} 
                             type="input"
                             onChange={(e: any) => setEditedData({...editedData, ethnicity: e.target.value})}
                           />
                           <div className="relative flex items-center gap-1.5 px-4 py-2 rounded-full border bg-transparent border-white/20 text-white min-w-[200px]">
                             <Languages className="w-4 h-4 text-grey-text" />
                             <input 
                               type="text" 
                               value={editedData.languages.join(', ')} 
                               onChange={(e) => setEditedData({...editedData, languages: e.target.value.split(',').map(s => s.trim()).filter(s => s)})}
                               placeholder="Languages (comma separated)"
                               className="bg-transparent outline-none flex-1 text-sm font-semibold placeholder:text-grey-text"
                             />
                           </div>
                           <div className="w-full flex items-center justify-between px-4 py-2 bg-secondary/20 rounded-xl mt-2 border border-white/5">
                             <div className="flex items-start gap-3">
                               <MapPin className="w-4 h-4 text-white mt-0.5" />
                               <div className="flex flex-col text-left">
                                 <span className="text-xs font-bold text-grey-text uppercase tracking-widest">Live Location</span>
                                 <span className="text-[10px] text-grey-text/70 mt-0.5">Share live distance with matches</span>
                               </div>
                             </div>
                             <button 
                               onClick={() => {
                                 const newVal = !editedData.shareLocation;
                                 setEditedData({...editedData, shareLocation: newVal});
                                 if (newVal && navigator.geolocation) {
                                   navigator.geolocation.getCurrentPosition(
                                     pos => setEditedData(prev => ({ 
                                       ...prev, 
                                       shareLocation: true, 
                                       latitude: pos.coords.latitude, 
                                       longitude: pos.coords.longitude 
                                     })),
                                     () => setEditedData(prev => ({ ...prev, shareLocation: false }))
                                   );
                                 }
                               }}
                               className={`w-10 h-5 rounded-full transition-colors relative flex-shrink-0 ${editedData.shareLocation ? 'bg-primary' : 'bg-grey-text/30'}`}
                             >
                               <div className={`absolute top-0.5 w-4 h-4 ${editedData.shareLocation ? 'bg-black' : 'bg-white'} rounded-full transition-all ${editedData.shareLocation ? 'left-5' : 'left-1'}`} />
                             </button>
                           </div>
                           <div className="w-full flex items-center justify-between px-4 py-2 bg-secondary/20 rounded-xl mt-2 border border-white/5">
                             <div className="flex items-center gap-2">
                               <CheckCircle2 className="w-4 h-4 text-white" />
                               <span className="text-xs font-bold text-grey-text uppercase tracking-widest">Verified Profile</span>
                             </div>
                             <button 
                               onClick={() => setEditedData({...editedData, verified: !editedData.verified})}
                               className={`w-10 h-5 rounded-full transition-colors relative ${editedData.verified ? 'bg-white' : 'bg-grey-text/30'}`}
                             >
                               <div className={`absolute top-0.5 w-4 h-4 ${editedData.verified ? 'bg-black' : 'bg-white'} rounded-full transition-all ${editedData.verified ? 'left-5' : 'left-1'}`} />
                             </button>
                           </div>
                           <div className="w-full mt-2 px-1">
                             <div className="flex justify-between items-center mb-1.5">
                               <span className="text-[10px] font-bold text-grey-text uppercase tracking-widest">Profile Completion</span>
                               <span className="text-[10px] font-bold text-white">{editedData.profileCompletion}%</span>
                             </div>
                             <div className="w-full h-1 bg-white/10 rounded-full overflow-hidden">
                               <div className="h-full bg-white" style={{ width: `${editedData.profileCompletion}%` }} />
                             </div>
                           </div>
                        </div>
                     </motion.div>
                   )}
                 </AnimatePresence>
              </section>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {showHeightPicker && (
          <HeightPicker 
            value={editedData.height} 
            onChange={(val) => setEditedData(prev => ({ ...prev, height: val }))} 
            onDismiss={() => setShowHeightPicker(false)} 
          />
        )}
      </AnimatePresence>

      <AnimatePresence>
        {showSettings && (
          <motion.div 
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="fixed inset-0 z-50 bg-app-bg flex flex-col h-full overflow-hidden"
          >
            <header className="flex items-center justify-between p-4 px-6 border-b border-white/5 bg-app-bg/90 backdrop-blur-md z-10 sticky top-0">
              <div className="w-16"></div>
              <h1 className="font-bold text-lg text-white">Settings</h1>
              <button onClick={() => setShowSettings(false)} className="text-primary font-bold p-2 -mr-2 w-16 text-right">Done</button>
            </header>

            <div className="flex-1 overflow-y-auto p-4 pt-6 flex flex-col gap-4">
              <section className="flex flex-col gap-3">
                <div className="bg-secondary/40 border border-white/5 rounded-xl overflow-hidden flex flex-col">
                  <button 
                    onClick={() => setShowReportConfirm(true)} 
                    className="flex items-center gap-3 px-6 py-4 text-white font-semibold hover:bg-white/5 transition-colors border-b border-white/5"
                  >
                    <ShieldAlert className="w-5 h-5 text-white/50" />
                    <span>Report User</span>
                  </button>
                  <button 
                    onClick={() => setShowBlockConfirm(true)} 
                    className="flex items-center gap-3 px-6 py-4 text-white font-semibold hover:bg-white/5 transition-colors border-b border-white/5"
                  >
                    <X className="w-5 h-5 text-white/50" />
                    <span>Block User</span>
                  </button>
                  <button onClick={handleLogout} className="flex items-center justify-center p-4 text-white/40 font-bold hover:bg-white/5 disabled:opacity-50 transition-colors">
                    Log out
                  </button>
                </div>
                <p className="px-4 mt-2 text-center text-[10px] text-grey-text uppercase tracking-widest font-bold">
                  Version 1.0.0
                </p>
              </section>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Report/Block Modals */}
      <AnimatePresence>
        {showBlockConfirm && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] bg-black/80 backdrop-blur-sm flex items-center justify-center p-6"
          >
            <motion.div 
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              className="bg-secondary w-full max-w-sm rounded-[32px] overflow-hidden border border-white/10 shadow-2xl"
            >
              {!blockSuccess ? (
                <div className="p-8 text-center">
                  <div className="w-16 h-16 bg-white/5 rounded-full flex items-center justify-center mx-auto mb-6">
                    <X className="w-8 h-8 text-white/60" />
                  </div>
                  <h2 className="text-xl font-bold text-white mb-2">Block this user?</h2>
                  <p className="text-grey-text text-sm mb-8 leading-relaxed">
                    You won't be able to see their profile or messages, and they won't be able to contact you.
                  </p>
                  <div className="flex flex-col gap-3">
                    <button 
                      onClick={() => {
                        setBlockSuccess(true);
                        setTimeout(() => {
                          setBlockSuccess(false);
                          setShowBlockConfirm(false);
                          setShowSettings(false);
                        }, 2000);
                      }}
                      className="w-full bg-white text-black py-3.5 rounded-xl font-bold text-sm tracking-tight hover:bg-white/90 transition-colors"
                    >
                      Yes, Block User
                    </button>
                    <button 
                      onClick={() => setShowBlockConfirm(false)}
                      className="w-full bg-white/5 py-3.5 rounded-xl text-white font-bold text-sm tracking-tight hover:bg-white/10 transition-colors"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                <div className="p-8 text-center animate-in zoom-in-95 duration-300">
                  <div className="w-16 h-16 bg-white/5 rounded-full flex items-center justify-center mx-auto mb-6">
                    <Check className="w-8 h-8 text-white" />
                  </div>
                  <h2 className="text-xl font-bold text-white mb-2">User Blocked</h2>
                  <p className="text-grey-text text-sm leading-relaxed">
                    This user has been blocked and will no longer appear in your feeds.
                  </p>
                </div>
              )}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
      <AnimatePresence>
        {showReportConfirm && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] bg-black/80 backdrop-blur-sm flex items-center justify-center p-6"
          >
            <motion.div 
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.9, y: 20 }}
              className="bg-secondary w-full max-w-sm rounded-[32px] overflow-hidden border border-white/10 shadow-2xl"
            >
              {!reportSuccess ? (
                <div className="p-8 text-center">
                  <div className="w-16 h-16 bg-white/5 rounded-full flex items-center justify-center mx-auto mb-6">
                    <ShieldAlert className="w-8 h-8 text-white/60" />
                  </div>
                  <h2 className="text-xl font-bold text-white mb-2">Report this user?</h2>
                  <p className="text-grey-text text-sm mb-8 leading-relaxed">
                    Are you sure you want to report this profile for inappropriate behavior? Our safety team will review it.
                  </p>
                  <div className="flex flex-col gap-3">
                    <button 
                      onClick={() => {
                        // Simulate report
                        setReportSuccess(true);
                        setTimeout(() => {
                          setReportSuccess(false);
                          setShowReportConfirm(false);
                        }, 2000);
                      }}
                      className="w-full bg-white text-black py-3.5 rounded-xl font-bold text-sm tracking-tight hover:bg-white/90 transition-colors"
                    >
                      Yes, Report User
                    </button>
                    <button 
                      onClick={() => setShowReportConfirm(false)}
                      className="w-full bg-white/5 py-3.5 rounded-xl text-white font-bold text-sm tracking-tight hover:bg-white/10 transition-colors"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                <div className="p-8 text-center animate-in zoom-in-95 duration-300">
                  <div className="w-16 h-16 bg-white/5 rounded-full flex items-center justify-center mx-auto mb-6">
                    <Check className="w-8 h-8 text-white" />
                  </div>
                  <h2 className="text-xl font-bold text-white mb-2">Report Submitted</h2>
                  <p className="text-grey-text text-sm leading-relaxed">
                    Thank you for keeping the community safe. We've received your report.
                  </p>
                </div>
              )}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
