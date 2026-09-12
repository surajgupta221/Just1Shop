import React from 'react';
import { 
  MapPin, 
  ChevronDown, 
  ShoppingBag, 
  Zap, 
  Globe, 
  Database,
  Navigation,
  Smartphone,
  Award,
  User,
  Bike,
  ShieldCheck,
  Eye,
  LogOut,
  Sparkles
} from 'lucide-react';
import type { Address, Product, CartItem, UserProfile, UserRole } from '../types';
import SmartSearchInput from './SmartSearchInput';

interface TopNavbarProps {
  currentAddress: Address;
  onOpenAddressModal: () => void;
  onOpenMapPicker?: () => void;
  cartItemCount: number;
  cartTotalPrice: number;
  onOpenCart: () => void;
  searchQuery: string;
  onSearchChange: (query: string) => void;
  onOpenSeoModal: () => void;
  onOpenAdminModal: () => void;
  allProducts: Product[];
  cartItems?: CartItem[];
  onAddToCart?: (product: Product) => void;
  onUpdateQuantity?: (product: Product, quantity: number) => void;
  onSelectProduct?: (product: Product) => void;
  onSelectCategory?: (category: string) => void;
  currentUser?: UserProfile | null;
  onOpenAuthModal?: () => void;
  onOpenOwnerModal?: () => void;
  onOpenApkModal?: () => void;
  onSwitchSimulatedRole?: (role: UserRole) => void;
  onOpenUserDetailsModal?: () => void;
  onLogout?: () => void;
  onOpenBannersModal?: () => void;
}

