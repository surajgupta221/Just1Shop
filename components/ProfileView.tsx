import React from 'react';
import { 
  User, 
  Wallet, 
  MapPin, 
  Globe, 
  Database, 
  ShieldCheck, 
  HelpCircle, 
  ChevronRight,
  Zap,
  Sparkles,
  Award,
  Smartphone,
  Bike,
  LogOut,
  RefreshCw,
  Phone
} from 'lucide-react';
import type { Address, UserProfile, UserRole } from '../types';

interface ProfileViewProps {
  currentAddress: Address;
  onOpenAddressModal: () => void;
  onOpenMapPicker?: () => void;
  onOpenSeoModal: () => void;
  onOpenAdminModal: () => void;
  currentUser?: UserProfile | null;
  onOpenAuthModal?: () => void;
  onOpenOwnerModal?: () => void;
  onOpenApkModal?: () => void;
  onLogout?: () => void;
  onOpenUserDetailsModal?: () => void;
  onOpenBannersModal?: () => void;
}

const ProfileView: React.FC<ProfileViewProps> = ({
  currentAddress,
  onOpenAddressModal,
  onOpenMapPicker,
  onOpenSeoModal,
  onOpenAdminModal,
  currentUser,
  onOpenAuthModal,
  onOpenOwnerModal,
  onOpenApkModal,
  onLogout,
  onOpenUserDetailsModal,
  onOpenBannersModal,
}) => {
  const isOwner = currentUser?.role === 'owner';
  const isAdmin = currentUser?.role === 'admin' || isOwner;
  const [showLogoutConfirm, setShowLogoutConfirm] = React.useState<boolean>(false);

  return (
    <div className="max-w-3xl mx-auto px-3 sm:px-4 lg:px-6 py-4 space-y-4">
      {/* Profile Card */}
      <div className="bg-gradient-to-br from-emerald-700 via-emerald-800 to-slate-900 text-white rounded-3xl p-5 sm:p-6 shadow-md relative overflow-hidden">
        <div className="absolute right-0 bottom-0 translate-x-4 translate-y-4 text-emerald-800/30 pointer-events-none">
          <Zap className="w-48 h-48" />
        </div>

        <div className="relative z-10 flex items-center justify-between">
          <div className="flex items-center gap-3 sm:gap-4">
            <div className="w-14 h-14 rounded-2xl bg-white text-emerald-800 flex items-center justify-center font-black text-xl shadow-md overflow-hidden">
              {currentUser?.avatar ? (
                <img src={currentUser.avatar} alt={currentUser.name} className="w-full h-full object-cover" />
              ) : (
                currentUser ? currentUser.name.slice(0, 2).toUpperCase() : 'JU'
              )}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-base sm:text-lg font-bold text-white">
                  {isOwner ? 'Store Administrator' : (currentUser ? currentUser.name : 'Guest User')}
                </h2>
                {isOwner ? (
                  <span className="bg-amber-400 text-gray-950 text-[10px] font-black px-2 py-0.5 rounded-full flex items-center gap-0.5">
                    <Award className="w-3 h-3" />
                    OWNER
                  </span>
                ) : currentUser?.role === 'delivery' ? (
                  <span className="bg-emerald-400 text-gray-950 text-[10px] font-black px-2 py-0.5 rounded-full flex items-center gap-0.5">
                    <Bike className="w-3 h-3" />
                    DELIVERY BOY
                  </span>
                ) : currentUser?.role === 'admin' ? (
                  <span className="bg-blue-400 text-gray-950 text-[10px] font-black px-2 py-0.5 rounded-full flex items-center gap-0.5">
                    <ShieldCheck className="w-3 h-3" />
                    ADMIN
                  </span>
                ) : (
                  <span className="bg-yellow-400 text-gray-900 text-[10px] font-black px-2 py-0.5 rounded-full">
                    CUSTOMER
                  </span>
                )}
              </div>
              <p className="text-xs text-emerald-200 mt-0.5">
                {isOwner ? 'Master Store Account · Verified Access' : (currentUser?.phone ? `+91 ${currentUser.phone}` : 'Account Mobile Not Linked')} {!isOwner && currentUser?.email ? `· ${currentUser.email}` : ''}
              </p>
              <p className="text-[11px] text-emerald-300 mt-1 flex items-center gap-1">
                <Zap className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                <span>Just1Shop Member · Under 24h Delivery SLA</span>
              </p>
            </div>
          </div>

          {/* Account Details / Login / Logout Actions */}
          <div className="flex items-center gap-2">
            {currentUser && onOpenUserDetailsModal && (
              <button
                onClick={onOpenUserDetailsModal}
                className="bg-white/10 hover:bg-white/20 border border-white/20 text-white text-xs font-bold px-3 py-1.5 rounded-xl transition-colors cursor-pointer flex items-center gap-1.5"
                title="View & Edit Account Details"
              >
                <User className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Details</span>
              </button>
            )}

            {currentUser && onLogout ? (
              <button
                onClick={() => setShowLogoutConfirm(true)}
                className="bg-red-500/20 hover:bg-red-500/40 border border-red-400/30 text-white text-xs font-bold px-3 py-1.5 rounded-xl transition-colors cursor-pointer flex items-center gap-1.5"
                title="Log out of this account"
              >
                <LogOut className="w-3.5 h-3.5 text-red-300" />
                <span className="hidden sm:inline">Log Out</span>
              </button>
            ) : onOpenAuthModal ? (
              <button
                onClick={onOpenAuthModal}
                className="bg-yellow-400 hover:bg-yellow-300 text-gray-950 text-xs font-black px-3.5 py-1.5 rounded-xl transition-colors cursor-pointer flex items-center gap-1.5 shadow-xs"
              >
                <RefreshCw className="w-3.5 h-3.5" />
                <span>Log In</span>
              </button>
            ) : null}
          </div>
        </div>

        {/* Quick Stats / Wallet */}
        <div className="mt-5 pt-4 border-t border-emerald-600/60 grid grid-cols-3 gap-2 text-center">
          <div className="bg-emerald-800/60 p-2.5 rounded-xl backdrop-blur-2xs">
            <span className="text-[10px] text-emerald-200 uppercase font-bold block">Role</span>
            <span className="text-sm sm:text-base font-black text-white capitalize">
              {currentUser?.role || 'Guest'}
            </span>
          </div>
          <div className="bg-emerald-800/60 p-2.5 rounded-xl backdrop-blur-2xs">
            <span className="text-[10px] text-emerald-200 uppercase font-bold block">Just1Cash</span>
            <span className="text-sm sm:text-base font-black text-white">₹150</span>
          </div>
          <div className="bg-emerald-800/60 p-2.5 rounded-xl backdrop-blur-2xs">
            <span className="text-[10px] text-emerald-200 uppercase font-bold block">Savings</span>
            <span className="text-sm sm:text-base font-black text-yellow-300">₹820 Saved</span>
          </div>
        </div>
      </div>

      {/* Owner Management Shortcut (Prominent for 8987767301) */}
      {isOwner && onOpenOwnerModal && (
        <div className="bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 rounded-3xl p-4 sm:p-5 shadow-2xs">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-amber-500 text-gray-950 flex items-center justify-center font-black shadow-xs">
                <Award className="w-6 h-6 text-amber-950" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="text-sm font-black text-gray-900">
                    Owner Command Center
                  </h3>
                  <span className="bg-amber-400 text-gray-950 text-[9px] font-black px-2 py-0.5 rounded-full">
                    MASTER
                  </span>
                </div>
                <p className="text-xs text-gray-600 mt-0.5">
                  Decide who is Admin, Delivery Boy, or Customer · Set Shop Location & Radius (km)
                </p>
              </div>
            </div>

            <button
              onClick={onOpenOwnerModal}
              className="px-4 py-2 bg-amber-500 hover:bg-amber-600 text-gray-950 font-black text-xs rounded-xl shadow-xs transition-colors cursor-pointer"
            >
              Open Owner Hub →
            </button>
          </div>
        </div>
      )}

      {/* Admin / Owner: Festive Season & Sale Banners Management Shortcut */}
      {isAdmin && onOpenBannersModal && (
        <div className="bg-gradient-to-r from-red-50 via-rose-50 to-amber-50 border border-rose-200 rounded-3xl p-4 sm:p-5 shadow-2xs">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-red-600 to-amber-600 text-white flex items-center justify-center font-black shadow-xs">
                <Sparkles className="w-6 h-6" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="text-sm font-black text-gray-900">
                    Festive & Sale Banners
                  </h3>
                  <span className="bg-rose-600 text-white text-[9px] font-black px-2 py-0.5 rounded-full">
                    LIVE
                  </span>
                </div>
                <p className="text-xs text-gray-600 mt-0.5">
                  Add or toggle Durga Puja, Company Exclusive & Winner Sale banners on storefront
                </p>
              </div>
            </div>

            <button
              onClick={onOpenBannersModal}
              className="px-3.5 py-2 bg-rose-600 hover:bg-rose-700 text-white font-bold text-xs rounded-xl shadow-xs transition-colors cursor-pointer"
            >
              Manage Banners →
            </button>
          </div>
        </div>
      )}

      {/* Android Mobile App / APK Guide Banner */}
      {onOpenApkModal && (
        <div className="bg-gradient-to-r from-sky-50 to-blue-50 border border-blue-200 rounded-3xl p-4 sm:p-5 shadow-2xs">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-blue-600 text-white flex items-center justify-center font-black shadow-xs">
                <Smartphone className="w-6 h-6" />
              </div>
              <div>
                <h3 className="text-sm font-black text-gray-900">
                  Android Mobile App & APK Guide
                </h3>
                <p className="text-xs text-gray-600 mt-0.5">
                  Install Just1Shop instantly on your Android phone or build release APK
                </p>
              </div>
            </div>

            <button
              onClick={onOpenApkModal}
              className="px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs rounded-xl shadow-xs transition-colors cursor-pointer"
            >
              Install App / APK →
            </button>
          </div>
        </div>
      )}

      {/* Developer & System Integrations Hub */}
      <div className="bg-white rounded-3xl border border-gray-100 p-4 sm:p-5 shadow-2xs space-y-3">
        <div className="flex items-center gap-2 mb-1">
          <div className="p-1.5 rounded-lg bg-amber-50 text-amber-700">
            <Sparkles className="w-4 h-4" />
          </div>
          <h3 className="text-sm font-bold text-gray-900">Engineering & Cloud Hub</h3>
        </div>

        <div className="space-y-2">
          {/* Catalog Sync Pipeline Trigger */}
          <button
            onClick={onOpenAdminModal}
            className="w-full flex items-center justify-between p-3.5 rounded-2xl bg-amber-50/70 hover:bg-amber-100/70 border border-amber-200 transition-colors text-left cursor-pointer group"
          >
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-amber-600 text-white flex items-center justify-center shadow-xs">
                <Database className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-xs font-bold text-gray-900 group-hover:text-amber-800">
                  Master Catalog Backend Pipeline & Schema
                </h4>
                <p className="text-[11px] text-gray-500">
                  Inspect Node.js scraper script, PostgreSQL/Mongo schema & NULL pricing rules
                </p>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-amber-600 group-hover:translate-x-1 transition-transform" />
          </button>

          {/* Google Search SEO Snippet Inspector */}
          <button
            onClick={onOpenSeoModal}
            className="w-full flex items-center justify-between p-3.5 rounded-2xl bg-blue-50/70 hover:bg-blue-100/70 border border-blue-200 transition-colors text-left cursor-pointer group"
          >
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-blue-600 text-white flex items-center justify-center shadow-xs">
                <Globe className="w-4 h-4" />
              </div>
              <div>
                <h4 className="text-xs font-bold text-gray-900 group-hover:text-blue-800">
                  Google Search SERP Preview & SEO Inspector
                </h4>
                <p className="text-[11px] text-gray-500">
                  Review Schema.org JSON-LD, meta tags, and live Google search appearance
                </p>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-blue-600 group-hover:translate-x-1 transition-transform" />
          </button>
        </div>
      </div>

      {/* Account Settings List */}
      <div className="bg-white rounded-3xl border border-gray-100 p-2 sm:p-3 shadow-2xs divide-y divide-gray-100">
        <button
          onClick={onOpenAddressModal}
          className="w-full flex items-center justify-between p-3 hover:bg-gray-50 rounded-2xl transition-colors text-left cursor-pointer"
        >
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-xl bg-gray-100 text-gray-700">
              <MapPin className="w-4 h-4" />
            </div>
            <div>
              <span className="text-xs font-bold text-gray-900 block">Manage Delivery Addresses</span>
              <span className="text-[11px] text-gray-400">Current: {currentAddress.title}</span>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-400" />
        </button>

        {onOpenMapPicker && (
          <button
            onClick={onOpenMapPicker}
            className="w-full flex items-center justify-between p-3 hover:bg-emerald-50/50 rounded-2xl transition-colors text-left cursor-pointer"
          >
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-xl bg-emerald-50 text-emerald-700">
                <MapPin className="w-4 h-4" />
              </div>
              <div>
                <span className="text-xs font-bold text-gray-900 block flex items-center gap-1.5">
                  Pin Exact Location on Map
                  <span className="bg-emerald-600 text-white text-[9px] font-bold px-1.5 py-0.2 rounded-full">
                    GPS
                  </span>
                </span>
                <span className="text-[11px] text-gray-400">
                  {currentAddress.coordinates ? `${currentAddress.coordinates.lat.toFixed(3)}°N, ${currentAddress.coordinates.lng.toFixed(3)}°E` : 'Auto-calculate dark store ETA'}
                </span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-emerald-600" />
          </button>
        )}

        <div className="w-full flex items-center justify-between p-3 hover:bg-gray-50 rounded-2xl transition-colors text-left">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-xl bg-gray-100 text-gray-700">
              <ShieldCheck className="w-4 h-4" />
            </div>
            <div>
              <span className="text-xs font-bold text-gray-900 block">Under 24-Hour SLA Delivery</span>
              <span className="text-[11px] text-gray-400">Doorstep fulfillment guarantee</span>
            </div>
          </div>
          <span className="text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded">Active</span>
        </div>

        <div className="w-full flex items-center justify-between p-3 hover:bg-gray-50 rounded-2xl transition-colors text-left">
          <div className="flex items-center gap-3">
            <div className="p-2 rounded-xl bg-gray-100 text-gray-700">
              <HelpCircle className="w-4 h-4" />
            </div>
            <div>
              <span className="text-xs font-bold text-gray-900 block">24x7 Customer Support</span>
              <span className="text-[11px] text-gray-400">Instant resolution for missing or damaged items</span>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-gray-400" />
        </div>

        {/* User Account & Details View Shortcut */}
        {currentUser && onOpenUserDetailsModal && (
          <button
            onClick={onOpenUserDetailsModal}
            className="w-full flex items-center justify-between p-3 hover:bg-emerald-50/50 rounded-2xl transition-colors text-left cursor-pointer"
          >
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-xl bg-emerald-100 text-emerald-800">
                <User className="w-4 h-4" />
              </div>
              <div>
                <span className="text-xs font-bold text-gray-900 block">Account & Profile Settings</span>
                <span className="text-[11px] text-gray-400">View personal details, order receipts & preferences</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-emerald-600" />
          </button>
        )}
      </div>

      {/* Prominent Log Out Section */}
      {currentUser && onLogout && (
        <div className="bg-white rounded-3xl border border-red-100 p-4 shadow-2xs">
          {showLogoutConfirm ? (
            <div className="bg-red-50 border border-red-200 rounded-2xl p-4 space-y-3">
              <div className="flex items-start gap-2.5">
                <LogOut className="w-5 h-5 text-red-600 shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-xs font-bold text-red-950">Are you sure you want to log out?</h4>
                  <p className="text-[11px] text-red-700 mt-0.5">
                    You can log back in at any time with your registered mobile number or email.
                  </p>
                </div>
              </div>
              <div className="flex items-center justify-end gap-2 pt-1">
                <button
                  type="button"
                  onClick={() => setShowLogoutConfirm(false)}
                  className="px-3.5 py-1.5 text-xs font-bold text-gray-600 hover:bg-gray-100 bg-white border border-gray-200 rounded-xl cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowLogoutConfirm(false);
                    onLogout();
                  }}
                  className="px-4 py-1.5 bg-red-600 hover:bg-red-700 text-white text-xs font-bold rounded-xl shadow-xs cursor-pointer flex items-center gap-1.5"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>Yes, Log Out</span>
                </button>
              </div>
            </div>
          ) : (
            <button
              type="button"
              onClick={() => setShowLogoutConfirm(true)}
              className="w-full flex items-center justify-center gap-2 p-3 bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 rounded-2xl text-xs font-bold transition-colors cursor-pointer"
            >
              <LogOut className="w-4 h-4" />
              <span>Log Out of Just1Shop</span>
            </button>
          )}
        </div>
      )}
    </div>
  );
};

export default ProfileView;

