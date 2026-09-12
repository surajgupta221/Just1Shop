import React, { useState } from 'react';
import { Zap, Clock, Navigation, ChevronDown, ChevronUp, ShieldCheck, AlertCircle, CloudRain, Bike, Store } from 'lucide-react';
import type { Address } from '../types';

interface RealTimeEtaTrackerProps {
  currentAddress: Address;
  onOpenMapPicker: () => void;
  trafficCondition?: 'normal' | 'rush' | 'rain';
  onTrafficConditionChange?: (condition: 'normal' | 'rush' | 'rain') => void;
}

export const RealTimeEtaTracker: React.FC<RealTimeEtaTrackerProps> = ({
  currentAddress,
  onOpenMapPicker,
  trafficCondition = 'normal',
  onTrafficConditionChange,
}) => {
  const [isExpanded, setIsExpanded] = useState<boolean>(false);
  const [internalTraffic, setInternalTraffic] = useState<'normal' | 'rush' | 'rain'>(trafficCondition);

  const activeTraffic = onTrafficConditionChange ? trafficCondition : internalTraffic;

  const handleTrafficSelect = (mode: 'normal' | 'rush' | 'rain') => {
    if (onTrafficConditionChange) {
      onTrafficConditionChange(mode);
    } else {
      setInternalTraffic(mode);
    }
  };

  // Base ETA calculation derived from distance or stored address ETA
  const baseMinutes = currentAddress.etaMinutes || 8;
  const distance = currentAddress.distanceKm ? `${currentAddress.distanceKm} km` : '1.1 km';
  const darkStore = currentAddress.darkStoreName || 'Dark Store #04 (Bellandur Hub)';

  // Surge adjustments
  let surgePenalty = 0;
  let surgeLabel = 'Normal Traffic';
  if (activeTraffic === 'rush') {
    surgePenalty = 3;
    surgeLabel = 'Peak Rush Hour (+3m)';
  } else if (activeTraffic === 'rain') {
    surgePenalty = 7;
    surgeLabel = 'Monsoon Rain Surge (+7m)';
  }

  const computedEtaMin = baseMinutes + surgePenalty;
  const computedEtaMax = computedEtaMin + 3;

  return (
    <div 
      id="real-time-eta-tracker-banner"
      className="bg-gradient-to-r from-emerald-900 via-emerald-800 to-teal-900 text-white border-b border-emerald-700/50 shadow-sm transition-all duration-300"
    >
      <div className="max-w-7xl mx-auto px-3 sm:px-4 lg:px-6 py-2 sm:py-2.5">
        <div className="flex flex-wrap items-center justify-between gap-2 sm:gap-4">
          
          {/* Left: Dynamic Live Pulse + Real-Time ETA Tag */}
          <div className="flex items-center gap-2.5">
            <div className="relative flex items-center justify-center">
              <span className="animate-ping absolute inline-flex h-4 w-4 rounded-full bg-emerald-400 opacity-75"></span>
              <div className="w-6 h-6 rounded-full bg-emerald-500 flex items-center justify-center text-white shadow-xs">
                <Zap className="w-3.5 h-3.5 fill-current" />
              </div>
            </div>

            <div className="flex flex-col sm:flex-row sm:items-center gap-0.5 sm:gap-2">
              <div className="flex items-center gap-1.5">
                <span className="font-black text-sm sm:text-base text-yellow-300 tracking-tight flex items-center gap-1">
                  Delivery in {computedEtaMin}-{computedEtaMax} Mins
                </span>
                <span className="text-[10px] bg-emerald-700/80 text-emerald-200 font-bold px-1.5 py-0.5 rounded border border-emerald-600/60 uppercase">
                  Live GPS
                </span>
              </div>

              <span className="text-emerald-300/60 hidden sm:inline">|</span>

              <div className="flex items-center gap-1 text-[11px] text-emerald-100 font-medium">
                <Store className="w-3 h-3 text-emerald-300 shrink-0" />
                <span className="truncate max-w-[210px] sm:max-w-[300px]">
                  {darkStore} · {distance} away
                </span>
              </div>
            </div>
          </div>

          {/* Right: Map Pin Action & Live Surge Simulation Toggle */}
          <div className="flex items-center gap-2 sm:gap-3 ml-auto">
            {/* Quick Pin on Map Button */}
            <button
              id="eta-banner-pin-map-btn"
              onClick={onOpenMapPicker}
              className="flex items-center gap-1.5 px-2.5 py-1 text-xs font-bold bg-white/10 hover:bg-white/20 text-white rounded-lg border border-white/20 transition-all active:scale-95 cursor-pointer shadow-xs"
              title="Open Smart Map Pinning"
            >
              <Navigation className="w-3 h-3 text-yellow-400" />
              <span className="hidden xs:inline">Pin Exact Location</span>
              <span className="xs:hidden">Pin Map</span>
            </button>

            {/* Toggle Dispatch Breakdown */}
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="flex items-center gap-1 text-[11px] font-semibold text-emerald-200 hover:text-white px-1.5 py-1 rounded transition-colors cursor-pointer"
            >
              <span>{isExpanded ? 'Hide Info' : 'Rider Info'}</span>
              {isExpanded ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
            </button>
          </div>
        </div>

        {/* Expandable Live Dark Store & Routing Intelligence Panel */}
        {isExpanded && (
          <div className="mt-2.5 pt-2.5 border-t border-emerald-700/60 grid grid-cols-1 md:grid-cols-3 gap-3 text-xs animate-in fade-in duration-200">
            {/* Step 1: Dark Store Speed */}
            <div className="bg-emerald-950/40 rounded-xl p-2.5 border border-emerald-700/40 flex items-start gap-2.5">
              <div className="p-1.5 rounded-lg bg-emerald-800/80 text-yellow-300">
                <Clock className="w-4 h-4" />
              </div>
              <div>
                <p className="font-bold text-white text-[11px]">Dark Store Packing</p>
                <p className="text-[10px] text-emerald-200">Bagger dispatch queue: &lt; 90 seconds. 18 active pickers.</p>
              </div>
            </div>

            {/* Step 2: Rider Assigned */}
            <div className="bg-emerald-950/40 rounded-xl p-2.5 border border-emerald-700/40 flex items-start gap-2.5">
              <div className="p-1.5 rounded-lg bg-emerald-800/80 text-emerald-300">
                <Bike className="w-4 h-4" />
              </div>
              <div>
                <p className="font-bold text-white text-[11px]">Direct Rider Route</p>
                <p className="text-[10px] text-emerald-200">
                  {distance} radial distance. Dedicated EV courier pre-assigned.
                </p>
              </div>
            </div>

            {/* Step 3: Traffic / Surge Simulator */}
            <div className="bg-emerald-950/40 rounded-xl p-2.5 border border-emerald-700/40">
              <div className="flex items-center justify-between mb-1.5">
                <span className="text-[10px] font-bold text-emerald-300 uppercase tracking-wider">
                  Condition Simulator:
                </span>
                <span className="text-[10px] text-yellow-300 font-semibold">{surgeLabel}</span>
              </div>
              <div className="grid grid-cols-3 gap-1">
                <button
                  type="button"
                  onClick={() => handleTrafficSelect('normal')}
                  className={`px-1.5 py-1 text-[10px] font-bold rounded-lg transition-all text-center cursor-pointer ${
                    activeTraffic === 'normal'
                      ? 'bg-emerald-500 text-white shadow-xs'
                      : 'bg-emerald-900/60 text-emerald-200 hover:bg-emerald-800'
                  }`}
                >
                  ⚡ Fast
                </button>
                <button
                  type="button"
                  onClick={() => handleTrafficSelect('rush')}
                  className={`px-1.5 py-1 text-[10px] font-bold rounded-lg transition-all text-center cursor-pointer ${
                    activeTraffic === 'rush'
                      ? 'bg-amber-500 text-gray-950 shadow-xs'
                      : 'bg-emerald-900/60 text-emerald-200 hover:bg-emerald-800'
                  }`}
                >
                  🚗 Rush
                </button>
                <button
                  type="button"
                  onClick={() => handleTrafficSelect('rain')}
                  className={`px-1.5 py-1 text-[10px] font-bold rounded-lg transition-all text-center cursor-pointer ${
                    activeTraffic === 'rain'
                      ? 'bg-cyan-500 text-gray-950 shadow-xs'
                      : 'bg-emerald-900/60 text-emerald-200 hover:bg-emerald-800'
                  }`}
                >
                  🌧️ Rain
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default RealTimeEtaTracker;
