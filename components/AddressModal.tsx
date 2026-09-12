import React, { useState } from 'react';
import { MapPin, Check, Plus, Navigation, X, Home, Briefcase, Heart } from 'lucide-react';
import type { Address } from '../types';

interface AddressModalProps {
  isOpen: boolean;
  onClose: () => void;
  addresses: Address[];
  currentAddress: Address;
  onSelectAddress: (address: Address) => void;
  onAddNewAddress: (address: Address) => void;
  onOpenMapPicker?: () => void;
}

const AddressModal: React.FC<AddressModalProps> = ({
  isOpen,
  onClose,
  addresses,
  currentAddress,
  onSelectAddress,
  onAddNewAddress,
  onOpenMapPicker,
}) => {
  const [isAddingNew, setIsAddingNew] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newAddressLine, setNewAddressLine] = useState('');
  const [newLandmark, setNewLandmark] = useState('');
  const [newTag, setNewTag] = useState<'home' | 'work' | 'other'>('home');
  const [isDetectingLocation, setIsDetectingLocation] = useState(false);

  if (!isOpen) return null;

  const handleUseCurrentLocation = () => {
    setIsDetectingLocation(true);
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setIsDetectingLocation(false);
          const detectedAddr: Address = {
            id: `addr-${Date.now()}`,
            title: 'Current GPS Location',
            addressLine: `Lat: ${position.coords.latitude.toFixed(4)}, Long: ${position.coords.longitude.toFixed(4)} - Sector 4, QuickMart Hub`,
            landmark: 'Near Current Device GPS',
            tag: 'other',
            isDefault: true,
          };
          onAddNewAddress(detectedAddr);
          onSelectAddress(detectedAddr);
          onClose();
        },
        () => {
          setIsDetectingLocation(false);
          // Fallback simulation for preview container
          const fallbackAddr: Address = {
            id: `addr-${Date.now()}`,
            title: 'Detected GPS Location',
            addressLine: 'Avenue 21, 100ft Inner Ring Road, Koramangala 4th Block',
            landmark: 'Near Sony World Signal',
            tag: 'other',
            isDefault: true,
          };
          onAddNewAddress(fallbackAddr);
          onSelectAddress(fallbackAddr);
          onClose();
        }
      );
    } else {
      setIsDetectingLocation(false);
    }
  };

  const handleSaveNewAddress = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim() || !newAddressLine.trim()) return;

    const newAddr: Address = {
      id: `addr-${Date.now()}`,
      title: newTitle.trim(),
      addressLine: newAddressLine.trim(),
      landmark: newLandmark.trim() || undefined,
      tag: newTag,
      isDefault: false,
    };

    onAddNewAddress(newAddr);
    onSelectAddress(newAddr);
    setIsAddingNew(false);
    setNewTitle('');
    setNewAddressLine('');
    setNewLandmark('');
    onClose();
  };

  const getTagIcon = (tag: 'home' | 'work' | 'other') => {
    switch (tag) {
      case 'home':
        return <Home className="w-4 h-4 text-emerald-600" />;
      case 'work':
        return <Briefcase className="w-4 h-4 text-blue-600" />;
      default:
        return <Heart className="w-4 h-4 text-amber-600" />;
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs animate-in fade-in duration-200">
      <div 
        className="bg-white rounded-3xl max-w-md w-full shadow-2xl overflow-hidden border border-gray-100 animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div className="p-4 sm:p-5 border-b border-gray-100 flex items-center justify-between">
          <div>
            <h3 className="text-base sm:text-lg font-bold text-gray-900">
              Select Delivery Location
            </h3>
            <p className="text-xs text-gray-500">Order gets assigned to your nearest dark store</p>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-gray-400 hover:text-gray-700 hover:bg-gray-100 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-4 sm:p-5 max-h-[70vh] overflow-y-auto space-y-3">
          {/* Interactive Map Pin Button (New Geolocation Feature) */}
          {onOpenMapPicker && (
            <button
              onClick={() => {
                onClose();
                onOpenMapPicker();
              }}
              className="w-full flex items-center justify-between p-3 rounded-2xl border-2 border-emerald-600 bg-gradient-to-r from-emerald-600 to-teal-700 text-white transition-all shadow-sm hover:shadow-md cursor-pointer text-left group active:scale-98"
            >
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center shadow-xs">
                  <MapPin className="w-5 h-5 text-yellow-300 fill-yellow-300" />
                </div>
                <div>
                  <span className="text-xs font-black block text-white flex items-center gap-1.5">
                    Drop Pin on Interactive Map
                    <span className="bg-yellow-400 text-gray-900 text-[9px] font-black px-1.5 py-0.2 rounded-full uppercase">
                      Instant
                    </span>
                  </span>
                  <span className="text-[11px] text-emerald-100">Drag pin & auto-detect Dark Store 8-min ETA</span>
                </div>
              </div>
              <span className="text-xs font-black text-yellow-300 underline group-hover:translate-x-0.5 transition-transform">
                Open Map →
              </span>
            </button>
          )}

          {/* GPS Locate Button */}
          <button
            onClick={handleUseCurrentLocation}
            disabled={isDetectingLocation}
            className="w-full flex items-center justify-between p-3 rounded-2xl border border-emerald-200 bg-emerald-50/70 hover:bg-emerald-100/70 text-emerald-800 transition-colors cursor-pointer text-left"
          >
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl bg-emerald-600 text-white flex items-center justify-center shadow-xs">
                <Navigation className={`w-4 h-4 ${isDetectingLocation ? 'animate-spin' : ''}`} />
              </div>
              <div>
                <span className="text-xs font-bold block">
                  {isDetectingLocation ? 'Locating device...' : 'Detect My Current Location'}
                </span>
                <span className="text-[11px] text-emerald-700">Using GPS coordinates for 8-min routing</span>
              </div>
            </div>
            <span className="text-xs font-bold text-emerald-700">Auto-detect</span>
          </button>

          {/* Saved Addresses List */}
          <div className="pt-2">
            <span className="text-[11px] font-bold uppercase text-gray-400 tracking-wider block mb-2 px-1">
              Saved Addresses
            </span>
            <div className="space-y-2">
              {addresses.map((addr) => {
                const isSelected = addr.id === currentAddress.id;
                return (
                  <div
                    key={addr.id}
                    onClick={() => {
                      onSelectAddress(addr);
                      onClose();
                    }}
                    className={`flex items-start justify-between p-3 rounded-2xl border transition-all cursor-pointer ${
                      isSelected
                        ? 'border-emerald-600 bg-emerald-50/40 ring-1 ring-emerald-500'
                        : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                    }`}
                  >
                    <div className="flex items-start gap-3">
                      <div className="mt-0.5 p-2 rounded-xl bg-gray-100">
                        {getTagIcon(addr.tag)}
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h4 className="text-xs font-bold text-gray-900">{addr.title}</h4>
                          <span className="text-[10px] font-semibold uppercase px-1.5 py-0.2 rounded bg-gray-100 text-gray-600">
                            {addr.tag}
                          </span>
                        </div>
                        <p className="text-xs text-gray-600 mt-0.5 leading-tight">{addr.addressLine}</p>
                        {addr.landmark && (
                          <p className="text-[11px] text-gray-400 mt-0.5">Landmark: {addr.landmark}</p>
                        )}
                      </div>
                    </div>
                    {isSelected && (
                      <div className="w-5 h-5 rounded-full bg-emerald-600 text-white flex items-center justify-center shrink-0 mt-1">
                        <Check className="w-3 h-3" />
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Add New Address Form / Trigger */}
          {!isAddingNew ? (
            <button
              onClick={() => setIsAddingNew(true)}
              className="w-full py-2.5 px-3 rounded-2xl border border-dashed border-gray-300 hover:border-emerald-500 hover:bg-emerald-50/30 text-emerald-700 font-bold text-xs flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
            >
              <Plus className="w-4 h-4" />
              <span>Add New Delivery Address</span>
            </button>
          ) : (
            <form onSubmit={handleSaveNewAddress} className="p-3 bg-gray-50 rounded-2xl border border-gray-200 space-y-2.5">
              <h4 className="text-xs font-bold text-gray-800">Add New Address</h4>
              
              <div className="grid grid-cols-3 gap-1.5">
                {(['home', 'work', 'other'] as const).map((tag) => (
                  <button
                    type="button"
                    key={tag}
                    onClick={() => setNewTag(tag)}
                    className={`py-1 text-xs font-semibold rounded-lg capitalize border ${
                      newTag === tag ? 'bg-emerald-600 text-white border-emerald-600' : 'bg-white text-gray-700 border-gray-200'
                    }`}
                  >
                    {tag}
                  </button>
                ))}
              </div>

              <input
                type="text"
                placeholder="Address Label (e.g., Home, Office, Gym)"
                value={newTitle}
                onChange={(e) => setNewTitle(e.target.value)}
                className="w-full text-xs p-2.5 bg-white border border-gray-200 rounded-xl focus:border-emerald-500 focus:outline-none"
                required
              />

              <textarea
                placeholder="Complete Address (Flat / House no, Building, Street, Area)"
                value={newAddressLine}
                onChange={(e) => setNewAddressLine(e.target.value)}
                rows={2}
                className="w-full text-xs p-2.5 bg-white border border-gray-200 rounded-xl focus:border-emerald-500 focus:outline-none"
                required
              />

              <input
                type="text"
                placeholder="Nearby Landmark (Optional)"
                value={newLandmark}
                onChange={(e) => setNewLandmark(e.target.value)}
                className="w-full text-xs p-2.5 bg-white border border-gray-200 rounded-xl focus:border-emerald-500 focus:outline-none"
              />

              <div className="flex gap-2 pt-1">
                <button
                  type="button"
                  onClick={() => setIsAddingNew(false)}
                  className="flex-1 py-1.5 text-xs font-semibold text-gray-600 bg-gray-200 rounded-xl hover:bg-gray-300"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-1.5 text-xs font-bold text-white bg-emerald-600 rounded-xl hover:bg-emerald-700"
                >
                  Save Address
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};

export default AddressModal;
