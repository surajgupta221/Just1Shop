import React, { useState } from 'react';
import { 
  Sparkles, 
  Plus, 
  Trash2, 
  Edit2, 
  Check, 
  X, 
  Eye, 
  EyeOff, 
  Tag, 
  Flame, 
  Award, 
  RotateCcw,
  Palette
} from 'lucide-react';
import type { PromoBanner, PromoBannerTheme } from '../types';

interface BannerManagementTabProps {
  banners: PromoBanner[];
  onUpdateBanners: (updated: PromoBanner[]) => void;
}

const THEME_PRESETS: {
  theme: PromoBannerTheme;
  label: string;
  gradient: string;
  emoji: string;
  bgPreview: string;
}[] = [
  {
    theme: 'durga_puja',
    label: '🌸 Durga Puja / Navratri (Crimson & Gold)',
    gradient: 'from-red-900 via-rose-800 to-amber-900',
    emoji: '🪔',
    bgPreview: 'bg-gradient-to-r from-red-900 via-rose-800 to-amber-900',
  },
  {
    theme: 'diwali',
    label: '🪔 Diwali Dhamaka (Golden Amber & Violet)',
    gradient: 'from-amber-600 via-yellow-600 to-purple-900',
    emoji: '✨',
    bgPreview: 'bg-gradient-to-r from-amber-600 via-yellow-600 to-purple-900',
  },
  {
    theme: 'exclusive',
    label: '👑 Company Exclusive (Royal Indigo & Deep Slate)',
    gradient: 'from-purple-950 via-indigo-900 to-slate-900',
    emoji: '💎',
    bgPreview: 'bg-gradient-to-r from-purple-950 via-indigo-900 to-slate-900',
  },
  {
    theme: 'winner_sale',
    label: '🏆 Winner Sale (High-Energy Orange & Fire Red)',
    gradient: 'from-amber-600 via-orange-600 to-red-700',
    emoji: '⚡',
    bgPreview: 'bg-gradient-to-r from-amber-600 via-orange-600 to-red-700',
  },
  {
    theme: 'monsoon',
    label: '🌧️ Monsoon / Rain Deals (Cyan & Emerald)',
    gradient: 'from-teal-800 via-cyan-800 to-emerald-900',
    emoji: '☕',
    bgPreview: 'bg-gradient-to-r from-teal-800 via-cyan-800 to-emerald-900',
  },
  {
    theme: 'mega_deals',
    label: '🛍️ Weekend Mega Mart (Emerald & Lime Zepto style)',
    gradient: 'from-emerald-800 via-teal-700 to-green-800',
    emoji: '🥦',
    bgPreview: 'bg-gradient-to-r from-emerald-800 via-teal-700 to-green-800',
  },
];

