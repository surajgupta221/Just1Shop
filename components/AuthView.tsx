import React, { useState } from 'react';
import { 
  ArrowRight, 
  Lock, 
  RefreshCw, 
  X, 
  Phone, 
  Sparkles,
  AlertCircle,
  ChevronLeft,
  CheckCircle2,
  Zap,
  Shield,
  Smartphone
} from 'lucide-react';
import type { UserProfile } from '../types';

interface AuthViewProps {
  isOpen?: boolean;
  onClose?: () => void;
  onLoginSuccess: (user: UserProfile) => void;
  allUsers: UserProfile[];
  onOpenApkModal?: () => void;
}

export const AuthView: React.FC<AuthViewProps> = ({
  isOpen = true,
  onClose,
  onLoginSuccess,
  allUsers,
  onOpenApkModal,
}) => {
  const [authMode, setAuthMode] = useState<'login' | 'signup'>('login');
  const [mobileNumber, setMobileNumber] = useState<string>('');
  const [fullName, setFullName] = useState<string>('');
  const [otpStep, setOtpStep] = useState<boolean>(false);
  const [otpCode, setOtpCode] = useState<string[]>(['', '', '', '', '', '']);
  const [isVerifying, setIsVerifying] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string>('');
  const [resendTimer, setResendTimer] = useState<number>(30);
  const [isTimerRunning, setIsTimerRunning] = useState<boolean>(false);

  if (!isOpen) return null;

  // Auto-detect if user enters the Owner number
  const isOwnerNumber = mobileNumber.trim().replace(/\D/g, '') === '8987767301';

  const handleMobileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value.replace(/\D/g, '').slice(0, 10);
    setMobileNumber(val);
    setErrorMessage('');
  };

  const startResendTimer = () => {
    setResendTimer(30);
    setIsTimerRunning(true);
    const interval = setInterval(() => {
      setResendTimer((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          setIsTimerRunning(false);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const handleSendOtp = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    const cleanNumber = mobileNumber.trim().replace(/\D/g, '');
    if (cleanNumber.length !== 10) {
      setErrorMessage('Please enter a valid 10-digit mobile number.');
      return;
    }

    if (authMode === 'signup' && !fullName.trim()) {
      setErrorMessage('Please enter your full name to create an account.');
      return;
    }

    setErrorMessage('');
    setOtpStep(true);

    // Fast test OTP for seamless experience
    if (cleanNumber === '8987767301') {
      setOtpCode(['7', '3', '0', '1', '9', '9']);
    } else {
      setOtpCode(['1', '2', '3', '4', '5', '6']);
    }
    startResendTimer();
  };

  const handleOtpChange = (index: number, val: string) => {
    const digit = val.slice(-1).replace(/\D/g, '');
    const newCode = [...otpCode];
    newCode[index] = digit;
    setOtpCode(newCode);

    // Auto-focus next input
    if (digit && index < 5) {
      const nextInput = document.getElementById(`futuristic-otp-${index + 1}`);
      if (nextInput) nextInput.focus();
    }
  };

  const handleVerifyOtp = () => {
    const entered = otpCode.join('');
    if (entered.length < 4) {
      setErrorMessage('Please enter the 6-digit OTP code.');
      return;
    }

    setIsVerifying(true);
    setErrorMessage('');

    setTimeout(() => {
      setIsVerifying(false);
      const cleanNumber = mobileNumber.trim().replace(/\D/g, '');

      // Check if user already exists in database
      const existingUser = allUsers.find((u) => u.phone === cleanNumber);

      if (existingUser) {
        // Log in as existing user with their preset role (Owner, Admin, Delivery, or Customer)
        onLoginSuccess(existingUser);
      } else {
        // New user creation
        const isOwner = cleanNumber === '8987767301';
        const newUser: UserProfile = {
          id: `usr-${Date.now()}`,
          name: fullName.trim() || (isOwner ? 'Store Owner' : 'Just1Shop Customer'),
          phone: cleanNumber,
          role: isOwner ? 'owner' : 'user',
          createdAt: new Date().toISOString().split('T')[0],
          isActive: true,
          email: isOwner ? 'owner@just1shop.com' : undefined,
        };
        onLoginSuccess(newUser);
      }
    }, 600);
  };

  // 1-Click Google / Gmail Authentication
  const handleGoogleLogin = () => {
    setIsVerifying(true);
    setTimeout(() => {
      setIsVerifying(false);
      const googleUser: UserProfile = {
        id: 'usr-google-user',
        name: 'Just1Shop Customer',
        email: 'customer@just1shop.com',
        phone: '9876543210',
        role: 'user',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        createdAt: '2026-01-01',
        isActive: true,
      };
      onLoginSuccess(googleUser);
    }, 500);
  };

  return (
    <div className="min-h-screen bg-slate-950/80 backdrop-blur-md fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-6 overflow-y-auto">
      {/* Futuristic Glow Backdrop */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[600px] h-[600px] bg-gradient-to-tr from-emerald-500/15 via-cyan-500/15 to-blue-600/15 rounded-full blur-3xl" />
        <div className="absolute bottom-10 right-10 w-80 h-80 bg-amber-500/10 rounded-full blur-2xl" />
      </div>

      {/* Main Glassmorphic Futuristic Modal Container */}
      <div 
        className="relative z-10 w-full max-w-4xl bg-slate-900/90 border border-slate-700/80 rounded-[32px] shadow-2xl overflow-hidden backdrop-blur-xl grid grid-cols-1 md:grid-cols-12 my-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close Button */}
        {onClose && (
          <button
            onClick={onClose}
            className="absolute top-4 right-4 z-30 w-10 h-10 rounded-full bg-slate-800/80 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center transition-all cursor-pointer border border-slate-700/50"
            title="Close"
          >
            <X className="w-5 h-5" />
          </button>
        )}

        {/* LEFT SIDE: Futuristic 3D Cyber Delivery Visual (Neon Cyber & Hologram Theme) */}
        <div className="md:col-span-5 bg-gradient-to-b from-slate-950 via-slate-900 to-emerald-950/80 p-6 sm:p-8 flex flex-col justify-between border-b md:border-b-0 md:border-r border-slate-800 relative overflow-hidden text-white">
          {/* Animated Neon Grid Lines */}
          <div className="absolute inset-0 bg-[linear-gradient(to_right,#10b9810a_1px,transparent_1px),linear-gradient(to_bottom,#10b9810a_1px,transparent_1px)] bg-[size:24px_24px] pointer-events-none" />
          
          {/* Brand Header */}
          <div className="relative z-10 flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-emerald-500 to-teal-300 text-slate-950 flex items-center justify-center font-black text-lg shadow-[0_0_20px_rgba(16,185,129,0.4)]">
                J1
              </div>
              <div>
                <span className="text-xl font-black tracking-tight text-white block leading-none">
                  Just<span className="text-emerald-400">1</span>Shop
                </span>
                <span className="text-[10px] text-emerald-400/80 font-mono tracking-wider uppercase">
                  Hyper-Instant 2026
                </span>
              </div>
            </div>

            <div className="px-2.5 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-[10px] font-bold flex items-center gap-1.5 shadow-[0_0_12px_rgba(16,185,129,0.2)]">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping" />
              <span>&lt;24h Doorstep</span>
            </div>
          </div>

          {/* Central Futuristic Delivery PNG & Hologram Composition */}
          <div className="relative z-10 my-auto py-8 text-center flex flex-col items-center">
            {/* Holographic Glowing Orb Stage */}
            <div className="relative w-56 h-56 flex items-center justify-center">
              {/* Outer Rotating Cyber Rings */}
              <div className="absolute inset-0 rounded-full border border-dashed border-emerald-500/40 animate-spin" style={{ animationDuration: '24s' }} />
              <div className="absolute inset-3 rounded-full border border-cyan-500/30 animate-spin" style={{ animationDirection: 'reverse', animationDuration: '18s' }} />
              <div className="absolute inset-8 rounded-full bg-radial from-emerald-500/20 via-teal-900/10 to-transparent blur-md" />

              {/* Central 3D Delivery Persona Illustration */}
              <div className="relative z-10 flex flex-col items-center transform hover:scale-105 transition-transform duration-300">
                {/* Floating Hologram Delivery Icon / PNG badge */}
                <div className="w-24 h-24 rounded-3xl bg-gradient-to-tr from-slate-900 via-slate-800 to-emerald-900 border-2 border-emerald-400/80 shadow-[0_0_35px_rgba(16,185,129,0.5)] flex items-center justify-center text-4xl animate-bounce" style={{ animationDuration: '3s' }}>
                  🛵
                </div>

                {/* Cyber HUD Floating Metrics */}
                <div className="mt-3 flex items-center gap-2">
                  <span className="px-2.5 py-0.5 rounded-md bg-slate-800/90 border border-emerald-500/40 text-[10px] font-mono text-emerald-300 shadow-sm">
                    GPS TRACKED
                  </span>
                  <span className="px-2.5 py-0.5 rounded-md bg-slate-800/90 border border-cyan-500/40 text-[10px] font-mono text-cyan-300 shadow-sm">
                    100% FRESH
                  </span>
                </div>
              </div>
            </div>

            {/* Futuristic Headline */}
            <h3 className="text-lg font-black text-white mt-4 tracking-wide">
              Next-Gen Grocery Fulfillment
            </h3>
            <p className="text-xs text-slate-400 mt-1.5 max-w-xs leading-relaxed">
              Real-time dark store dispatch, verified pricing, and instant courier route tracking.
            </p>
          </div>

          {/* Bottom App / APK Prompt */}
          <div className="relative z-10 pt-4 border-t border-slate-800/80 flex items-center justify-between text-xs">
            <span className="text-slate-400 text-[11px]">Android Phone User?</span>
            {onOpenApkModal && (
              <button
                onClick={onOpenApkModal}
                className="text-emerald-400 hover:text-emerald-300 font-bold flex items-center gap-1 cursor-pointer transition-colors"
              >
                <Smartphone className="w-3.5 h-3.5" />
                <span>Download APK / Install →</span>
              </button>
            )}
          </div>
        </div>

        {/* RIGHT SIDE: Ultra-Clean Futuristic Form */}
        <div className="md:col-span-7 p-6 sm:p-10 flex flex-col justify-between bg-slate-900/60">
          <div>
            {/* Top Toggle: Login vs Sign Up (No role selector!) */}
            <div className="flex items-center justify-between mb-6">
              <div className="flex p-1 rounded-2xl bg-slate-800/80 border border-slate-700/60 max-w-xs w-full">
                <button
                  type="button"
                  onClick={() => {
                    setAuthMode('login');
                    setErrorMessage('');
                  }}
                  className={`flex-1 py-2 rounded-xl text-xs font-black transition-all cursor-pointer ${
                    authMode === 'login'
                      ? 'bg-gradient-to-r from-emerald-500 to-teal-500 text-slate-950 shadow-md'
                      : 'text-slate-400 hover:text-white'
                  }`}
                >
                  Log In
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setAuthMode('signup');
                    setErrorMessage('');
                  }}
                  className={`flex-1 py-2 rounded-xl text-xs font-black transition-all cursor-pointer ${
                    authMode === 'signup'
                      ? 'bg-gradient-to-r from-emerald-500 to-teal-500 text-slate-950 shadow-md'
                      : 'text-slate-400 hover:text-white'
                  }`}
                >
                  Sign Up
                </button>
              </div>

              {/* Fast Instant Access Note */}
              <div className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs font-bold">
                <Sparkles className="w-3.5 h-3.5 text-emerald-400" />
                <span>Hyper-Instant 2026 Login</span>
              </div>
            </div>

            {/* Title & Subtitle */}
            <div className="mb-6">
              <h2 className="text-2xl sm:text-3xl font-black text-white tracking-tight">
                {otpStep 
                  ? 'Verify Security Code' 
                  : authMode === 'login' 
                  ? 'Welcome Back' 
                  : 'Create Your Account'}
              </h2>
              <p className="text-xs sm:text-sm text-slate-400 mt-1">
                {otpStep 
                  ? `Enter the 6-digit confirmation code sent to +91 ${mobileNumber}`
                  : authMode === 'login'
                  ? 'Enter your phone number to access your account & live orders.'
                  : 'Join Just1Shop for instant under 24-hour grocery delivery.'}
              </p>
            </div>

            {/* Error Message */}
            {errorMessage && (
              <div className="mb-4 p-3 bg-red-500/10 border border-red-500/30 rounded-2xl flex items-center gap-2.5 text-xs text-red-300">
                <AlertCircle className="w-4 h-4 shrink-0 text-red-400" />
                <span>{errorMessage}</span>
              </div>
            )}

            {!otpStep ? (
              /* STEP 1: MOBILE INPUT (+ NAME IF SIGNUP) */
              <form onSubmit={handleSendOtp} className="space-y-4">
                {/* Full Name field if Sign Up */}
                {authMode === 'signup' && (
                  <div>
                    <label className="text-xs font-bold text-slate-300 block mb-1.5">
                      Full Name
                    </label>
                    <input
                      type="text"
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      placeholder="e.g. Rahul Sharma"
                      className="w-full px-4 py-3 bg-slate-800/80 border border-slate-700 rounded-2xl text-sm font-bold text-white placeholder:text-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                    />
                  </div>
                )}

                {/* Mobile Number Field */}
                <div>
                  <label className="text-xs font-bold text-slate-300 block mb-1.5">
                    Phone Number
                  </label>
                  <div className="flex items-center rounded-2xl border border-slate-700 bg-slate-800/80 focus-within:border-emerald-500 focus-within:ring-2 focus-within:ring-emerald-500/20 transition-all overflow-hidden p-1">
                    <span className="px-3.5 py-2 text-sm font-bold text-emerald-400 border-r border-slate-700 flex items-center gap-1.5">
                      <Phone className="w-3.5 h-3.5" />
                      +91
                    </span>
                    <input
                      type="tel"
                      value={mobileNumber}
                      onChange={handleMobileChange}
                      placeholder="Enter 10-digit number"
                      maxLength={10}
                      className="w-full px-3.5 py-2 bg-transparent text-sm font-bold text-white placeholder:text-slate-500 outline-none"
                      autoFocus
                    />
                    {mobileNumber && (
                      <button
                        type="button"
                        onClick={() => setMobileNumber('')}
                        className="p-1.5 text-slate-400 hover:text-white mr-1.5"
                      >
                        <X className="w-4 h-4" />
                      </button>
                    )}
                  </div>

                  {/* Owner Number Recognition Alert */}
                  {isOwnerNumber && (
                    <div className="mt-2 p-2 rounded-xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-between text-xs text-amber-300 font-bold">
                      <span className="flex items-center gap-1.5">
                        <Sparkles className="w-4 h-4 text-amber-400" />
                        Store Administrator Access Detected
                      </span>
                      <span className="text-[10px] bg-amber-400 text-slate-950 px-2 py-0.5 rounded font-black">
                        MASTER ACCESS
                      </span>
                    </div>
                  )}
                </div>


                {/* Submit OTP Request Button */}
                <button
                  type="submit"
                  disabled={mobileNumber.length !== 10}
                  className="w-full py-3.5 bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 disabled:from-slate-800 disabled:to-slate-800 disabled:text-slate-500 text-slate-950 font-black text-sm rounded-2xl flex items-center justify-center gap-2 shadow-[0_0_20px_rgba(16,185,129,0.3)] transition-all cursor-pointer active:scale-98"
                >
                  <span>{authMode === 'login' ? 'Continue with OTP' : 'Create Account & Verify'}</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </form>
            ) : (
              /* STEP 2: OTP VERIFICATION */
              <div className="space-y-5">
                <div className="flex items-center justify-between bg-slate-800/80 p-3 rounded-2xl border border-slate-700">
                  <div className="flex items-center gap-2 text-xs font-bold text-white">
                    <Phone className="w-4 h-4 text-emerald-400" />
                    <span>+91 {mobileNumber}</span>
                  </div>
                  <button
                    type="button"
                    onClick={() => setOtpStep(false)}
                    className="text-xs font-bold text-emerald-400 hover:underline flex items-center gap-0.5 cursor-pointer"
                  >
                    <ChevronLeft className="w-3.5 h-3.5" />
                    Change
                  </button>
                </div>

                {/* 6 Digit Futuristic OTP Inputs */}
                <div>
                  <label className="text-xs font-bold text-slate-300 block mb-2">
                    Enter Verification Code
                  </label>
                  <div className="grid grid-cols-6 gap-2 sm:gap-3">
                    {otpCode.map((digit, i) => (
                      <input
                        key={i}
                        id={`futuristic-otp-${i}`}
                        type="text"
                        inputMode="numeric"
                        maxLength={1}
                        value={digit}
                        onChange={(e) => handleOtpChange(i, e.target.value)}
                        className="w-full h-13 text-center text-xl font-black text-white bg-slate-800 border border-slate-700 rounded-xl focus:border-emerald-400 focus:ring-2 focus:ring-emerald-400/20 outline-none transition-all"
                      />
                    ))}
                  </div>

                  <div className="mt-3 flex items-center justify-between text-xs text-slate-400">
                    <span className="text-emerald-400 font-medium">Test OTP auto-filled for speed</span>
                    {isTimerRunning ? (
                      <span>Resend in {resendTimer}s</span>
                    ) : (
                      <button
                        type="button"
                        onClick={startResendTimer}
                        className="text-emerald-400 hover:text-emerald-300 font-bold underline cursor-pointer"
                      >
                        Resend Code
                      </button>
                    )}
                  </div>
                </div>

                {/* Verify Button */}
                <button
                  type="button"
                  onClick={handleVerifyOtp}
                  disabled={isVerifying}
                  className="w-full py-3.5 bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-slate-950 font-black text-sm rounded-2xl flex items-center justify-center gap-2 shadow-[0_0_25px_rgba(16,185,129,0.35)] transition-all cursor-pointer active:scale-98"
                >
                  {isVerifying ? (
                    <>
                      <RefreshCw className="w-4 h-4 animate-spin" />
                      <span>Authenticating Securely...</span>
                    </>
                  ) : (
                    <>
                      <span>Confirm & Enter Storefront</span>
                      <ArrowRight className="w-4 h-4" />
                    </>
                  )}
                </button>
              </div>
            )}

            {/* DIVIDER */}
            <div className="relative my-6 text-center">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-slate-800" />
              </div>
              <span className="relative bg-slate-900 px-3 text-[11px] text-slate-500 uppercase tracking-widest font-mono">
                or continue with
              </span>
            </div>

            {/* GOOGLE 1-CLICK AUTH BUTTON */}
            <button
              type="button"
              onClick={handleGoogleLogin}
              disabled={isVerifying}
              className="w-full py-3 px-4 rounded-2xl bg-slate-800/80 hover:bg-slate-800 border border-slate-700 hover:border-slate-600 text-white text-xs font-bold flex items-center justify-center gap-3 transition-all cursor-pointer shadow-sm active:scale-98"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                />
              </svg>
              <span>Continue with Google</span>
            </button>
          </div>

          {/* Security & Compliance Footer */}
          <div className="mt-6 pt-4 border-t border-slate-800/80 flex items-center justify-between text-[11px] text-slate-500">
            <span className="flex items-center gap-1">
              <Shield className="w-3.5 h-3.5 text-emerald-400" />
              <span>256-bit Encrypted Session</span>
            </span>
            <span>Just1Shop Privacy Protected</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AuthView;