const TopNavbar: React.FC<TopNavbarProps> = ({
  currentAddress,
  onOpenAddressModal,
  onOpenMapPicker,
  cartItemCount,
  cartTotalPrice,
  onOpenCart,
  searchQuery,
  onSearchChange,
  onOpenSeoModal,
  onOpenAdminModal,
  allProducts,
  cartItems = [],
  onAddToCart,
  onUpdateQuantity,
  onSelectProduct,
  onSelectCategory,
  currentUser,
  onOpenAuthModal,
  onOpenOwnerModal,
  onOpenApkModal,
  onSwitchSimulatedRole,
  onOpenUserDetailsModal,
  onLogout,
  onOpenBannersModal,
}) => {
  const currentEta = currentAddress.etaMinutes || 8;
  const isOwner = currentUser?.role === 'owner';
  const isAdmin = currentUser?.role === 'admin' || isOwner;

  return (
    <header className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-gray-100 shadow-2xs">
      {/* Top Banner Notice: Delivery Promise + Quick Tools */}
      <div className="bg-emerald-800 text-emerald-50 text-[11px] font-medium py-1 px-3">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-1.5 overflow-hidden">
            <span className="flex h-2 w-2 relative">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-400"></span>
            </span>
            <span className="font-bold text-white tracking-wide">LIGHTNING DELIVERY:</span>
            <span className="truncate">Instant {currentEta}-minute grocery doorstep service in your area</span>
          </div>
          <div className="hidden sm:flex items-center gap-3">
            {/* Download Mobile APK Guide Button */}
            {onOpenApkModal && (
              <button
                onClick={onOpenApkModal}
                className="hover:text-yellow-300 flex items-center gap-1 transition-colors cursor-pointer text-white font-bold"
                title="Download or Install Just1Shop Android App / APK"
              >
                <Smartphone className="w-3.5 h-3.5 text-yellow-300" />
                <span>📱 Android App / APK</span>
              </button>
            )}
            <span className="text-emerald-600">|</span>

            {/* Owner Hub shortcut if user is owner */}
            {isOwner && onOpenOwnerModal && (
              <>
                <button
                  onClick={onOpenOwnerModal}
                  className="bg-amber-400 hover:bg-amber-300 text-gray-950 px-2 py-0.5 rounded-md font-black text-[10px] flex items-center gap-1 transition-colors cursor-pointer shadow-2xs"
                  title="Manage Staff Roles, Dark Store Location and Delivery Radius (km)"
                >
                  <Award className="w-3 h-3 text-amber-900" />
                  <span>Owner Command Center</span>
                </button>
                <span className="text-emerald-600">|</span>
              </>
            )}

            {/* Admin / Owner: Festive Sale Banners shortcut */}
            {isAdmin && onOpenBannersModal && (
              <>
                <button
                  onClick={onOpenBannersModal}
                  className="bg-gradient-to-r from-red-600 to-amber-600 hover:from-red-500 hover:to-amber-500 text-white px-2 py-0.5 rounded-md font-black text-[10px] flex items-center gap-1 transition-colors cursor-pointer shadow-2xs"
                  title="Manage Festive & Sale Banners (Durga Puja, Company Exclusive, Winner Sale)"
                >
                  <Sparkles className="w-3 h-3 text-yellow-200" />
                  <span>Festive Banners</span>
                </button>
                <span className="text-emerald-600">|</span>
              </>
            )}

            <button
              onClick={onOpenSeoModal}
              className="hover:text-white flex items-center gap-1 transition-colors cursor-pointer text-emerald-200 hover:underline"
              title="Google Search Console / SEO Preview"
            >
              <Globe className="w-3 h-3" />
              <span>Google SEO</span>
            </button>
            <span className="text-emerald-500">|</span>
            <button
              onClick={onOpenAdminModal}
              className="hover:text-white flex items-center gap-1 transition-colors cursor-pointer text-amber-300 font-bold hover:underline"
              title="Admin Inventory Controls, Pricing Verification & Storefront Publisher"
            >
              <Database className="w-3 h-3" />
              <span>Admin Inventory</span>
            </button>
          </div>
        </div>
      </div>

      {/* Main Navigation Bar */}
      <div className="max-w-7xl mx-auto px-3 sm:px-4 lg:px-6 py-2.5">
        <div className="flex items-center justify-between gap-2 sm:gap-4">
          {/* Logo & Delivery Address Locator Dropdown */}
          <div className="flex items-center gap-2 sm:gap-3 shrink-0">
            {/* Brand Logo */}
            <div className="flex flex-col cursor-pointer" onClick={() => onSearchChange('')}>
              <div className="flex items-center gap-1">
                <div className="w-7 h-7 sm:w-8 sm:h-8 rounded-xl bg-gradient-to-br from-emerald-500 to-emerald-700 flex items-center justify-center text-white font-black text-base shadow-xs">
                  J1
                </div>
                <span className="text-xl sm:text-2xl font-black tracking-tight text-gray-900 flex items-center">
                  Just<span className="text-emerald-600">1</span>Shop
                </span>
              </div>
            </div>

            {/* Address Selector Dropdown Button with Dynamic ETA */}
            <div className="hidden xs:flex items-center gap-1">
              <button
                id="address-locator-dropdown-btn"
                onClick={onOpenAddressModal}
                className="flex items-center gap-1.5 p-1.5 sm:px-2.5 sm:py-1.5 rounded-xl hover:bg-gray-100 transition-colors border border-transparent hover:border-gray-200 text-left max-w-[170px] sm:max-w-[210px] md:max-w-[240px] cursor-pointer"
                title="Change delivery address"
              >
                <div className="w-7 h-7 rounded-lg bg-emerald-50 flex items-center justify-center text-emerald-700 shrink-0">
                  <MapPin className="w-4 h-4" />
                </div>
                <div className="overflow-hidden">
                  <div className="flex items-center gap-1 text-[11px] font-bold text-gray-900 leading-tight">
                    <span className="text-emerald-700 font-extrabold flex items-center gap-0.5 whitespace-nowrap">
                      <Zap className="w-3 h-3 fill-emerald-600 text-emerald-600" />
                      {currentEta} MINS
                    </span>
                    <span className="text-gray-400">·</span>
                    <span className="truncate">{currentAddress.title}</span>
                    <ChevronDown className="w-3 h-3 text-gray-400 shrink-0 ml-0.5" />
                  </div>
                  <p className="text-[10px] text-gray-500 truncate leading-tight mt-0.5">
                    {currentAddress.addressLine}
                  </p>
                </div>
              </button>

              {/* Pin Map Icon Button */}
              {onOpenMapPicker && (
                <button
                  onClick={onOpenMapPicker}
                  className="p-1.5 rounded-lg text-emerald-700 hover:bg-emerald-50 transition-colors cursor-pointer border border-emerald-200/60 hidden sm:flex items-center gap-1 text-[11px] font-bold"
                  title="Drop pin on map"
                >
                  <Navigation className="w-3.5 h-3.5 text-emerald-600" />
                  <span className="hidden md:inline">Map</span>
                </button>
              )}
            </div>
          </div>

          {/* Smart Search Bar with Typo Auto-Correction & Instant Matches */}
          <div className="flex-grow max-w-2xl relative">
            <SmartSearchInput
              searchQuery={searchQuery}
              onSearchChange={onSearchChange}
              products={allProducts}
              cartItems={cartItems}
              onAddToCart={onAddToCart}
              onUpdateQuantity={onUpdateQuantity}
              onSelectProduct={onSelectProduct}
              onSelectCategory={onSelectCategory}
              placeholder="Search groceries, brands, vegetables, milk..."
            />
          </div>

          {/* Actions: Cart + User Profile / Login / Logout */}
          <div className="flex items-center gap-2 shrink-0">
            {/* User Account / Role Pill & Owner Role Perspective Switcher */}
            {currentUser ? (
              <div className="hidden sm:flex items-center gap-1.5">
                {/* If owner, show role dropdown without displaying personal name or number */}
                {isOwner && onSwitchSimulatedRole ? (
                  <div className="flex items-center rounded-xl border border-amber-300 bg-amber-50/90 overflow-hidden shadow-2xs">
                    <button
                      type="button"
                      onClick={onOpenOwnerModal}
                      className="flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-bold text-amber-950 hover:bg-amber-100 transition-colors cursor-pointer"
                      title="Open Owner Command Center"
                    >
                      <div className="w-5 h-5 rounded-lg bg-amber-600 flex items-center justify-center text-white text-[10px]">
                        <Award className="w-3.5 h-3.5" />
                      </div>
                      <div className="flex flex-col text-left leading-none">
                        <span className="text-[9px] uppercase font-black tracking-wider text-amber-700">
                          Role
                        </span>
                        <span className="text-xs font-black text-gray-900">
                          Owner
                        </span>
                      </div>
                    </button>

                    <div className="h-6 w-px bg-amber-200 mx-0.5" />

                    {/* Role Dropdown Selector */}
                    <select
                      value={currentUser.role}
                      onChange={(e) => onSwitchSimulatedRole(e.target.value as UserRole)}
                      className="bg-transparent text-amber-950 text-xs font-bold px-1.5 py-1.5 outline-none cursor-pointer hover:text-amber-700 transition-colors"
                      title="Select perspective: how app looks for Admin, Delivery Boy or Customer"
                    >
                      <option value="owner">👑 Owner View</option>
                      <option value="admin">🛡️ Admin View</option>
                      <option value="delivery">🛵 Delivery View</option>
                      <option value="user">🛍️ Customer View</option>
                    </select>
                  </div>
                ) : (
                  <button
                    type="button"
                    onClick={onOpenUserDetailsModal || onOpenAuthModal}
                    className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl text-xs font-bold border transition-colors cursor-pointer ${
                      currentUser.role === 'delivery'
                        ? 'bg-emerald-50 border-emerald-300 text-emerald-900 hover:bg-emerald-100'
                        : currentUser.role === 'admin'
                        ? 'bg-blue-50 border-blue-300 text-blue-900 hover:bg-blue-100'
                        : 'bg-gray-50 border-gray-200 text-gray-800 hover:bg-gray-100'
                    }`}
                    title="View Account Details & Profile"
                  >
                    <div className={`w-5 h-5 rounded-lg flex items-center justify-center text-white text-[10px] ${
                      currentUser.role === 'delivery' ? 'bg-emerald-600' : currentUser.role === 'admin' ? 'bg-blue-600' : 'bg-gray-600'
                    }`}>
                      {currentUser.role === 'delivery' ? <Bike className="w-3.5 h-3.5" /> : currentUser.role === 'admin' ? <ShieldCheck className="w-3.5 h-3.5" /> : <User className="w-3.5 h-3.5" />}
                    </div>
                    <div className="flex flex-col text-left leading-none">
                      <span className="text-[9px] uppercase font-black tracking-wider text-gray-500">
                        {currentUser.role}
                      </span>
                      <span className="text-xs font-bold text-gray-900 truncate max-w-[90px]">
                        Account
                      </span>
                    </div>
                  </button>
                )}

                {/* Direct User Details Button */}
                {onOpenUserDetailsModal && (
                  <button
                    type="button"
                    onClick={onOpenUserDetailsModal}
                    className="p-2 text-gray-600 hover:text-emerald-700 hover:bg-emerald-50 rounded-xl border border-gray-200 transition-colors cursor-pointer"
                    title="My Account & Profile Details"
                  >
                    <User className="w-4 h-4" />
                  </button>
                )}

                {/* Direct Logout Button in Navbar */}
                {onLogout && (
                  <button
                    type="button"
                    onClick={onLogout}
                    className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-xl border border-gray-200 transition-colors cursor-pointer"
                    title="Log Out"
                  >
                    <LogOut className="w-4 h-4" />
                  </button>
                )}
              </div>
            ) : (
              /* If logged out: Show clean Log In / Sign Up button */
              onOpenAuthModal && (
                <button
                  type="button"
                  onClick={onOpenAuthModal}
                  className="hidden sm:flex items-center gap-1.5 px-3 py-2 bg-emerald-50 hover:bg-emerald-100 border border-emerald-300 text-emerald-800 text-xs font-bold rounded-xl transition-colors cursor-pointer shadow-2xs"
                >
                  <User className="w-3.5 h-3.5 text-emerald-700" />
                  <span>Log In</span>
                </button>
              )
            )}

            {/* Prominent Cart Button (Blinkit / Zepto Hybrid Style) */}
            <button
              id="prominent-cart-btn"
              onClick={onOpenCart}
              className="flex items-center gap-2.5 px-3 sm:px-4 py-2 sm:py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold shadow-sm hover:shadow-md transition-all duration-150 active:scale-97 cursor-pointer group"
            >
              <div className="relative">
                <ShoppingBag className="w-5 h-5 group-hover:scale-105 transition-transform" />
                {cartItemCount > 0 && (
                  <span className="absolute -top-2 -right-2 bg-yellow-400 text-gray-950 text-[10px] font-black w-4 h-4 rounded-full flex items-center justify-center border-2 border-emerald-600 shadow-2xs animate-pulse">
                    {cartItemCount}
                  </span>
                )}
              </div>

              <div className="flex flex-col text-left leading-none">
                <span className="text-[10px] text-emerald-100 font-semibold tracking-wide uppercase">
                  {cartItemCount === 0 ? 'My Cart' : `${cartItemCount} items`}
                </span>
                <span className="text-xs sm:text-sm font-black text-white mt-0.5">
                  {cartItemCount === 0 ? 'View Cart' : `₹${cartTotalPrice}`}
                </span>
              </div>
            </button>
          </div>
        </div>

        {/* Mobile address switcher sub-bar if address was hidden */}
        <div className="xs:hidden mt-2 pt-2 border-t border-gray-100 flex items-center justify-between">
          <button
            onClick={onOpenAddressModal}
            className="flex items-center gap-1 text-xs text-gray-700 font-semibold truncate max-w-[240px]"
          >
            <MapPin className="w-3.5 h-3.5 text-emerald-600 shrink-0" />
            <span className="font-bold text-emerald-700 shrink-0">{currentEta} MINS ·</span>
            <span className="truncate">{currentAddress.title} - {currentAddress.addressLine}</span>
            <ChevronDown className="w-3 h-3 text-gray-400 shrink-0" />
          </button>
          
          <div className="flex items-center gap-2">
            {onOpenMapPicker && (
              <button
                onClick={onOpenMapPicker}
                className="text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded flex items-center gap-0.5"
              >
                <Navigation className="w-2.5 h-2.5" />
                <span>Pin</span>
              </button>
            )}
            <button
              onClick={onOpenAdminModal}
              className="text-[10px] font-bold text-amber-700 bg-amber-50 px-2 py-0.5 rounded"
            >
              Admin
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};

export default TopNavbar;
