import React, { useState, useEffect, useRef } from 'react';
import { 
  MapPin, 
  Navigation, 
  Check, 
  X, 
  Home, 
  Briefcase, 
  Heart, 
  Store, 
  Zap, 
  Compass, 
  Crosshair, 
  Search, 
  Layers
} from 'lucide-react';
import type { Address } from '../types';
import { DARK_STORE_HUBS } from '../constants';

interface MapAddressPickerProps {
  isOpen: boolean;
  onClose: () => void;
  currentAddress: Address;
  onConfirmAddress: (address: Address) => void;
}

interface CoordinatePreset {
  name: string;
  area: string;
  city: string;
  coords: { lat: number; lng: number };
  nearestHubId: string;
}

const PRESET_LOCATIONS: CoordinatePreset[] = [
  {
    name: 'Green Glen Heights, Bellandur',
    area: 'Bellandur Outer Ring Road',
    city: 'Bengaluru 560103',
    coords: { lat: 12.9260, lng: 77.6762 },
    nearestHubId: 'hub-01'
  },
  {
    name: '100ft Road, Indiranagar',
    area: 'Indiranagar 2nd Stage',
    city: 'Bengaluru 560038',
    coords: { lat: 12.9780, lng: 77.6400 },
    nearestHubId: 'hub-02'
  },
  {
    name: 'Sony World Signal, Koramangala',
    area: 'Koramangala 4th Block',
    city: 'Bengaluru 560034',
    coords: { lat: 12.9348, lng: 77.6250 },
    nearestHubId: 'hub-03'
  },
  {
    name: 'ITPL Main Road, Whitefield',
    area: 'Whitefield EPIP Zone',
    city: 'Bengaluru 560066',
    coords: { lat: 12.9698, lng: 77.7499 },
    nearestHubId: 'hub-04'
  },
  {
    name: '27th Main, HSR Layout',
    area: 'HSR Layout Sector 1',
    city: 'Bengaluru 560102',
    coords: { lat: 12.9121, lng: 77.6446 },
    nearestHubId: 'hub-03'
  }
];

