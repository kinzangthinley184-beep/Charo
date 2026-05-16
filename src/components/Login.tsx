import { Smartphone, ArrowRight, ChevronLeft, Heart, Chrome } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import React, { useState } from 'react';
import { signInWithPopup, GoogleAuthProvider, RecaptchaVerifier, signInWithPhoneNumber, ConfirmationResult } from 'firebase/auth';
import { auth } from '../lib/firebase';

interface LoginProps {
  onLogin: (isReturning: boolean) => void;
}

export function Login({ onLogin }: LoginProps) {
  const [step, setStep] = useState<'welcome' | 'phone' | 'otp'>('welcome');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [loading, setLoading] = useState(false);
  const [confirmationResult, setConfirmationResult] = useState<ConfirmationResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleGoogleLogin = async () => {
    setLoading(true);
    setError(null);
    try {
      const provider = new GoogleAuthProvider();
      // Added custom parameters if necessary, but standard is fine
      await signInWithPopup(auth, provider);
      // Wait for onAuthStateChanged in App.tsx to catch the login and call handleLogin?
      // Actually onAuthStateChanged updates App state, so we don't need to manually call onLogin.
    } catch (err: any) {
      console.error(err);
      setError(err.message || 'Failed to login with Google.');
      setLoading(false);
    }
  };

  const handlePhoneSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (phoneNumber.length < 8) return;
    
    setLoading(true);
    setError(null);
    setTimeout(() => {
      setLoading(false);
      setStep('otp');
    }, 1000); // Shorter mock delay
  };

  const handleOtpChange = (index: number, value: string) => {
    if (value.length > 1) value = value.slice(-1);
    const newOtp = [...otp];
    newOtp[index] = value;
    setOtp(newOtp);

    // Auto-focus next input
    if (value && index < 5) {
      const nextInput = document.getElementById(`otp-${index + 1}`);
      nextInput?.focus();
    }

    // Auto-submit when complete
    if (newOtp.every(digit => digit !== '') && index === 5) {
      handleOtpSubmit(newOtp.join(''));
    }
  };

  const handleOtpSubmit = async (code: string) => {
    setLoading(true);
    setError(null);
    setTimeout(() => {
      setLoading(false);
      // Mode: phone starting with '1' is returning
      const isReturning = phoneNumber.startsWith('1') || phoneNumber === '12345678';
      onLogin(isReturning);
    }, 1500);
  };

  return (
    <div className="flex flex-col h-full bg-app-bg text-white relative overflow-hidden font-sans">
      {/* Background gradients */}
      <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-b from-[#111] via-[#111] to-primary/10 z-0" />
      
      {/* Abstract Shapes */}
      <div className="absolute top-20 -right-20 w-64 h-64 bg-primary/20 rounded-full blur-[80px] z-0" />
      <div className="absolute -bottom-20 -left-20 w-64 h-64 bg-primary/20 rounded-full blur-[80px] z-0" />

      <AnimatePresence mode="wait">
        {step === 'welcome' && (
          <motion.div 
            key="welcome"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="flex-1 flex flex-col justify-end px-6 py-10 sm:p-8 z-10 pb-20 sm:pb-24"
          >
            <div className="mb-10 sm:mb-12">
              <div className="flex items-center gap-2 mb-6">
                <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-[0_0_20px_rgba(255,255,255,0.3)] rotate-3">
                  <Heart className="w-6 h-6 text-black fill-current" />
                </div>
                <span className="text-2xl font-black italic tracking-tight">Charo</span>
              </div>
              <h1 className="text-5xl sm:text-6xl font-black tracking-tight mb-4 leading-[0.95]">
                It starts<br />with a<br /><span className="text-white italic">swipe.</span>
              </h1>
              <p className="text-grey-text font-semibold text-base sm:text-lg max-w-[90%] sm:max-w-[80%] leading-relaxed">
                Connect with hearts across the Land of the Thunder Dragon.
              </p>
            </div>

            <div className="flex flex-col gap-3.5">
              {error && (
                <div className="bg-white/10 border border-white/20 text-white/70 p-3 rounded-xl text-xs font-bold text-center mb-2">
                  {error}
                </div>
              )}
              <button 
                onClick={handleGoogleLogin}
                disabled={loading}
                className="w-full bg-white text-black font-extrabold text-base py-4 rounded-full flex items-center justify-center gap-3 shadow-[0_0_20px_rgba(255,255,255,0.1)] hover:scale-[1.02] transition-all active:scale-[0.98] disabled:opacity-50"
              >
                <Chrome className="w-5 h-5 text-[#4285F4]" />
                {loading ? 'Logging in...' : 'Continue with Google'}
              </button>
              <button 
                onClick={() => setStep('phone')}
                disabled={loading}
                className="w-full bg-white/5 border border-white/10 text-white font-extrabold text-base py-4 rounded-full flex items-center justify-center gap-3 hover:bg-white/10 transition-all active:scale-[0.98]"
              >
                <Smartphone className="w-5 h-5" />
                Continue with Phone
              </button>
            </div>

            <div className="mt-8 text-center">
              <p className="text-grey-text text-[12px] font-bold uppercase tracking-widest leading-relaxed px-4 opacity-60">
                By continuing, you agree to our <span className="text-white underline cursor-pointer">Terms</span> & <span className="text-white underline cursor-pointer">Privacy</span>
              </p>
            </div>
          </motion.div>
        )}

        {step === 'phone' && (
          <motion.div 
            key="phone"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="flex-1 flex flex-col px-6 py-10 sm:p-8 z-10 pt-16 sm:pt-20"
          >
            <button onClick={() => setStep('welcome')} className="mb-6 sm:mb-8 p-3 -ml-3 rounded-full hover:bg-white/5 transition-colors w-fit">
              <ChevronLeft className="w-8 h-8" />
            </button>
            <h2 className="text-2xl sm:text-3xl font-black mb-2">My number is</h2>
            <p className="text-grey-text font-medium mb-6 sm:mb-8 text-sm sm:text-base">We'll send a code to verify your account.</p>
            
            {error && (
              <div className="bg-white/10 border border-white/20 text-white/70 p-3 rounded-xl text-xs font-bold mb-6">
                {error}
              </div>
            )}

            <form onSubmit={handlePhoneSubmit} className="flex flex-col gap-6 sm:gap-8">
              <div className="flex items-center gap-3 sm:gap-4 text-2xl sm:text-3xl font-black border-b-[3px] border-primary pb-3 sm:pb-4">
                <span className="text-grey-text opacity-50 text-xl sm:text-3xl">+975</span>
                <input 
                  autoFocus
                  type="tel"
                  placeholder="17 11 11 11"
                  className="bg-transparent outline-none flex-1 placeholder:text-white/10 text-xl sm:text-3xl"
                  value={phoneNumber}
                  onChange={e => setPhoneNumber(e.target.value)}
                />
              </div>

              <button 
                disabled={phoneNumber.length < 8 || loading}
                className="w-full bg-white py-5 rounded-full text-black font-black text-lg shadow-xl shadow-white/20 flex items-center justify-center gap-2 group transition-all"
              >
                {loading ? 'Continuing...' : 'Continue'}
                {!loading && <ArrowRight className="w-6 h-6 group-hover:translate-x-1 transition-transform" />}
              </button>
            </form>
          </motion.div>
        )}

        {step === 'otp' && (
          <motion.div 
            key="otp"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="flex-1 flex flex-col px-5 py-10 sm:p-8 z-10 pt-16 sm:pt-20"
          >
            <button onClick={() => setStep('phone')} className="mb-6 sm:mb-8 p-3 -ml-3 rounded-full hover:bg-white/5 transition-colors w-fit text-white">
              <ChevronLeft className="w-8 h-8" />
            </button>
            <h2 className="text-2xl sm:text-3xl font-black mb-2">Enter the code</h2>
            <p className="text-grey-text font-medium mb-6 sm:mb-8 text-sm sm:text-base">We sent it to +975 {phoneNumber}</p>
            
            {error && (
              <div className="bg-white/10 border border-white/20 text-white/70 p-3 rounded-xl text-xs font-bold mb-6">
                {error}
              </div>
            )}

            <div className="flex justify-between gap-1.5 sm:gap-2 mb-10 sm:mb-12">
              {otp.map((digit, i) => (
                <input 
                  key={i}
                  id={`otp-${i}`}
                  autoFocus={i === 0}
                  type="text"
                  inputMode="numeric"
                  value={digit}
                  onChange={e => handleOtpChange(i, e.target.value)}
                  className="w-10 h-14 sm:w-12 sm:h-16 bg-secondary/50 border-b-[3px] border-white/10 focus:border-primary outline-none text-center text-xl sm:text-3xl font-black transition-all rounded-lg"
                />
              ))}
            </div>

            <button className="text-white font-bold hover:underline self-center">
              Resend Code in 0:45
            </button>

            {loading && (
              <div className="fixed inset-0 bg-black/60 backdrop-blur-md flex items-center justify-center z-[100]">
                <div className="w-16 h-16 border-4 border-white border-t-transparent rounded-full animate-spin" />
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
      <div id="recaptcha-container"></div>
    </div>
  );
}
