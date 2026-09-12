import React from 'react';
import { X, Globe, CheckCircle2, Search, ExternalLink, Sparkles, Star } from 'lucide-react';

interface GoogleSearchPreviewModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const GoogleSearchPreviewModal: React.FC<GoogleSearchPreviewModalProps> = ({
  isOpen,
  onClose,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/60 backdrop-blur-xs">
      <div 
        className="bg-white rounded-3xl max-w-2xl w-full shadow-2xl overflow-hidden border border-gray-100 animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 border-b border-gray-100 flex items-center justify-between bg-gray-50">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-blue-600 text-white flex items-center justify-center">
              <Globe className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-base font-bold text-gray-900">
                Google Search (SERP) & SEO Preview
              </h3>
              <p className="text-xs text-gray-500">
                How Just1Shop appears when customers search on Google
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-gray-400 hover:text-gray-700 hover:bg-gray-200 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-5 sm:p-6 space-y-6">
          {/* Simulated Google Search Bar */}
          <div className="flex items-center gap-3 px-4 py-2.5 rounded-full border border-gray-200 shadow-xs bg-white">
            <span className="font-bold text-blue-600 tracking-tight text-sm">Google</span>
            <div className="flex items-center gap-2 text-xs text-gray-800 flex-grow">
              <Search className="w-3.5 h-3.5 text-gray-400" />
              <span>online grocery delivery just1shop</span>
            </div>
          </div>

          {/* Google SERP Snippet Card */}
          <div className="p-4 rounded-2xl bg-white border border-gray-200 shadow-sm space-y-2">
            {/* Breadcrumb & Site Info */}
            <div className="flex items-center gap-2 text-xs text-gray-700">
              <div className="w-6 h-6 rounded-full bg-emerald-700 text-white font-black text-[10px] flex items-center justify-center">
                J1
              </div>
              <div className="flex flex-col">
                <span className="text-xs font-semibold text-gray-900 leading-none">Just1Shop</span>
                <span className="text-[11px] text-gray-500 leading-none mt-0.5">
                  https://just1shop.com › groceries › 8-min-delivery
                </span>
              </div>
            </div>

            {/* Main Search Result Link */}
            <h4 className="text-lg font-normal text-[#1a0dab] hover:underline cursor-pointer leading-snug">
              Just1Shop - Instant Grocery Delivery Online | Fresh Produce, Dairy & Snacks
            </h4>

            {/* Rich Snippets (Rating + Delivery Time) */}
            <div className="flex items-center gap-2 text-xs text-gray-600">
              <div className="flex items-center text-amber-500">
                <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
                <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" />
              </div>
              <span className="font-semibold text-gray-800">4.8</span>
              <span className="text-gray-400">·</span>
              <span>12,400+ reviews</span>
              <span className="text-gray-400">·</span>
              <span className="text-emerald-700 font-bold">⚡ 8 Mins Delivery</span>
              <span className="text-gray-400">·</span>
              <span>Price: $$</span>
            </div>

            {/* Meta Description */}
            <p className="text-xs sm:text-sm text-[#4d5156] leading-relaxed">
              Order fresh groceries online on <strong>Just1Shop</strong>. 8-minute delivery for fresh vegetables, fruits, dairy, bread, munchies, beverages, and daily household essentials at lowest prices. Instant doorstep service.
            </p>

            {/* Sitelinks */}
            <div className="grid grid-cols-2 gap-2 pt-2 border-t border-gray-100 text-xs">
              <div>
                <a href="#vegetables" className="text-[#1a0dab] hover:underline font-medium block">
                  Vegetables & Fruits
                </a>
                <span className="text-[11px] text-gray-500">Farm fresh organic veggies delivered daily.</span>
              </div>
              <div>
                <a href="#dairy" className="text-[#1a0dab] hover:underline font-medium block">
                  Dairy, Bread & Eggs
                </a>
                <span className="text-[11px] text-gray-500">Amul milk, artisan breads and country eggs.</span>
              </div>
              <div>
                <a href="#deals" className="text-[#1a0dab] hover:underline font-medium block">
                  Deals of the Day
                </a>
                <span className="text-[11px] text-gray-500">Up to 30% discount on quick snacks and munchies.</span>
              </div>
              <div>
                <a href="#track" className="text-[#1a0dab] hover:underline font-medium block">
                  Track Live Delivery
                </a>
                <span className="text-[11px] text-gray-500">Real-time dark store routing in 8 minutes.</span>
              </div>
            </div>
          </div>

          {/* SEO Checklist */}
          <div className="bg-emerald-50/70 border border-emerald-200 rounded-2xl p-4 text-xs space-y-2">
            <div className="flex items-center gap-1.5 text-emerald-800 font-bold">
              <CheckCircle2 className="w-4 h-4 text-emerald-600" />
              <span>Google SEO & Structured Data Implemented</span>
            </div>
            <ul className="list-disc list-inside space-y-1 text-emerald-900 text-[11px]">
              <li><strong>Schema.org JSON-LD</strong> embedded for <code className="bg-emerald-100 px-1 py-0.5 rounded font-mono">GroceryStore</code> and <code className="bg-emerald-100 px-1 py-0.5 rounded font-mono">SearchAction</code>.</li>
              <li><strong>OpenGraph & Twitter Cards</strong> configured for social sharing on WhatsApp, Twitter, and iMessage.</li>
              <li><strong>Mobile-first responsiveness</strong> configured for Google Mobile-Friendly indexation.</li>
              <li><strong>Canonical & robots</strong> tags configured for Google Search indexing.</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default GoogleSearchPreviewModal;