export const MapAddressPicker: React.FC<MapAddressPickerProps> = ({
  isOpen,
  onClose,
  currentAddress,
  onConfirmAddress,
}) => {
  // Map Pin Coordinates
  const [coords, setCoords] = useState<{ lat: number; lng: number }>({
    lat: currentAddress.latitude || 12.9260,
    lng: currentAddress.longitude || 77.6762,
  });

  // Relative pin position on canvas (percentage 0 - 100)
  const [pinOffset, setPinOffset] = useState<{ x: number; y: number }>({ x: 50, y: 50 });
  const [isLocating, setIsLocating] = useState<boolean>(false);
  const [mapStyle, setMapStyle] = useState<'standard' | 'satellite'>('standard');

  // Form Fields
  const [addressTitle, setAddressTitle] = useState<string>(currentAddress.title || 'Home');
  const [houseNo, setHouseNo] = useState<string>(currentAddress.houseNumber || 'Flat 402, Tower B');
  const [floorBuilding, setFloorBuilding] = useState<string>(currentAddress.floorBuilding || 'Green Glen Heights');
  const [streetArea, setStreetArea] = useState<string>(currentAddress.addressLine || 'Bellandur Outer Ring Road');
  const [landmark, setLandmark] = useState<string>(currentAddress.landmark || 'Opposite Central Park');
  const [tag, setTag] = useState<'home' | 'work' | 'other'>(currentAddress.tag || 'home');

  const mapContainerRef = useRef<HTMLDivElement>(null);

  // Sync with current address when opened
  useEffect(() => {
    if (isOpen) {
      if (currentAddress.latitude && currentAddress.longitude) {
        setCoords({ lat: currentAddress.latitude, lng: currentAddress.longitude });
      }
      setAddressTitle(currentAddress.title || 'Home');
      setStreetArea(currentAddress.addressLine || 'Bellandur Outer Ring Road');
      setLandmark(currentAddress.landmark || '');
      setTag(currentAddress.tag || 'home');
      if (currentAddress.houseNumber) setHouseNo(currentAddress.houseNumber);
      if (currentAddress.floorBuilding) setFloorBuilding(currentAddress.floorBuilding);
    }
  }, [isOpen, currentAddress]);

  if (!isOpen) return null;

  // Calculate nearest dark store and distance in KM
  const calculateNearestStore = (lat: number, lng: number) => {
    let nearest = DARK_STORE_HUBS[0];
    let minDistance = 99999;

    DARK_STORE_HUBS.forEach((hub) => {
      // Euclidean approximate distance in km (1 deg lat ~ 111km, 1 deg lng ~ 108km)
      const dLat = (hub.coordinates.lat - lat) * 111;
      const dLng = (hub.coordinates.lng - lng) * 108;
      const dist = Math.sqrt(dLat * dLat + dLng * dLng);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = hub;
      }
    });

    const distanceKm = Number(Math.max(0.4, minDistance).toFixed(1));
    const etaMinutes = Math.min(20, Math.max(6, Math.round(nearest.baseEtaMinutes + distanceKm * 1.8)));

    return { nearestHub: nearest, distanceKm, etaMinutes };
  };

  const { nearestHub, distanceKm, etaMinutes } = calculateNearestStore(coords.lat, coords.lng);

  // Handle interactive click/drop on the map surface
  const handleMapClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!mapContainerRef.current) return;
    const rect = mapContainerRef.current.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const clickY = e.clientY - rect.top;

    const percentX = Math.min(95, Math.max(5, (clickX / rect.width) * 100));
    const percentY = Math.min(95, Math.max(5, (clickY / rect.height) * 100));

    setPinOffset({ x: percentX, y: percentY });

    // Derive lat/lng delta from center (50%, 50%)
    const latDelta = ((50 - percentY) / 50) * 0.015;
    const lngDelta = ((percentX - 50) / 50) * 0.018;

    const newLat = Number((coords.lat + latDelta).toFixed(4));
    const newLng = Number((coords.lng + lngDelta).toFixed(4));

    setCoords({ lat: newLat, lng: newLng });
    setStreetArea(`Pin Location near ${nearestHub.name.split(' ')[0]} Sector (Coord: ${newLat}, ${newLng})`);
  };

  // Device Geolocation Trigger
  const handleUseDeviceGps = () => {
    setIsLocating(true);
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setIsLocating(false);
          const newLat = Number(position.coords.latitude.toFixed(4));
          const newLng = Number(position.coords.longitude.toFixed(4));
          setCoords({ lat: newLat, lng: newLng });
          setPinOffset({ x: 50, y: 50 });
          setStreetArea(`GPS Verified Location: Lat ${newLat}, Lng ${newLng}`);
          setLandmark('Detected Device Sensor GPS');
        },
        () => {
          setIsLocating(false);
          // Fallback simulation for iframe sandboxes
          const simulated = PRESET_LOCATIONS[0];
          setCoords(simulated.coords);
          setPinOffset({ x: 50, y: 50 });
          setStreetArea(`${simulated.name}, ${simulated.area}`);
          setLandmark('Near Main Metro Station');
        },
        { enableHighAccuracy: true, timeout: 5000 }
      );
    } else {
      setIsLocating(false);
    }
  };

  const handleSelectPreset = (preset: CoordinatePreset) => {
    setCoords(preset.coords);
    setPinOffset({ x: 50, y: 50 });
    setStreetArea(`${preset.name}, ${preset.area}`);
    setFloorBuilding(preset.name);
    setLandmark(`Near ${preset.area.split(' ')[0]} Market`);
  };

  const handleSaveAndConfirm = (e: React.FormEvent) => {
    e.preventDefault();
    const fullAddress = `${houseNo ? houseNo + ', ' : ''}${floorBuilding ? floorBuilding + ', ' : ''}${streetArea}`;

    const confirmedAddr: Address = {
      id: `addr-pin-${Date.now()}`,
      title: addressTitle || 'Delivered Location',
      addressLine: fullAddress,
      landmark: landmark || undefined,
      tag: tag,
      isDefault: true,
      latitude: coords.lat,
      longitude: coords.lng,
      coordinates: coords,
      etaMinutes: etaMinutes,
      distanceKm: distanceKm,
      darkStoreName: `Dark Store (${nearestHub.name})`,
      houseNumber: houseNo,
      floorBuilding: floorBuilding
    };

    onConfirmAddress(confirmedAddr);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div 
        className="bg-white rounded-3xl max-w-2xl w-full shadow-2xl overflow-hidden border border-gray-100 flex flex-col max-h-[92vh] animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div className="p-4 border-b border-gray-100 flex items-center justify-between bg-white shrink-0">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-emerald-600 text-white flex items-center justify-center shadow-xs">
              <Compass className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-base font-bold text-gray-900 leading-tight">
                Drop Pin on Delivery Map
              </h3>
              <p className="text-xs text-gray-500">
                Click or drag pin anywhere to get hyper-precise 8-min routing
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-gray-400 hover:text-gray-700 hover:bg-gray-100 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Content: Scrollable Body */}
        <div className="overflow-y-auto flex-grow p-4 sm:p-5 space-y-4">
          
          {/* Quick Hotspot Preset Chips */}
          <div>
            <span className="text-[11px] font-bold uppercase text-gray-400 tracking-wider block mb-1.5">
              Popular Quick-Commerce Delivery Zones:
            </span>
            <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-1">
              {PRESET_LOCATIONS.map((preset, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => handleSelectPreset(preset)}
                  className="px-2.5 py-1 text-xs font-semibold rounded-lg bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 text-gray-700 shrink-0 transition-colors border border-transparent hover:border-emerald-200 cursor-pointer"
                >
                  📍 {preset.area.split(' ')[0]}
                </button>
              ))}
            </div>
          </div>

          {/* Interactive Map Visualizer Surface */}
          <div className="relative rounded-2xl overflow-hidden border-2 border-emerald-500/40 shadow-inner bg-slate-900 h-64 sm:h-72 select-none group">
            
            {/* Map Canvas Background with simulated roads & dark store radar */}
            <div
              ref={mapContainerRef}
              onClick={handleMapClick}
              className={`w-full h-full cursor-crosshair relative transition-all duration-300 ${
                mapStyle === 'satellite' 
                  ? 'bg-gradient-to-br from-slate-950 via-slate-900 to-emerald-950' 
                  : 'bg-[#e5e3df]'
              }`}
            >
              {/* Map Road Grid Lines */}
              <svg className="w-full h-full absolute inset-0 opacity-40 pointer-events-none" xmlns="http://www.w3.org/2000/svg">
                <defs>
                  <pattern id="grid-pattern" width="40" height="40" patternUnits="userSpaceOnUse">
                    <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#cbd5e1" strokeWidth="1" />
                  </pattern>
                </defs>
                <rect width="100%" height="100%" fill="url(#grid-pattern)" />
                {/* Major Arterial Roads */}
                <line x1="0" y1="120" x2="100%" y2="150" stroke="#fef08a" strokeWidth="6" />
                <line x1="140" y1="0" x2="180" y2="100%" stroke="#ffffff" strokeWidth="5" />
                <line x1="280" y1="0" x2="310" y2="100%" stroke="#ffffff" strokeWidth="4" />
                <line x1="0" y1="210" x2="100%" y2="190" stroke="#ffffff" strokeWidth="5" />
                {/* Green Park Patch */}
                <circle cx="80" cy="60" r="45" fill="#bbf7d0" opacity="0.6" />
                <rect x="360" y="80" width="90" height="70" rx="8" fill="#bbf7d0" opacity="0.6" />
              </svg>

              {/* Nearest Dark Store Hub Icon on Map */}
              <div 
                className="absolute top-8 left-8 flex flex-col items-center pointer-events-none z-10 animate-pulse"
                title={nearestHub.name}
              >
                <div className="w-8 h-8 rounded-full bg-emerald-700 text-white flex items-center justify-center shadow-lg border-2 border-white">
                  <Store className="w-4 h-4" />
                </div>
                <span className="mt-1 bg-emerald-900/90 text-white text-[9px] font-bold px-1.5 py-0.5 rounded shadow-xs whitespace-nowrap">
                  {nearestHub.name.split(' ')[0]} Hub
                </span>
                {/* 5km Radius Radial Circle */}
                <div className="absolute -inset-14 rounded-full border border-emerald-500/40 pointer-events-none"></div>
              </div>

              {/* Dynamic Dropped Pin Marker */}
              <div 
                style={{
                  left: `${pinOffset.x}%`,
                  top: `${pinOffset.y}%`,
                  transform: 'translate(-50%, -100%)'
                }}
                className="absolute pointer-events-none z-20 flex flex-col items-center transition-all duration-150"
              >
                <div className="relative">
                  {/* Pin Wave Radar */}
                  <span className="animate-ping absolute -bottom-1 -left-2 inline-flex h-8 w-8 rounded-full bg-rose-500 opacity-60"></span>
                  {/* Pin Body */}
                  <div className="w-10 h-10 rounded-full bg-rose-600 text-white flex items-center justify-center shadow-xl border-2 border-white ring-2 ring-rose-300">
                    <MapPin className="w-6 h-6 fill-rose-600 text-white" />
                  </div>
                </div>
                {/* Floating Tag */}
                <div className="bg-gray-900/90 text-white text-[10px] font-bold px-2 py-0.5 rounded-full shadow-md mt-1 whitespace-nowrap flex items-center gap-1 border border-gray-700">
                  <Zap className="w-2.5 h-2.5 text-yellow-400 fill-current" />
                  <span>Deliver Here ({etaMinutes}m)</span>
                </div>
              </div>

              {/* Instruction Banner at top of map */}
              <div className="absolute top-2.5 right-2.5 z-10 flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setMapStyle(mapStyle === 'standard' ? 'satellite' : 'standard')}
                  className="px-2 py-1 bg-white/90 backdrop-blur-xs text-gray-700 rounded-lg text-[10px] font-bold shadow-xs hover:bg-white flex items-center gap-1 cursor-pointer"
                >
                  <Layers className="w-3 h-3 text-emerald-600" />
                  <span>{mapStyle === 'standard' ? 'Satellite' : 'Street Map'}</span>
                </button>
              </div>

              {/* "Locate Me" GPS Center Button on Map */}
              <button
                type="button"
                onClick={handleUseDeviceGps}
                disabled={isLocating}
                className="absolute bottom-3 right-3 z-10 p-2.5 bg-white text-emerald-700 rounded-xl shadow-md hover:bg-emerald-50 active:scale-95 transition-all border border-gray-200 cursor-pointer flex items-center gap-1.5 text-xs font-bold"
                title="Locate device with GPS"
              >
                <Crosshair className={`w-4 h-4 ${isLocating ? 'animate-spin text-emerald-600' : ''}`} />
                <span className="hidden xs:inline">Locate Me</span>
              </button>
            </div>

            {/* Bottom Floating Coordinate Bar */}
            <div className="absolute bottom-2.5 left-2.5 z-10 bg-white/95 backdrop-blur-xs px-2.5 py-1 rounded-xl shadow-sm border border-gray-200 text-[10px] font-mono text-gray-700 flex items-center gap-2">
              <span className="text-emerald-700 font-bold">GPS:</span>
              <span>{coords.lat.toFixed(4)}° N, {coords.lng.toFixed(4)}° E</span>
              <span className="text-gray-300">|</span>
              <span className="text-rose-600 font-bold">{distanceKm} km from Hub</span>
            </div>
          </div>

          {/* Real-time Dark Store Routing Info Pill */}
          <div className="p-3 bg-emerald-50 rounded-2xl border border-emerald-200 flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-xl bg-emerald-600 text-white flex items-center justify-center shrink-0 shadow-2xs">
                <Zap className="w-4 h-4 fill-current" />
              </div>
              <div>
                <p className="text-xs font-black text-emerald-900">
                  Assigned Dark Store: {nearestHub.name}
                </p>
                <p className="text-[11px] text-emerald-700">
                  Calculated Delivery ETA: <strong className="text-emerald-900">{etaMinutes} Minutes</strong> ({distanceKm} km radial road distance)
                </p>
              </div>
            </div>
            <span className="text-[10px] font-black text-white bg-emerald-700 px-2 py-0.5 rounded-full uppercase tracking-wide">
              {nearestHub.code}
            </span>
          </div>

          {/* Address Details Confirmation Form */}
          <form onSubmit={handleSaveAndConfirm} className="space-y-3 pt-1">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-gray-900">Address Details</span>
              {/* Address Tag Selector */}
              <div className="flex items-center gap-1.5">
                {(['home', 'work', 'other'] as const).map((t) => (
                  <button
                    type="button"
                    key={t}
                    onClick={() => setTag(t)}
                    className={`px-2.5 py-0.5 rounded-lg text-xs font-bold capitalize transition-all cursor-pointer flex items-center gap-1 border ${
                      tag === t
                        ? 'bg-emerald-600 text-white border-emerald-600 shadow-2xs'
                        : 'bg-gray-100 text-gray-700 border-gray-200 hover:bg-gray-200'
                    }`}
                  >
                    {t === 'home' && <Home className="w-3 h-3" />}
                    {t === 'work' && <Briefcase className="w-3 h-3" />}
                    {t === 'other' && <Heart className="w-3 h-3" />}
                    <span>{t}</span>
                  </button>
                ))}
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              <div>
                <label className="block text-[11px] font-bold text-gray-500 uppercase tracking-wider mb-1">
                  House / Flat / Floor No. *
                </label>
                <input
                  type="text"
                  value={houseNo}
                  onChange={(e) => setHouseNo(e.target.value)}
                  placeholder="e.g., Flat 402, 4th Floor"
                  className="w-full text-xs p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:border-emerald-500 focus:outline-none"
                  required
                />
              </div>

              <div>
                <label className="block text-[11px] font-bold text-gray-500 uppercase tracking-wider mb-1">
                  Apartment / Building / Society *
                </label>
                <input
                  type="text"
                  value={floorBuilding}
                  onChange={(e) => setFloorBuilding(e.target.value)}
                  placeholder="e.g., Green Glen Heights"
                  className="w-full text-xs p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:border-emerald-500 focus:outline-none"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-bold text-gray-500 uppercase tracking-wider mb-1">
                Street / Area (Auto-filled from Pin) *
              </label>
              <input
                type="text"
                value={streetArea}
                onChange={(e) => setStreetArea(e.target.value)}
                placeholder="Street address"
                className="w-full text-xs p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:border-emerald-500 focus:outline-none font-medium"
                required
              />
            </div>

            <div>
              <label className="block text-[11px] font-bold text-gray-500 uppercase tracking-wider mb-1">
                Landmark / Directions for Rider (Optional)
              </label>
              <input
                type="text"
                value={landmark}
                onChange={(e) => setLandmark(e.target.value)}
                placeholder="e.g., Near Sony World Signal, opposite ICICI Bank"
                className="w-full text-xs p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:border-emerald-500 focus:outline-none"
              />
            </div>

            {/* Confirm Button */}
            <div className="pt-2">
              <button
                type="submit"
                id="confirm-pin-address-btn"
                className="w-full py-3 px-4 rounded-xl bg-emerald-600 hover:bg-emerald-700 active:scale-98 text-white font-black text-sm tracking-wide shadow-md transition-all flex items-center justify-center gap-2 cursor-pointer"
              >
                <Check className="w-4 h-4" />
                <span>Confirm Pin & Set Delivery Location</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default MapAddressPicker;
