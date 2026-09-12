import React, { useState, useEffect } from 'react';
import { 
  Sparkles, 
  Tag, 
  ChevronLeft, 
  ChevronRight, 
  Copy, 
  Check, 
  Gift, 
  Zap, 
  Edit3,
  Flame,
  ArrowRight
} from 'lucide-react';
import type { PromoBanner } from '../types';

interface FestiveBannerCarouselProps {
  banners: PromoBanner[];
  onOpenAdminBanners?: () => void;
  isAdminOrOwner?: boolean;
  onSelectCategory?: (categoryId: string) => void;
}

const FestiveBannerCarousel: React.FC<FestiveBannerCarouselProps> = ({
  banners,
  onOpenAdminBanners,
  isAdminOrOwner,
  onSelectCategory,
}) => {
  const activeBanners = banners.filter((b) => b.isActive);
  const [currentIndex, setCurrentIndex] = useState<number>(0);
  const [copiedCode, setCopiedCode] = useState<string | null>(null);

  // Auto-slide every 6 seconds if multiple banners
  useEffect(() => {
    if (activeBanners.length <= 1) return;
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % activeBanners.length);
    }, 6000);
    return () => clearInterval(interval);
  }, [activeBanners.length]);

  if (activeBanners.length === 0) return null;

  const currentBanner = activeBanners[currentIndex] || activeBanners[0];

  const handleCopyCode = (code?: string) => {
    if (!code) return;
    navigator.clipboard?.writeText(code);
    setCopiedCode(code);
    setTimeout(() => setCopiedCode(null), 2500);
  };

  const handleCtaClick = () => {
    if (onSelectCategory) {
      if (currentBanner.bannerType === 'festive') {
        onSelectCategory('munchies'); // or all
      } else {
        onSelectCategory('all');
      }
    }
  };

  return (
    <div className="relative rounded-3xl overflow-hidden shadow-md text-white transition-all duration-500">
      {/* Background Gradient Container */}
      <div 
        className={`bg-gradient-to-r ${currentBanner.gradient} p-5 sm:p-7 relative overflow-hidden transition-all duration-700 min-h-[190px] flex flex-col justify-between`}
      >
        {/* Subtle Decorative Background Pattern & Big Emoji Icon */}
        <div className="absolute right-3 -bottom-2 sm:right-8 sm:bottom-1 text-7xl sm:text-9xl opacity-25 select-none pointer-events-none transform -rotate-12 transition-transform duration-500 hover:scale-110">
          {currentBanner.emojiIcon || '✨'}
        </div>

        {/* Ambient Top Glow Ornaments */}
        <div className="absolute top-0 right-1/4 w-40 h-40 bg-white/10 rounded-full blur-2xl pointer-events-none" />

        {/* Header Row: Badge, Countdown/Tag, and Admin shortcut */}
        <div className="relative z-10 flex items-center justify-between gap-2 flex-wrap mb-2">
          <div className="flex items-center gap-2">
            <span className="inline-flex items-center gap-1.5 bg-white/20 backdrop-blur-md text-white border border-white/30 text-[11px] font-black px-3 py-1 rounded-full uppercase tracking-wider shadow-xs">
              <span className="text-sm">{currentBanner.emojiIcon}</span>
              <span>{currentBanner.badge}</span>
            </span>

            {currentBanner.validUntil && (
              <span className="hidden sm:inline-flex items-center gap-1 text-[11px] font-medium text-white/90 bg-black/20 backdrop-blur-xs px-2.5 py-0.5 rounded-full">
                <Flame className="w-3 h-3 text-amber-300" />
                <span>{currentBanner.validUntil}</span>
              </span>
            )}
          </div>

          {/* Admin Banner Quick Edit pill */}
          {isAdminOrOwner && onOpenAdminBanners && (
            <button
              onClick={onOpenAdminBanners}
              className="bg-black/30 hover:bg-black/50 text-white text-[11px] font-bold px-2.5 py-1 rounded-lg backdrop-blur-xs border border-white/20 flex items-center gap-1 transition-colors cursor-pointer"
              title="Add or Edit Festive & Promo Banners in Admin Console"
            >
              <Edit3 className="w-3 h-3 text-amber-300" />
              <span>Admin: Manage Banners ({activeBanners.length} Live)</span>
            </button>
          )}
        </div>

        {/* Banner Content Area */}
        <div className="relative z-10 max-w-xl space-y-2.5">
          <div className="flex items-center gap-2">
            <span className="bg-amber-400 text-gray-950 text-xs sm:text-sm font-black px-2.5 py-0.5 rounded-md shadow-xs">
              {currentBanner.discountText}
            </span>
          </div>

          <h2 className="text-xl sm:text-3xl lg:text-4xl font-black tracking-tight leading-tight drop-shadow-xs">
            {currentBanner.title}
          </h2>

          <p className="text-xs sm:text-sm text-white/90 font-medium max-w-lg leading-relaxed drop-shadow-2xs">
            {currentBanner.subtitle}
          </p>
        </div>

        {/* Actions Row: Coupon code pill + CTA button */}
        <div className="relative z-10 flex flex-wrap items-center gap-3 pt-3">
          {currentBanner.couponCode && (
            <button
              onClick={() => handleCopyCode(currentBanner.couponCode)}
              className="flex items-center gap-1.5 bg-black/30 hover:bg-black/40 backdrop-blur-md border border-white/30 text-white px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer group"
              title="Click to copy coupon code"
            >
              <Tag className="w-3.5 h-3.5 text-yellow-300" />
              <span>Use Code:</span>
              <span className="font-mono bg-white/20 px-1.5 py-0.5 rounded text-yellow-200 tracking-wider">
                {currentBanner.couponCode}
              </span>
              {copiedCode === currentBanner.couponCode ? (
                <span className="flex items-center gap-0.5 text-emerald-300 text-[11px]">
                  <Check className="w-3.5 h-3.5" /> Copied!
                </span>
              ) : (
                <Copy className="w-3.5 h-3.5 text-white/60 group-hover:text-white" />
              )}
            </button>
          )}

          <button
            onClick={handleCtaClick}
            className="flex items-center gap-1.5 bg-white hover:bg-gray-100 text-gray-950 text-xs sm:text-sm font-black px-4 py-1.5 sm:py-2 rounded-xl shadow-md transition-transform hover:scale-102 active:scale-98 cursor-pointer"
          >
            <span>{currentBanner.ctaText || 'Shop Festive Deals'}</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>

        {/* Carousel Slide Indicators & Prev/Next Arrows (if > 1 banner) */}
        {activeBanners.length > 1 && (
          <div className="relative z-10 flex items-center justify-between pt-4 mt-2 border-t border-white/10">
            {/* Banner tabs / dots */}
            <div className="flex items-center gap-1.5">
              {activeBanners.map((b, idx) => (
                <button
                  key={b.id}
                  onClick={() => setCurrentIndex(idx)}
                  className={`h-2 rounded-full transition-all cursor-pointer ${
                    currentIndex === idx 
                      ? 'w-6 bg-white shadow-xs' 
                      : 'w-2 bg-white/40 hover:bg-white/70'
                  }`}
                  aria-label={`Go to slide ${idx + 1}: ${b.title}`}
                  title={b.title}
                />
              ))}
            </div>

            {/* Prev / Next controls */}
            <div className="flex items-center gap-1.5">
              <button
                onClick={() => setCurrentIndex((prev) => (prev - 1 + activeBanners.length) % activeBanners.length)}
                className="w-7 h-7 rounded-full bg-black/20 hover:bg-black/40 backdrop-blur-xs flex items-center justify-center text-white transition-colors cursor-pointer"
                aria-label="Previous banner"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <span className="text-[11px] font-bold text-white/70 px-1">
                {currentIndex + 1} / {activeBanners.length}
              </span>
              <button
                onClick={() => setCurrentIndex((prev) => (prev + 1) % activeBanners.length)}
                className="w-7 h-7 rounded-full bg-black/20 hover:bg-black/40 backdrop-blur-xs flex items-center justify-center text-white transition-colors cursor-pointer"
                aria-label="Next banner"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default FestiveBannerCarousel;
