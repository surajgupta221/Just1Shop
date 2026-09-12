import React, { useState } from 'react';
import { 
  X, 
  Smartphone, 
  Download, 
  CheckCircle2, 
  ExternalLink, 
  Terminal, 
  Copy, 
  Layers, 
  Sparkles, 
  Share2, 
  QrCode,
  ArrowRight
} from 'lucide-react';

interface ApkDownloadModalProps {
  isOpen: boolean;
  onClose: () => void;
  appUrl?: string;
}

export const ApkDownloadModal: React.FC<ApkDownloadModalProps> = ({
  isOpen,
  onClose,
  appUrl = 'https://just1shop.com',
}) => {
  const [activeTab, setActiveTab] = useState<'instant_pwa' | 'build_apk' | 'manifest'>('instant_pwa');
  const [copiedText, setCopiedText] = useState('');
  const [isDownloading, setIsDownloading] = useState(false);
  const [downloadSuccess, setDownloadSuccess] = useState(false);

  if (!isOpen) return null;

  const handleCopy = (text: string, label: string) => {
    navigator.clipboard.writeText(text);
    setCopiedText(label);
    setTimeout(() => setCopiedText(''), 3000);
  };

  const handleSimulateDownload = () => {
    setIsDownloading(true);
    setTimeout(() => {
      setIsDownloading(false);
      setDownloadSuccess(true);
      // Trigger manifest / package download
      const element = document.createElement('a');
      const file = new Blob([
        JSON.stringify({
          name: 'Just1Shop - Instant Grocery Delivery',
          short_name: 'Just1Shop',
          package_name: 'com.just1shop.app',
          version: '1.0.0',
          build_type: 'Android Release APK (TWA/PWA)',
          target_url: window.location.href,
          author: 'Suraj Gupta',
          contact: '+91 8987767301',
          instructions: 'Open in Android Chrome -> Tap 3-dots -> Install App to run as native APK.'
        }, null, 2)
      ], { type: 'application/json' });
      element.href = URL.createObjectURL(file);
      element.download = 'just1shop-android-config.json';
      document.body.appendChild(element);
      element.click();
      document.body.removeChild(element);
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-2 sm:p-4 bg-black/70 backdrop-blur-xs">
      <div 
        className="bg-white rounded-3xl max-w-2xl w-full max-h-[94vh] shadow-2xl flex flex-col overflow-hidden border border-gray-100 animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 border-b border-gray-100 flex items-center justify-between bg-emerald-800 text-white shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-white text-emerald-800 flex items-center justify-center font-black shadow-md">
              <Smartphone className="w-6 h-6" />
            </div>
            <div>
              <h2 className="text-base sm:text-lg font-black text-white">
                Mobile App & APK Access Guide
              </h2>
              <p className="text-xs text-emerald-200 mt-0.5">
                Run Just1Shop on Android phone as a native app or build standalone APK
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="w-9 h-9 rounded-full bg-emerald-900/60 hover:bg-emerald-900 text-emerald-200 hover:text-white flex items-center justify-center transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Switcher */}
        <div className="flex items-center gap-2 p-3 bg-gray-50 border-b border-gray-200">
          <button
            onClick={() => setActiveTab('instant_pwa')}
            className={`flex-1 py-2 px-3 rounded-xl text-xs font-black transition-all cursor-pointer ${
              activeTab === 'instant_pwa'
                ? 'bg-emerald-600 text-white shadow-xs'
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            📱 Option 1: Instant Install (No Build Needed)
          </button>
          <button
            onClick={() => setActiveTab('build_apk')}
            className={`flex-1 py-2 px-3 rounded-xl text-xs font-black transition-all cursor-pointer ${
              activeTab === 'build_apk'
                ? 'bg-emerald-600 text-white shadow-xs'
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            ⚙️ Option 2: Build .APK File
          </button>
        </div>

        {/* Content Body */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-4">
          {activeTab === 'instant_pwa' && (
            <div className="space-y-4">
              <div className="p-4 bg-emerald-50 rounded-2xl border border-emerald-200 flex items-start gap-3">
                <Sparkles className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
                <div className="text-xs text-emerald-900 leading-relaxed">
                  <strong className="font-bold block text-sm text-emerald-950 mb-0.5">
                    How to test on your Android phone immediately:
                  </strong>
                  Your app is already configured with a Progressive Web App (PWA) manifest. You can install it on any Android device in 10 seconds without needing to compile in Android Studio.
                </div>
              </div>

              {/* 3 Steps Visual Guide */}
              <div className="space-y-2.5">
                <div className="p-3.5 rounded-2xl border border-gray-200 bg-white flex items-start gap-3">
                  <div className="w-7 h-7 rounded-xl bg-emerald-600 text-white flex items-center justify-center font-black text-xs shrink-0">
                    1
                  </div>
                  <div>
                    <span className="text-xs font-bold text-gray-900 block">
                      Open in Google Chrome on your Android phone
                    </span>
                    <span className="text-[11px] text-gray-500 block mt-0.5">
                      Open <strong className="text-emerald-700">{window.location.origin}</strong> or <strong className="text-emerald-700">just1shop.com</strong>
                    </span>
                  </div>
                </div>

                <div className="p-3.5 rounded-2xl border border-gray-200 bg-white flex items-start gap-3">
                  <div className="w-7 h-7 rounded-xl bg-emerald-600 text-white flex items-center justify-center font-black text-xs shrink-0">
                    2
                  </div>
                  <div>
                    <span className="text-xs font-bold text-gray-900 block">
                      Tap the 3 vertical dots (Chrome Menu ⋮) in top right
                    </span>
                    <span className="text-[11px] text-gray-500 block mt-0.5">
                      Look for <strong className="text-gray-800">"Install app"</strong> or <strong className="text-gray-800">"Add to Home Screen"</strong>
                    </span>
                  </div>
                </div>

                <div className="p-3.5 rounded-2xl border border-gray-200 bg-white flex items-start gap-3">
                  <div className="w-7 h-7 rounded-xl bg-emerald-600 text-white flex items-center justify-center font-black text-xs shrink-0">
                    3
                  </div>
                  <div>
                    <span className="text-xs font-bold text-gray-900 block">
                      Tap "Install"
                    </span>
                    <span className="text-[11px] text-gray-500 block mt-0.5">
                      The Just1Shop icon will appear directly in your Android App Drawer, open full-screen without address bars, and support offline caching & instant launch!
                    </span>
                  </div>
                </div>
              </div>

              {/* Direct Download Simulation */}
              <div className="pt-2">
                <button
                  type="button"
                  onClick={handleSimulateDownload}
                  disabled={isDownloading}
                  className="w-full py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-2xl font-black text-xs sm:text-sm flex items-center justify-center gap-2 shadow-sm transition-all cursor-pointer"
                >
                  <Download className="w-4 h-4" />
                  <span>
                    {isDownloading 
                      ? 'Generating Android Package Configuration...' 
                      : 'Download Just1Shop Android App Package (.json / .apk config)'}
                  </span>
                </button>
                {downloadSuccess && (
                  <p className="text-xs text-emerald-700 font-bold text-center mt-2 flex items-center justify-center gap-1">
                    <CheckCircle2 className="w-4 h-4" />
                    <span>Android configuration package downloaded to your device!</span>
                  </p>
                )}
              </div>
            </div>
          )}

          {activeTab === 'build_apk' && (
            <div className="space-y-4 text-xs">
              <div className="p-3.5 bg-slate-900 text-slate-100 rounded-2xl border border-slate-800 space-y-2">
                <div className="flex items-center justify-between text-amber-400 font-bold text-xs">
                  <span className="flex items-center gap-1.5">
                    <Terminal className="w-4 h-4" />
                    How to generate a standalone .APK file for Google Play / Android
                  </span>
                  <button
                    onClick={() => handleCopy('npx @bubblewrap/cli init --manifest=https://just1shop.com/manifest.json && npx @bubblewrap/cli build', 'cmd')}
                    className="text-slate-400 hover:text-white flex items-center gap-1 cursor-pointer"
                  >
                    <Copy className="w-3.5 h-3.5" />
                    <span>{copiedText === 'cmd' ? 'Copied!' : 'Copy'}</span>
                  </button>
                </div>

                <p className="text-[11px] text-slate-300">
                  Google provides <strong>Bubblewrap</strong> to convert any PWA web app into a signed Android APK (`app-release-signed.apk`) or AAB:
                </p>

                <div className="bg-black/50 p-3 rounded-xl font-mono text-[11px] text-emerald-400 space-y-1 overflow-x-auto">
                  <div># 1. Install Google Bubblewrap CLI</div>
                  <div>npm install -g @bubblewrap/cli</div>
                  <div className="pt-1"># 2. Initialize project using your web URL</div>
                  <div>bubblewrap init --manifest={window.location.origin}/manifest.json</div>
                  <div className="pt-1"># 3. Compile signed APK for Android</div>
                  <div>bubblewrap build</div>
                  <div className="text-gray-400 pt-1"># Output generated: ./app-release-signed.apk</div>
                </div>
              </div>

              {/* Alternative: Capacitor */}
              <div className="p-3.5 bg-gray-50 rounded-2xl border border-gray-200 space-y-2">
                <span className="font-bold text-gray-900 block text-xs">
                  Alternative: Build with Capacitor & Android Studio:
                </span>
                <div className="bg-white p-2.5 rounded-xl border border-gray-200 font-mono text-[11px] text-gray-800 space-y-1">
                  <div>npm install @capacitor/core @capacitor/cli @capacitor/android</div>
                  <div>npx cap init "Just1Shop" "com.just1shop.app"</div>
                  <div>npx cap add android</div>
                  <div>npx cap open android   # Launches Android Studio to build APK</div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ApkDownloadModal;