const BannerManagementTab: React.FC<BannerManagementTabProps> = ({
  banners,
  onUpdateBanners,
}) => {
  const [editingBannerId, setEditingBannerId] = useState<string | null>(null);
  const [isAddingNew, setIsAddingNew] = useState<boolean>(false);

  // Form state for creating or editing
  const [formState, setFormState] = useState<Partial<PromoBanner>>({
    title: '',
    subtitle: '',
    badge: '🌸 FESTIVE DEAL',
    discountText: 'FLAT 50% OFF',
    couponCode: 'FESTIVE50',
    ctaText: 'Shop Festive Deals',
    bannerType: 'festive',
    theme: 'durga_puja',
    gradient: 'from-red-900 via-rose-800 to-amber-900',
    emojiIcon: '🪔',
    isActive: true,
    validUntil: 'Limited Festive Period',
  });

  const handleToggleActive = (id: string) => {
    onUpdateBanners(
      banners.map((b) => (b.id === id ? { ...b, isActive: !b.isActive } : b))
    );
  };

  const handleDelete = (id: string) => {
    if (banners.length <= 1) {
      alert('You must keep at least 1 banner in the system.');
      return;
    }
    onUpdateBanners(banners.filter((b) => b.id !== id));
    if (editingBannerId === id) {
      setEditingBannerId(null);
    }
  };

  const handleStartEdit = (banner: PromoBanner) => {
    setEditingBannerId(banner.id);
    setIsAddingNew(false);
    setFormState({ ...banner });
  };

  const handleStartAdd = () => {
    setIsAddingNew(true);
    setEditingBannerId(null);
    setFormState({
      id: `banner-${Date.now()}`,
      title: 'Durga Puja Maha Utsav Sale',
      subtitle: 'Special 50% discount on Sweets, Dry Fruits, Fresh Ghee & Puja Samagri',
      badge: '🌸 DURGA PUJA SPECIAL',
      discountText: 'FLAT 50% OFF',
      couponCode: 'PUJA50',
      ctaText: 'Shop Festive Deals',
      bannerType: 'festive',
      theme: 'durga_puja',
      gradient: 'from-red-900 via-rose-800 to-amber-900',
      emojiIcon: '🪔',
      isActive: true,
      priority: banners.length + 1,
      validUntil: 'Live for Festive Week',
    });
  };

  const handleApplyPreset = (presetKey: 'durga_puja' | 'diwali' | 'exclusive' | 'winner') => {
    if (presetKey === 'durga_puja') {
      setFormState((prev) => ({
        ...prev,
        title: 'Durga Puja Maha Utsav Sale',
        subtitle: 'Special 50% discount on Sweets, Dry Fruits, Fresh Ghee & Puja Samagri',
        badge: '🌸 DURGA PUJA SPECIAL',
        discountText: 'FLAT 50% OFF',
        couponCode: 'PUJA50',
        ctaText: 'Shop Festive Deals',
        bannerType: 'festive',
        theme: 'durga_puja',
        gradient: 'from-red-900 via-rose-800 to-amber-900',
        emojiIcon: '🪔',
        validUntil: 'Live for Festive Week',
      }));
    } else if (presetKey === 'diwali') {
      setFormState((prev) => ({
        ...prev,
        title: 'Diwali Dhamaka Super Mega Sale',
        subtitle: 'Huge savings on dry fruit gift boxes, mithai, diyas & gourmet chocolates',
        badge: '🪔 DIWALI DHAMAKA',
        discountText: 'FLAT 40% OFF + EXTRA CASHBACK',
        couponCode: 'DIWALI40',
        ctaText: 'Shop Diwali Specials',
        bannerType: 'festive',
        theme: 'diwali',
        gradient: 'from-amber-600 via-yellow-600 to-purple-900',
        emojiIcon: '✨',
        validUntil: 'Diwali Festival Rush',
      }));
    } else if (presetKey === 'exclusive') {
      setFormState((prev) => ({
        ...prev,
        title: 'Company Exclusive Member Sale',
        subtitle: 'VIP member access: Premium imported fruits, cold-pressed oils & gourmet cheeses',
        badge: '👑 COMPANY EXCLUSIVE',
        discountText: 'EXTRA 35% SAVINGS',
        couponCode: 'EXCLUSIVE35',
        ctaText: 'Claim Member Offers',
        bannerType: 'exclusive',
        theme: 'exclusive',
        gradient: 'from-purple-950 via-indigo-900 to-slate-900',
        emojiIcon: '💎',
        validUntil: 'Just1Shop Members Only',
      }));
    } else if (presetKey === 'winner') {
      setFormState((prev) => ({
        ...prev,
        title: 'Grand Winner Super Saver',
        subtitle: 'Stock up your kitchen pantry with double cashback & 100% price match guarantee',
        badge: '🏆 WINNER SALE',
        discountText: 'UP TO 60% OFF',
        couponCode: 'WINNER100',
        ctaText: 'Grab Winner Deals',
        bannerType: 'sale',
        theme: 'winner_sale',
        gradient: 'from-amber-600 via-orange-600 to-red-700',
        emojiIcon: '⚡',
        validUntil: 'Limited Stock Rush',
      }));
    }
  };

  const handleSaveForm = () => {
    if (!formState.title?.trim() || !formState.discountText?.trim()) {
      alert('Please provide a banner title and discount text.');
      return;
    }

    if (isAddingNew) {
      const newBanner: PromoBanner = {
        id: formState.id || `banner-${Date.now()}`,
        title: formState.title || 'Special Festive Offer',
        subtitle: formState.subtitle || 'Shop fresh groceries delivered in 8 minutes',
        badge: formState.badge || 'PROMO SALE',
        discountText: formState.discountText || 'SPECIAL OFFER',
        couponCode: formState.couponCode,
        ctaText: formState.ctaText || 'Shop Deals',
        bannerType: formState.bannerType || 'festive',
        theme: formState.theme || 'durga_puja',
        gradient: formState.gradient || 'from-red-900 via-rose-800 to-amber-900',
        emojiIcon: formState.emojiIcon || '✨',
        isActive: formState.isActive !== undefined ? formState.isActive : true,
        priority: banners.length + 1,
        validUntil: formState.validUntil || 'Limited Period',
      };
      onUpdateBanners([...banners, newBanner]);
      setIsAddingNew(false);
    } else if (editingBannerId) {
      onUpdateBanners(
        banners.map((b) =>
          b.id === editingBannerId
            ? {
                ...b,
                ...formState,
              } as PromoBanner
            : b
        )
      );
      setEditingBannerId(null);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Info & Add Button */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 rounded-2xl p-4">
        <div>
          <h3 className="text-sm font-black text-gray-900 flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-amber-600" />
            <span>Festive & Sale Banner Management System</span>
          </h3>
          <p className="text-xs text-gray-600 mt-0.5">
            Create and toggle dynamic promotional banners for <strong>Durga Puja Sale</strong>, <strong>Company Exclusive</strong>, <strong>Winner Sale</strong>, and seasonal events. Active banners display right at the top of the storefront.
          </p>
        </div>

        <button
          onClick={handleStartAdd}
          className="bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs px-3.5 py-2 rounded-xl flex items-center gap-1.5 shadow-xs transition-colors cursor-pointer shrink-0"
        >
          <Plus className="w-4 h-4" />
          <span>Add New Sale Banner</span>
        </button>
      </div>

      {/* Editor or Creator Form (if open) */}
      {(isAddingNew || editingBannerId) && (
        <div className="bg-white border-2 border-amber-400 rounded-2xl p-4 sm:p-5 shadow-sm space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-gray-100">
            <h4 className="text-sm font-black text-gray-900 flex items-center gap-2">
              <Palette className="w-4 h-4 text-amber-600" />
              <span>{isAddingNew ? 'Create New Festive / Sale Banner' : 'Edit Banner Details'}</span>
            </h4>
            <button
              onClick={() => {
                setIsAddingNew(false);
                setEditingBannerId(null);
              }}
              className="p-1 text-gray-400 hover:text-gray-600 rounded-lg cursor-pointer"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Quick Preset Buttons */}
          <div>
            <span className="text-[11px] font-bold text-gray-500 uppercase tracking-wider block mb-1.5">
              1-Click Festive & Sale Presets:
            </span>
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => handleApplyPreset('durga_puja')}
                className="bg-red-50 hover:bg-red-100 text-red-900 border border-red-200 text-xs font-bold px-3 py-1.5 rounded-lg transition-colors cursor-pointer flex items-center gap-1"
              >
                <span>🌸 Durga Puja Sale</span>
              </button>
              <button
                type="button"
                onClick={() => handleApplyPreset('diwali')}
                className="bg-amber-50 hover:bg-amber-100 text-amber-900 border border-amber-200 text-xs font-bold px-3 py-1.5 rounded-lg transition-colors cursor-pointer flex items-center gap-1"
              >
                <span>🪔 Diwali Dhamaka</span>
              </button>
              <button
                type="button"
                onClick={() => handleApplyPreset('exclusive')}
                className="bg-indigo-50 hover:bg-indigo-100 text-indigo-900 border border-indigo-200 text-xs font-bold px-3 py-1.5 rounded-lg transition-colors cursor-pointer flex items-center gap-1"
              >
                <span>👑 Company Exclusive</span>
              </button>
              <button
                type="button"
                onClick={() => handleApplyPreset('winner')}
                className="bg-orange-50 hover:bg-orange-100 text-orange-900 border border-orange-200 text-xs font-bold px-3 py-1.5 rounded-lg transition-colors cursor-pointer flex items-center gap-1"
              >
                <span>🏆 Winner Super Sale</span>
              </button>
            </div>
          </div>

          {/* Live Preview Card */}
          <div>
            <span className="text-[11px] font-bold text-gray-500 uppercase tracking-wider block mb-1.5">
              Live Banner Preview:
            </span>
            <div className={`rounded-2xl p-4 text-white bg-gradient-to-r ${formState.gradient} shadow-xs relative overflow-hidden`}>
              <div className="absolute right-3 bottom-1 text-6xl opacity-30 select-none pointer-events-none">
                {formState.emojiIcon}
              </div>
              <div className="relative z-10 flex items-center gap-2 mb-1.5">
                <span className="bg-white/20 backdrop-blur-xs text-[10px] font-black px-2.5 py-0.5 rounded-full border border-white/30 uppercase">
                  {formState.badge || 'SPECIAL SALE'}
                </span>
                <span className="bg-amber-400 text-gray-950 text-[10px] font-black px-2 py-0.5 rounded">
                  {formState.discountText || '50% OFF'}
                </span>
              </div>
              <h5 className="text-base sm:text-lg font-black">{formState.title || 'Banner Title'}</h5>
              <p className="text-xs text-white/90 mt-0.5">{formState.subtitle || 'Banner offer description goes here'}</p>
              <div className="flex items-center gap-2 mt-3 text-xs font-bold">
                {formState.couponCode && (
                  <span className="bg-black/30 border border-white/30 px-2 py-0.5 rounded-md font-mono text-yellow-300">
                    CODE: {formState.couponCode}
                  </span>
                )}
                <span className="bg-white text-gray-950 px-2.5 py-0.5 rounded-md font-bold text-[11px]">
                  {formState.ctaText || 'Shop Now'} →
                </span>
              </div>
            </div>
          </div>

          {/* Form Inputs Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
            <div>
              <label className="text-xs font-bold text-gray-700 block mb-1">
                Banner Headline Title *
              </label>
              <input
                type="text"
                value={formState.title || ''}
                onChange={(e) => setFormState({ ...formState, title: e.target.value })}
                placeholder="e.g. Durga Puja Maha Utsav Sale"
                className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-amber-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-gray-700 block mb-1">
                Discount Highlight Badge *
              </label>
              <input
                type="text"
                value={formState.discountText || ''}
                onChange={(e) => setFormState({ ...formState, discountText: e.target.value })}
                placeholder="e.g. FLAT 50% OFF or UP TO 60% OFF"
                className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-amber-500 focus:outline-none"
              />
            </div>

            <div className="sm:col-span-2">
              <label className="text-xs font-bold text-gray-700 block mb-1">
                Offer Subtitle & Details
              </label>
              <input
                type="text"
                value={formState.subtitle || ''}
                onChange={(e) => setFormState({ ...formState, subtitle: e.target.value })}
                placeholder="e.g. Massive discounts on sweets, puja essentials, dry fruits & fresh ghee"
                className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-amber-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-gray-700 block mb-1">
                Festive Tag / Pill Text
              </label>
              <input
                type="text"
                value={formState.badge || ''}
                onChange={(e) => setFormState({ ...formState, badge: e.target.value })}
                placeholder="e.g. 🌸 DURGA PUJA SPECIAL"
                className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-amber-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-gray-700 block mb-1">
                Coupon Code (Optional)
              </label>
              <input
                type="text"
                value={formState.couponCode || ''}
                onChange={(e) => setFormState({ ...formState, couponCode: e.target.value.toUpperCase() })}
                placeholder="e.g. PUJA50 or EXCLUSIVE35"
                className="w-full text-xs font-mono font-bold uppercase px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-amber-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-gray-700 block mb-1">
                Color Theme & Background Gradient
              </label>
              <select
                value={formState.theme || 'durga_puja'}
                onChange={(e) => {
                  const selectedTheme = e.target.value as PromoBannerTheme;
                  const found = THEME_PRESETS.find((p) => p.theme === selectedTheme);
                  setFormState({
                    ...formState,
                    theme: selectedTheme,
                    gradient: found ? found.gradient : formState.gradient,
                    emojiIcon: found ? found.emoji : formState.emojiIcon,
                  });
                }}
                className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl bg-white focus:ring-2 focus:ring-amber-500 focus:outline-none cursor-pointer"
              >
                {THEME_PRESETS.map((preset) => (
                  <option key={preset.theme} value={preset.theme}>
                    {preset.label}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="text-xs font-bold text-gray-700 block mb-1">
                CTA Button Text
              </label>
              <input
                type="text"
                value={formState.ctaText || ''}
                onChange={(e) => setFormState({ ...formState, ctaText: e.target.value })}
                placeholder="e.g. Shop Festive Deals"
                className="w-full text-xs font-medium px-3 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-amber-500 focus:outline-none"
              />
            </div>
          </div>

          <div className="flex items-center justify-end gap-2 pt-3 border-t border-gray-100">
            <button
              type="button"
              onClick={() => {
                setIsAddingNew(false);
                setEditingBannerId(null);
              }}
              className="px-3.5 py-1.5 border border-gray-200 text-gray-600 text-xs font-bold rounded-xl hover:bg-gray-50 transition-colors cursor-pointer"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleSaveForm}
              className="px-4 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-colors cursor-pointer flex items-center gap-1.5"
            >
              <Check className="w-4 h-4" />
              <span>{isAddingNew ? 'Publish Festive Banner' : 'Save Changes'}</span>
            </button>
          </div>
        </div>
      )}

      {/* List of Configured Banners */}
      <div className="space-y-3">
        <div className="flex items-center justify-between text-xs font-bold text-gray-500 px-1">
          <span>Configured Promotional Banners ({banners.length})</span>
          <span className="text-emerald-700">
            {banners.filter((b) => b.isActive).length} Currently Live on App
          </span>
        </div>

        <div className="grid grid-cols-1 gap-3">
          {banners.map((banner) => (
            <div
              key={banner.id}
              className={`border rounded-2xl p-4 transition-all ${
                banner.isActive 
                  ? 'bg-white border-gray-200 shadow-2xs' 
                  : 'bg-gray-50/70 border-gray-200 opacity-60'
              }`}
            >
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="flex items-start gap-3">
                  {/* Banner color dot / theme swatch */}
                  <div className={`w-12 h-12 rounded-xl bg-gradient-to-r ${banner.gradient} text-white flex items-center justify-center text-xl shrink-0 shadow-xs`}>
                    {banner.emojiIcon || '✨'}
                  </div>

                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <h4 className="text-sm font-black text-gray-900">{banner.title}</h4>
                      <span className="bg-amber-100 text-amber-950 text-[10px] font-bold px-2 py-0.5 rounded">
                        {banner.discountText}
                      </span>
                      {banner.couponCode && (
                        <span className="bg-gray-100 text-gray-700 text-[10px] font-mono font-bold px-1.5 py-0.5 rounded">
                          {banner.couponCode}
                        </span>
                      )}
                    </div>

                    <p className="text-xs text-gray-500 mt-1 max-w-xl">
                      {banner.subtitle}
                    </p>

                    <div className="flex items-center gap-2 mt-2 text-[11px] text-gray-400">
                      <span className="font-semibold text-gray-600">{banner.badge}</span>
                      <span>·</span>
                      <span>Button: "{banner.ctaText}"</span>
                      {banner.validUntil && (
                        <>
                          <span>·</span>
                          <span>{banner.validUntil}</span>
                        </>
                      )}
                    </div>
                  </div>
                </div>

                {/* Actions: Toggle Active, Edit, Delete */}
                <div className="flex items-center gap-2 self-end sm:self-center shrink-0">
                  <button
                    onClick={() => handleToggleActive(banner.id)}
                    className={`px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-colors cursor-pointer ${
                      banner.isActive
                        ? 'bg-emerald-50 text-emerald-800 border border-emerald-300 hover:bg-emerald-100'
                        : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                    }`}
                    title={banner.isActive ? 'Hide banner from storefront' : 'Show banner on storefront'}
                  >
                    {banner.isActive ? (
                      <>
                        <Eye className="w-3.5 h-3.5 text-emerald-600" />
                        <span>Live on Store</span>
                      </>
                    ) : (
                      <>
                        <EyeOff className="w-3.5 h-3.5 text-gray-500" />
                        <span>Hidden</span>
                      </>
                    )}
                  </button>

                  <button
                    onClick={() => handleStartEdit(banner)}
                    className="p-2 text-gray-600 hover:text-amber-700 hover:bg-amber-50 rounded-xl border border-gray-200 transition-colors cursor-pointer"
                    title="Edit banner content & discount"
                  >
                    <Edit2 className="w-3.5 h-3.5" />
                  </button>

                  <button
                    onClick={() => handleDelete(banner.id)}
                    className="p-2 text-gray-400 hover:text-red-700 hover:bg-red-50 rounded-xl border border-gray-200 transition-colors cursor-pointer"
                    title="Delete banner"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default BannerManagementTab;
