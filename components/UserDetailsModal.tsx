import React, { useState } from 'react';
import { 
  X, 
  User, 
  Phone, 
  Mail, 
  MapPin, 
  LogOut, 
  Edit3, 
  Check, 
  ShieldCheck, 
  Wallet, 
  Clock, 
  ShoppingBag, 
  Award, 
  Bike,
  Sparkles,
  AlertCircle
} from 'lucide-react';
import type { UserProfile, Address, Order } from '../types';

interface UserDetailsModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentUser: UserProfile | null;
  onUpdateProfile: (updated: Partial<UserProfile>) => void;
  onLogout: () => void;
  currentAddress: Address;
  onOpenAddressModal: () => void;
  onOpenMapPicker?: () => void;
  orders: Order[];
  onViewOrders: () => void;
  onOpenAuthModal?: () => void;
}

const UserDetailsModal: React.FC<UserDetailsModalProps> = ({
  isOpen,
  onClose,
  currentUser,
  onUpdateProfile,
  onLogout,
  currentAddress,
  onOpenAddressModal,
  onOpenMapPicker,
  orders,
  onViewOrders,
  onOpenAuthModal,
}) => {
  const [isEditing, setIsEditing] = useState<boolean>(false);
  const [name, setName] = useState<string>(currentUser?.name || '');
  const [email, setEmail] = useState<string>(currentUser?.email || '');
  const [showLogoutConfirm, setShowLogoutConfirm] = useState<boolean>(false);

  if (!isOpen) return null;

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    onUpdateProfile({
      name: name.trim(),
      email: email.trim() || undefined,
    });
    setIsEditing(false);
  };

  const handleConfirmLogout = () => {
    setShowLogoutConfirm(false);
    onLogout();
    onClose();
  };

  const isOwner = currentUser?.role === 'owner';
  const displayName = isOwner ? 'Store Administrator' : (currentUser?.name || '');
  const displayPhone = isOwner ? 'Master Admin Secure ID' : (currentUser ? `+91 ${currentUser.phone}` : '');

  const userOrders = currentUser 
    ? orders.filter(o => o.address?.title?.toLowerCase().includes(currentUser.name.toLowerCase()) || currentUser.role !== 'user')
    : [];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div 
        className="bg-white rounded-3xl max-w-lg w-full max-h-[90vh] overflow-y-auto shadow-2xl border border-gray-100 flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-gray-100 sticky top-0 bg-white/95 backdrop-blur-md z-10">
          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-2xl bg-emerald-100 text-emerald-800 flex items-center justify-center font-black">
              <User className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-black text-gray-900">User Account & Details</h2>
              <p className="text-xs text-gray-500">Manage your profile, addresses & session</p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-1.5 text-gray-400 hover:text-gray-600 rounded-xl hover:bg-gray-100 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content Body */}
        <div className="p-5 space-y-5">
          {/* User Profile Card */}
          {currentUser ? (
            <div className="bg-gradient-to-br from-emerald-800 via-emerald-700 to-teal-900 text-white rounded-3xl p-5 relative overflow-hidden shadow-sm">
              <div className="relative z-10 flex items-start justify-between gap-3">
                <div className="flex items-center gap-3.5">
                  <div className="w-14 h-14 rounded-2xl bg-white text-emerald-900 flex items-center justify-center font-black text-xl shadow-md overflow-hidden shrink-0">
                    {currentUser.avatar ? (
                      <img src={currentUser.avatar} alt={currentUser.name} className="w-full h-full object-cover" />
                    ) : (
                      currentUser.name.slice(0, 2).toUpperCase()
                    )}
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <h3 className="text-base sm:text-lg font-black text-white">{displayName}</h3>
                      <span className="bg-white/20 text-white text-[10px] font-black uppercase px-2 py-0.5 rounded-full border border-white/30">
                        {isOwner ? 'STORE OWNER' : currentUser.role}
                      </span>
                    </div>
                    <p className="text-xs text-emerald-100 flex items-center gap-1.5 mt-0.5">
                      <Phone className="w-3 h-3 text-emerald-300" />
                      <span>{displayPhone}</span>
                    </p>
                    {currentUser.email && !isOwner && (
                      <p className="text-xs text-emerald-200 flex items-center gap-1.5 mt-0.5">
                        <Mail className="w-3 h-3 text-emerald-300" />
                        <span>{currentUser.email}</span>
                      </p>
                    )}
                  </div>
                </div>

                <button
                  onClick={() => setIsEditing(!isEditing)}
                  className="bg-white/10 hover:bg-white/20 text-white text-xs font-bold px-3 py-1.5 rounded-xl border border-white/20 transition-colors cursor-pointer flex items-center gap-1 shrink-0"
                >
                  <Edit3 className="w-3 h-3" />
                  <span>{isEditing ? 'Cancel' : 'Edit'}</span>
                </button>
              </div>

              {/* Wallet & Stats Strip */}
              <div className="mt-4 pt-3 border-t border-white/10 grid grid-cols-3 gap-2 text-center text-xs">
                <div className="bg-black/20 rounded-xl p-2">
                  <span className="text-[10px] text-emerald-200 block uppercase font-bold">Just1Cash</span>
                  <span className="font-black text-white text-sm">₹150</span>
                </div>
                <div className="bg-black/20 rounded-xl p-2">
                  <span className="text-[10px] text-emerald-200 block uppercase font-bold">Total Orders</span>
                  <span className="font-black text-white text-sm">{orders.length}</span>
                </div>
                <div className="bg-black/20 rounded-xl p-2">
                  <span className="text-[10px] text-emerald-200 block uppercase font-bold">SLA Guarantee</span>
                  <span className="font-black text-yellow-300 text-sm">&lt; 24h</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-gray-50 border border-gray-200 rounded-3xl p-5 text-center space-y-3">
              <User className="w-10 h-10 text-gray-400 mx-auto" />
              <div>
                <h3 className="text-sm font-bold text-gray-900">You are currently logged out</h3>
                <p className="text-xs text-gray-500 mt-0.5">Log in with your mobile number or Google to access your profile</p>
              </div>
              {onOpenAuthModal && (
                <button
                  onClick={() => {
                    onClose();
                    onOpenAuthModal();
                  }}
                  className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-colors cursor-pointer"
                >
                  Log In / Create Account
                </button>
              )}
            </div>
          )}

          {/* Edit Profile Form (if toggled) */}
          {isEditing && currentUser && (
            <form onSubmit={handleSave} className="bg-emerald-50/70 border border-emerald-200 rounded-2xl p-4 space-y-3">
              <h4 className="text-xs font-black text-emerald-950 uppercase tracking-wider">
                Update Profile Information
              </h4>
              <div>
                <label className="text-xs font-bold text-gray-700 block mb-1">Full Name</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl bg-white focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                  required
                />
              </div>
              <div>
                <label className="text-xs font-bold text-gray-700 block mb-1">Email Address</label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="yourname@gmail.com"
                  className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl bg-white focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                />
              </div>
              <div className="flex justify-end gap-2 pt-1">
                <button
                  type="button"
                  onClick={() => setIsEditing(false)}
                  className="px-3 py-1.5 text-xs font-bold text-gray-600 hover:bg-gray-100 rounded-xl cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs cursor-pointer flex items-center gap-1"
                >
                  <Check className="w-3.5 h-3.5" />
                  <span>Save Changes</span>
                </button>
              </div>
            </form>
          )}

          {/* Account Links & Settings Options */}
          <div className="space-y-2">
            <h4 className="text-xs font-black text-gray-500 uppercase tracking-wider px-1">
              Account & Addresses
            </h4>

            {/* Manage Addresses */}
            <button
              onClick={() => {
                onClose();
                onOpenAddressModal();
              }}
              className="w-full flex items-center justify-between p-3.5 rounded-2xl bg-gray-50 hover:bg-gray-100 border border-gray-200 transition-colors text-left cursor-pointer group"
            >
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center">
                  <MapPin className="w-4 h-4" />
                </div>
                <div>
                  <h5 className="text-xs font-bold text-gray-900 group-hover:text-emerald-800">
                    Saved Delivery Addresses
                  </h5>
                  <p className="text-[11px] text-gray-500">
                    Current: <strong>{currentAddress.title}</strong> · {currentAddress.address}
                  </p>
                </div>
              </div>
              <span className="text-xs font-bold text-emerald-700 bg-emerald-50 px-2 py-1 rounded-lg">
                Change
              </span>
            </button>

            {/* GPS Pin */}
            {onOpenMapPicker && (
              <button
                onClick={() => {
                  onClose();
                  onOpenMapPicker();
                }}
                className="w-full flex items-center justify-between p-3.5 rounded-2xl bg-gray-50 hover:bg-gray-100 border border-gray-200 transition-colors text-left cursor-pointer group"
              >
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl bg-blue-100 text-blue-800 flex items-center justify-center">
                    <MapPin className="w-4 h-4" />
                  </div>
                  <div>
                    <h5 className="text-xs font-bold text-gray-900 group-hover:text-blue-800">
                      Live Map GPS Pinning
                    </h5>
                    <p className="text-[11px] text-gray-500">
                      Pin accurate doorstep location for fast 8-min dispatch
                    </p>
                  </div>
                </div>
                <span className="text-xs font-bold text-blue-700 bg-blue-50 px-2 py-1 rounded-lg">
                  Open Map
                </span>
              </button>
            )}

            {/* Order History */}
            <button
              onClick={() => {
                onClose();
                onViewOrders();
              }}
              className="w-full flex items-center justify-between p-3.5 rounded-2xl bg-gray-50 hover:bg-gray-100 border border-gray-200 transition-colors text-left cursor-pointer group"
            >
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-amber-100 text-amber-900 flex items-center justify-center">
                  <ShoppingBag className="w-4 h-4" />
                </div>
                <div>
                  <h5 className="text-xs font-bold text-gray-900 group-hover:text-amber-800">
                    Order History & Live Tracking
                  </h5>
                  <p className="text-[11px] text-gray-500">
                    View active dispatches and past receipts ({orders.length} orders recorded)
                  </p>
                </div>
              </div>
              <span className="text-xs font-bold text-amber-900 bg-amber-50 px-2 py-1 rounded-lg">
                View Orders
              </span>
            </button>
          </div>

          {/* CLEAR LOGOUT SECTION */}
          {currentUser && (
            <div className="pt-2 border-t border-gray-100">
              {showLogoutConfirm ? (
                <div className="bg-red-50 border-2 border-red-300 rounded-2xl p-4 space-y-3 animate-in fade-in">
                  <div className="flex items-start gap-2.5">
                    <AlertCircle className="w-5 h-5 text-red-600 shrink-0 mt-0.5" />
                    <div>
                      <h4 className="text-xs font-bold text-red-950">Confirm Log Out?</h4>
                      <p className="text-[11px] text-red-700 mt-0.5">
                        You will be signed out from this device. You can log back in at any time with your mobile number.
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center justify-end gap-2 pt-1">
                    <button
                      type="button"
                      onClick={() => setShowLogoutConfirm(false)}
                      className="px-3.5 py-1.5 text-xs font-bold text-gray-600 hover:bg-gray-200 bg-white border border-gray-200 rounded-xl cursor-pointer"
                    >
                      Cancel
                    </button>
                    <button
                      type="button"
                      onClick={handleConfirmLogout}
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
                  className="w-full flex items-center justify-center gap-2 p-3.5 bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 rounded-2xl text-xs font-bold transition-colors cursor-pointer"
                >
                  <LogOut className="w-4 h-4" />
                  <span>Log Out of Just1Shop</span>
                </button>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default UserDetailsModal;
