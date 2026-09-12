import React, { useState, useMemo, useEffect } from 'react';
import TopNavbar from './components/TopNavbar';
import RealTimeEtaTracker from './components/RealTimeEtaTracker';
import MapAddressPicker from './components/MapAddressPicker';
import CategoryGrid from './components/CategoryGrid';
import ProductCarousel from './components/ProductCarousel';
import ProductCard from './components/ProductCard';
import CartDrawer from './components/CartDrawer';
import BottomNavbar, { type TabType } from './components/BottomNavbar';
import AddressModal from './components/AddressModal';
import GoogleSearchPreviewModal from './components/GoogleSearchPreviewModal';
import AdminCatalogModal from './components/AdminCatalogModal';
import CategoriesView from './components/CategoriesView';
import SearchView from './components/SearchView';
import OrdersView from './components/OrdersView';
import ProfileView from './components/ProfileView';
import Footer from './components/Footer';
import AuthView from './components/AuthView';
import OwnerManagementModal from './components/OwnerManagementModal';
import ApkDownloadModal from './components/ApkDownloadModal';
import DeliveryPartnerView from './components/DeliveryPartnerView';
import FestiveBannerCarousel from './components/FestiveBannerCarousel';
import BannerManagementTab from './components/BannerManagementTab';
import UserDetailsModal from './components/UserDetailsModal';
import { PRODUCTS, INITIAL_ADDRESSES, PAST_ORDERS, INITIAL_USERS, INITIAL_STORE_SETTINGS, INITIAL_PROMO_BANNERS } from './constants';
import type { Product, CartItem, Address, Order, MasterCatalogItem, UserProfile, StoreSettings, UserRole, PromoBanner } from './types';
import { Zap, ShieldCheck, Clock, Award, Sparkles, Bike, AlertCircle, X } from 'lucide-react';

const App: React.FC = () => {
  // --- Global State ---
  const [products, setProducts] = useState<Product[]>(PRODUCTS);
  const [cartItems, setCartItems] = useState<CartItem[]>([
    { product: PRODUCTS[5], quantity: 1 }, // 1 Amul Milk
    { product: PRODUCTS[10], quantity: 1 }  // 1 Lays Magic Masala
  ]);
  const [addresses, setAddresses] = useState<Address[]>(INITIAL_ADDRESSES);
  const [currentAddress, setCurrentAddress] = useState<Address>(INITIAL_ADDRESSES[0]);
  const [orders, setOrders] = useState<Order[]>(PAST_ORDERS);
  const [trafficCondition, setTrafficCondition] = useState<'normal' | 'rush' | 'rain'>('normal');

  // --- Auth & Owner RBAC State ---
  const [users, setUsers] = useState<UserProfile[]>(INITIAL_USERS);
  // Default logged in user is the Store Owner
  const [currentUser, setCurrentUser] = useState<UserProfile>(INITIAL_USERS[0]);
  const [storeSettings, setStoreSettings] = useState<StoreSettings>(INITIAL_STORE_SETTINGS);

  // --- Promo & Festive Banners State ---
  const [banners, setBanners] = useState<PromoBanner[]>(INITIAL_PROMO_BANNERS);

  // --- Navigation & Filter State ---
  const [activeTab, setActiveTab] = useState<TabType>('home');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');

  // --- Modals State ---
  const [isCartOpen, setIsCartOpen] = useState<boolean>(false);
  const [isAddressModalOpen, setIsAddressModalOpen] = useState<boolean>(false);
  const [isMapPickerOpen, setIsMapPickerOpen] = useState<boolean>(false);
  const [isSeoModalOpen, setIsSeoModalOpen] = useState<boolean>(false);
  const [isAdminModalOpen, setIsAdminModalOpen] = useState<boolean>(false);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState<boolean>(false);
  const [isOwnerModalOpen, setIsOwnerModalOpen] = useState<boolean>(false);
  const [isApkModalOpen, setIsApkModalOpen] = useState<boolean>(false);
  const [isUserDetailsModalOpen, setIsUserDetailsModalOpen] = useState<boolean>(false);
  const [isBannersModalOpen, setIsBannersModalOpen] = useState<boolean>(false);

  // Listen for #/auth or #auth URL hash
  useEffect(() => {
    const handleHash = () => {
      const hash = window.location.hash;
      if (hash === '#/auth' || hash === '#auth') {
        setIsAuthModalOpen(true);
      }
    };
    handleHash();
    window.addEventListener('hashchange', handleHash);
    return () => window.removeEventListener('hashchange', handleHash);
  }, []);

  const handleCloseAuth = () => {
    setIsAuthModalOpen(false);
    if (window.location.hash === '#/auth' || window.location.hash === '#auth') {
      window.history.pushState('', document.title, window.location.pathname + window.location.search);
    }
  };

  const handleLoginSuccess = (user: UserProfile) => {
    setCurrentUser(user);
    // If user is updated or new, make sure it's in users list
    setUsers((prev) => {
      const idx = prev.findIndex((u) => u.id === user.id || u.phone === user.phone);
      if (idx >= 0) {
        const updated = [...prev];
        updated[idx] = user;
        return updated;
      }
      return [...prev, user];
    });
    handleCloseAuth();
    if (user.role === 'owner') {
      setIsOwnerModalOpen(true);
    }
  };

  // Owner perspective switcher (inspect how app looks for Admin, Delivery Boy, or Customer)
  const handleSwitchSimulatedRole = (targetRole: UserRole) => {
    setCurrentUser((prev) => ({
      ...prev,
      role: targetRole,
    }));
    // If switched to delivery role, switch to orders tab to show delivery dispatch view
    if (targetRole === 'delivery') {
      setActiveTab('orders');
    } else if (targetRole === 'admin') {
      setIsAdminModalOpen(true);
    }
  };

  const handleUpdateOrderStatus = (orderId: string, newStatus: 'placed' | 'packing' | 'out_for_delivery' | 'delivered') => {
    setOrders((prev) =>
      prev.map((o) => (o.id === orderId ? { ...o, status: newStatus } : o))
    );
  };

  // --- Cart Operations ---
  const handleAddToCart = (product: Product) => {
    setCartItems((prev) => {
      const existing = prev.find((item) => item.product.id === product.id);
      if (existing) {
        return prev.map((item) =>
          item.product.id === product.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      }
      return [...prev, { product, quantity: 1 }];
    });
  };

  const handleUpdateQuantity = (product: Product, quantity: number) => {
    if (quantity <= 0) {
      handleRemoveItem(product);
      return;
    }
    setCartItems((prev) =>
      prev.map((item) =>
        item.product.id === product.id ? { ...item, quantity } : item
      )
    );
  };

  const handleRemoveItem = (product: Product) => {
    setCartItems((prev) => prev.filter((item) => item.product.id !== product.id));
  };

  const cartItemCount = useMemo(() => {
    return cartItems.reduce((sum, item) => sum + item.quantity, 0);
  }, [cartItems]);

  const cartTotalPrice = useMemo(() => {
    return cartItems.reduce((sum, item) => sum + item.product.price * item.quantity, 0);
  }, [cartItems]);

  const getProductQuantity = (productId: string) => {
    const found = cartItems.find((i) => i.product.id === productId);
    return found ? found.quantity : 0;
  };

  // --- Address Handlers ---
  const handleAddNewAddress = (newAddr: Address) => {
    setAddresses((prev) => [newAddr, ...prev]);
  };

  // --- Order Placement ---
  const handlePlaceOrder = (orderTotal: number, tip: number) => {
    const newOrder: Order = {
      id: `ord-${Date.now()}`,
      orderNumber: `J1S-${Math.floor(10000 + Math.random() * 90000)}`,
      date: 'Just now',
      status: 'placed',
      total: orderTotal,
      deliveryEta: 'Arriving in 8 mins',
      paymentMethod: 'UPI / Online Fast Pay',
      address: currentAddress,
      items: [...cartItems],
    };

    setOrders((prev) => [newOrder, ...prev]);
    setCartItems([]); // Clear cart
    setActiveTab('orders'); // Switch directly to orders tracker tab
  };

  const handleReorder = (order: Order) => {
    // Append order items into current cart
    setCartItems((prev) => {
      const merged = [...prev];
      for (const orderItem of order.items) {
        const existing = merged.find((i) => i.product.id === orderItem.product.id);
        if (existing) {
          existing.quantity += orderItem.quantity;
        } else {
          merged.push({ product: orderItem.product, quantity: orderItem.quantity });
        }
      }
      return merged;
    });
    setIsCartOpen(true);
  };

  // --- Admin Catalog Publish handler (Demonstrates the NULL/0 price safeguard being unlocked and toggled live) ---
  const handlePublishFromAdmin = (
    item: MasterCatalogItem,
    sellingPrice: number,
    purchasePrice: number,
    isActive: boolean = true
  ) => {
    // Map catalog category to storefront category key
    const catLower = item.category.toLowerCase();
    let storefrontCat = 'packaged';
    if (catLower.includes('veg') || catLower.includes('fruit')) storefrontCat = 'vegetables';
    else if (catLower.includes('dairy') || catLower.includes('milk') || catLower.includes('bread') || catLower.includes('egg')) storefrontCat = 'dairy';
    else if (catLower.includes('munch') || catLower.includes('chip') || catLower.includes('snack')) storefrontCat = 'munchies';
    else if (catLower.includes('bev') || catLower.includes('drink') || catLower.includes('tea') || catLower.includes('coffee')) storefrontCat = 'beverages';
    else if (catLower.includes('clean') || catLower.includes('home')) storefrontCat = 'cleaning';
    else if (catLower.includes('care') || catLower.includes('bath')) storefrontCat = 'personal_care';

    setProducts((prev) => {
      const existingIndex = prev.findIndex((p) => p.id === item.id || p.barcode === item.barcode);

      if (!isActive) {
        // If toggled OFF, remove from storefront
        return prev.filter((p) => p.id !== item.id && p.barcode !== item.barcode);
      }

      const profitPercent = sellingPrice > 0 ? Number((((sellingPrice - purchasePrice) / sellingPrice) * 100).toFixed(2)) : 0;

      const productRecord: Product = {
        id: item.id,
        name: item.product_title,
        brand: item.brand_name,
        unit: item.weight_metric,
        price: sellingPrice,
        mrp: Math.round(sellingPrice * 1.25),
        discountPercent: Math.max(5, Math.round(profitPercent * 0.4)),
        image: item.image_url,
        category: storefrontCat,
        subcategory: item.subcategory,
        description: `Authentic ${item.brand_name} sourced freshly through master catalog wholesale pipeline.`,
        deliveryTime: '8 MINS',
        rating: 4.8,
        ratingCount: 1,
        inStock: true,
        barcode: item.barcode,
        tags: ['trending', 'deal_of_day'],
        purchase_price: purchasePrice,
        selling_price: sellingPrice,
        profit_margin_percent: profitPercent,
        is_published: true,
      };

      if (existingIndex >= 0) {
        const copy = [...prev];
        copy[existingIndex] = productRecord;
        return copy;
      } else {
        return [productRecord, ...prev];
      }
    });
  };

  // --- Filtered products for home view ---
  const trendingProducts = useMemo(() => {
    return products.filter((p) => p.tags?.includes('trending'));
  }, [products]);

  const dealsOfTheDay = useMemo(() => {
    return products.filter((p) => p.tags?.includes('deal_of_day'));
  }, [products]);

  const recentlyPurchased = useMemo(() => {
    return products.filter((p) => p.tags?.includes('recently_purchased'));
  }, [products]);

  const homeGridProducts = useMemo(() => {
    if (selectedCategory === 'all') return products;
    return products.filter((p) => p.category === selectedCategory);
  }, [products, selectedCategory]);

  const handleLogout = () => {
    const guestUser: UserProfile = {
      id: 'usr-guest-' + Date.now(),
      name: 'Guest Customer',
      phone: '',
      role: 'user',
      createdAt: new Date().toISOString(),
      isActive: true,
    };
    setCurrentUser(guestUser);
    setIsUserDetailsModalOpen(false);
  };

  const handleUpdateUserProfile = (updated: Partial<UserProfile>) => {
    if (!currentUser) return;
    const newProfile = { ...currentUser, ...updated };
    setCurrentUser(newProfile);
    setUsers((prev) => prev.map((u) => (u.id === currentUser.id ? { ...u, ...updated } : u)));
  };

  return (
    <div className="min-h-screen flex flex-col bg-gray-100 selection:bg-emerald-100 selection:text-emerald-900">
      {/* 1. Top Sticky Navigation Bar */}
      <TopNavbar
        currentAddress={currentAddress}
        onOpenAddressModal={() => setIsAddressModalOpen(true)}
        onOpenMapPicker={() => setIsMapPickerOpen(true)}
        cartItemCount={cartItemCount}
        cartTotalPrice={cartTotalPrice}
        onOpenCart={() => setIsCartOpen(true)}
        searchQuery={searchQuery}
        onSearchChange={(q) => {
          setSearchQuery(q);
          if (q.trim() && activeTab !== 'search') {
            setActiveTab('search');
          }
        }}
        onOpenSeoModal={() => setIsSeoModalOpen(true)}
        onOpenAdminModal={() => setIsAdminModalOpen(true)}
        allProducts={products}
        cartItems={cartItems}
        onAddToCart={handleAddToCart}
        onUpdateQuantity={handleUpdateQuantity}
        onSelectProduct={(product) => {
          handleAddToCart(product);
          setIsCartOpen(true);
        }}
        onSelectCategory={(catId) => {
          setSelectedCategory(catId);
          setActiveTab('categories');
        }}
        currentUser={currentUser}
        onOpenAuthModal={() => setIsAuthModalOpen(true)}
        onOpenOwnerModal={() => setIsOwnerModalOpen(true)}
        onOpenApkModal={() => setIsApkModalOpen(true)}
        onSwitchSimulatedRole={handleSwitchSimulatedRole}
        onOpenUserDetailsModal={() => setIsUserDetailsModalOpen(true)}
        onLogout={handleLogout}
        onOpenBannersModal={() => setIsBannersModalOpen(true)}
      />

      {/* Role Banner: Owner or Delivery Mode Notification */}
      {currentUser.role === 'owner' && (
        <div className="bg-amber-500 text-gray-950 px-3 py-1.5 text-xs font-bold border-b border-amber-600 shadow-2xs">
          <div className="max-w-7xl mx-auto flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Award className="w-4 h-4 text-gray-950 shrink-0" />
              <span>
                Owner Active: <strong>Store Administrator</strong> · Delivery Radius: <strong>{storeSettings.serviceRadiusKm} km</strong> (Under 24h SLA)
              </span>
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setIsBannersModalOpen(true)}
                className="bg-amber-600 hover:bg-amber-700 text-gray-950 text-[10px] font-black px-2.5 py-0.5 rounded-lg transition-colors cursor-pointer flex items-center gap-1"
                title="Manage festive sale banners"
              >
                <Sparkles className="w-3 h-3" />
                <span>Festive Banners</span>
              </button>
              <button
                onClick={() => setIsOwnerModalOpen(true)}
                className="bg-gray-950 hover:bg-gray-800 text-amber-400 text-[10px] font-black px-2.5 py-0.5 rounded-lg transition-colors cursor-pointer"
              >
                Manage Roles & Store →
              </button>
            </div>
          </div>
        </div>
      )}

      {currentUser.role === 'delivery' && (
        <div className="bg-emerald-700 text-white px-3 py-1.5 text-xs font-bold border-b border-emerald-800 shadow-2xs">
          <div className="max-w-7xl mx-auto flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Bike className="w-4 h-4 text-yellow-300 shrink-0" />
              <span>
                Delivery Mode Active: <strong>{currentUser.name}</strong> · Fulfill orders under 24 hours
              </span>
            </div>
            <button
              onClick={() => setActiveTab('orders')}
              className="bg-white hover:bg-gray-100 text-emerald-900 text-[10px] font-black px-2.5 py-0.5 rounded-lg transition-colors cursor-pointer"
            >
              View Dispatch Queue ({orders.filter(o => o.status !== 'delivered').length}) →
            </button>
          </div>
        </div>
      )}

      {/* 2. Real-Time ETA Tracker Banner (Dynamic Geolocation & Nearest Dark Store) */}
      <RealTimeEtaTracker
        currentAddress={currentAddress}
        onOpenMapPicker={() => setIsMapPickerOpen(true)}
        trafficCondition={trafficCondition}
        onTrafficConditionChange={setTrafficCondition}
      />

      {/* Main Content Area Based on Active Tab */}
      <main className="flex-grow pb-24 md:pb-12">
        {/* TAB 1: HOME */}
        {activeTab === 'home' && (
          <div className="max-w-7xl mx-auto px-3 sm:px-4 lg:px-6 py-4 space-y-6">
            {/* Quick Commerce Promo Hero Banner (Hybrid Blinkit/Zepto/Flipkart Grocery) */}
            <div className="relative rounded-3xl overflow-hidden bg-gradient-to-r from-emerald-800 via-emerald-700 to-teal-800 text-white p-5 sm:p-7 shadow-sm">
              <div className="relative z-10 max-w-xl space-y-2">
                <div className="inline-flex items-center gap-1.5 bg-yellow-400 text-gray-950 text-[11px] font-black px-2.5 py-0.5 rounded-full shadow-xs">
                  <Zap className="w-3.5 h-3.5 fill-current" />
                  <span>DARK STORE #14 ACTIVE</span>
                </div>
                <h1 className="text-2xl sm:text-3xl lg:text-4xl font-black tracking-tight leading-tight">
                  Groceries delivered in <span className="text-yellow-400 underline decoration-emerald-400">8 minutes</span>.
                </h1>
                <p className="text-xs sm:text-sm text-emerald-100 font-medium leading-relaxed">
                  Farm fresh vegetables, dairy, snacks, and chilled beverages delivered instantly to {currentAddress.title}.
                </p>

                {/* Micro Guarantee Badges */}
                <div className="pt-2 flex flex-wrap items-center gap-3 text-[11px] text-emerald-200 font-semibold">
                  <span className="flex items-center gap-1">
                    <Clock className="w-3.5 h-3.5 text-yellow-400" />
                    <span>8-min door delivery</span>
                  </span>
                  <span className="text-emerald-500">·</span>
                  <span className="flex items-center gap-1">
                    <ShieldCheck className="w-3.5 h-3.5 text-emerald-300" />
                    <span>Best mandi prices</span>
                  </span>
                  <span className="text-emerald-500">·</span>
                  <span className="flex items-center gap-1">
                    <Award className="w-3.5 h-3.5 text-emerald-300" />
                    <span>100% Quality guarantee</span>
                  </span>
                </div>
              </div>

              {/* Decorative Subtle Background Elements */}
              <div className="absolute right-0 top-0 bottom-0 w-1/3 opacity-20 pointer-events-none flex items-center justify-end pr-6">
                <span className="text-8xl">🥦🥛🍎</span>
              </div>
            </div>

            {/* Festive Season & Special Event Banners (Durga Puja, Company Exclusive, Winner Sale) */}
            <FestiveBannerCarousel
              banners={banners}
              onOpenAdminBanners={() => setIsBannersModalOpen(true)}
              isAdminOrOwner={currentUser.role === 'admin' || currentUser.role === 'owner'}
              onSelectCategory={(catId) => {
                setSelectedCategory(catId);
                setActiveTab('categories');
              }}
            />

            {/* 2. Dynamic Category Grid */}
            <CategoryGrid
              selectedCategory={selectedCategory}
              onSelectCategory={(catId) => setSelectedCategory(catId)}
            />

            {/* 3. Horizontal Scrolling Carousels */}
            {/* Carousel A: Deals of the Day */}
            <ProductCarousel
              title="Deals of the Day"
              subtitle="Crazy price drops & massive savings"
              type="deal_of_day"
              products={dealsOfTheDay}
              cartItems={cartItems}
              onAddToCart={handleAddToCart}
              onUpdateQuantity={handleUpdateQuantity}
              onViewAll={() => setActiveTab('categories')}
            />

            {/* Carousel B: Trending Items */}
            <ProductCarousel
              title="Trending in Your Neighborhood"
              subtitle="Fast-moving essentials right now"
              type="trending"
              products={trendingProducts}
              cartItems={cartItems}
              onAddToCart={handleAddToCart}
              onUpdateQuantity={handleUpdateQuantity}
              onViewAll={() => setActiveTab('categories')}
            />

            {/* Carousel C: Recently Purchased */}
            <ProductCarousel
              title="Recently Purchased"
              subtitle="Order again with a single tap"
              type="recently_purchased"
              products={recentlyPurchased}
              cartItems={cartItems}
              onAddToCart={handleAddToCart}
              onUpdateQuantity={handleUpdateQuantity}
              onViewAll={() => setActiveTab('orders')}
            />

            {/* 4. Complete Products Grid (Dynamically filtered by Category) */}
            <section className="mt-8 pt-4 border-t border-gray-200">
              <div className="flex items-center justify-between mb-4 px-1">
                <div>
                  <h2 className="text-lg sm:text-xl font-black text-gray-900 leading-tight">
                    {selectedCategory === 'all'
                      ? 'Shop All Grocery Essentials'
                      : `Items in ${selectedCategory.charAt(0).toUpperCase() + selectedCategory.slice(1).replace('_', ' ')}`}
                  </h2>
                  <p className="text-xs text-gray-500">
                    Showing {homeGridProducts.length} items with instant 8-min dark store fulfillment
                  </p>
                </div>
                {selectedCategory !== 'all' && (
                  <button
                    onClick={() => setSelectedCategory('all')}
                    className="text-xs font-bold text-emerald-700 bg-emerald-50 px-2.5 py-1.5 rounded-lg hover:bg-emerald-100 transition-colors cursor-pointer"
                  >
                    View All Items
                  </button>
                )}
              </div>

              <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 sm:gap-4">
                {homeGridProducts.map((product) => (
                  <ProductCard
                    key={product.id}
                    product={product}
                    quantity={getProductQuantity(product.id)}
                    onAddToCart={handleAddToCart}
                    onUpdateQuantity={handleUpdateQuantity}
                  />
                ))}
              </div>
            </section>
          </div>
        )}

        {/* TAB 2: CATEGORIES */}
        {activeTab === 'categories' && (
          <CategoriesView
            products={products}
            cartItems={cartItems}
            onAddToCart={handleAddToCart}
            onUpdateQuantity={handleUpdateQuantity}
            selectedCategory={selectedCategory}
            onSelectCategory={(catId) => setSelectedCategory(catId)}
          />
        )}

        {/* TAB 3: SEARCH */}
        {activeTab === 'search' && (
          <SearchView
            products={products}
            cartItems={cartItems}
            onAddToCart={handleAddToCart}
            onUpdateQuantity={handleUpdateQuantity}
            searchQuery={searchQuery}
            onSearchChange={(q) => setSearchQuery(q)}
          />
        )}

        {/* TAB 4: ORDERS / DELIVERY DISPATCH */}
        {activeTab === 'orders' && (
          currentUser.role === 'delivery' ? (
            <div className="max-w-4xl mx-auto px-3 sm:px-4 py-4">
              <div className="mb-4 flex items-center justify-between bg-emerald-50 border border-emerald-200 rounded-2xl p-3">
                <div className="flex items-center gap-2">
                  <Bike className="w-5 h-5 text-emerald-700" />
                  <div>
                    <h3 className="text-xs font-bold text-emerald-900">Delivery Partner Console</h3>
                    <p className="text-[11px] text-emerald-600">Assigned rider: {currentUser.name} (+91 {currentUser.phone})</p>
                  </div>
                </div>
                <button
                  onClick={() => setIsOwnerModalOpen(true)}
                  className="text-xs text-emerald-800 font-bold underline cursor-pointer"
                >
                  Switch Role / Store Settings
                </button>
              </div>
              <DeliveryPartnerView
                orders={orders}
                onUpdateOrderStatus={handleUpdateOrderStatus}
                currentUser={currentUser}
              />
            </div>
          ) : (
            <OrdersView
              orders={orders}
              onReorder={handleReorder}
              onExploreProducts={() => setActiveTab('home')}
            />
          )
        )}

        {/* TAB 5: PROFILE */}
        {activeTab === 'profile' && (
          <ProfileView
            currentAddress={currentAddress}
            onOpenAddressModal={() => setIsAddressModalOpen(true)}
            onOpenMapPicker={() => setIsMapPickerOpen(true)}
            onOpenSeoModal={() => setIsSeoModalOpen(true)}
            onOpenAdminModal={() => setIsAdminModalOpen(true)}
            currentUser={currentUser}
            onOpenAuthModal={() => setIsAuthModalOpen(true)}
            onOpenOwnerModal={() => setIsOwnerModalOpen(true)}
            onOpenApkModal={() => setIsApkModalOpen(true)}
            onOpenUserDetailsModal={() => setIsUserDetailsModalOpen(true)}
            onLogout={handleLogout}
            onOpenBannersModal={() => setIsBannersModalOpen(true)}
          />
        )}
      </main>

      {/* Slide-over Cart Drawer */}
      <CartDrawer
        isOpen={isCartOpen}
        onClose={() => setIsCartOpen(false)}
        cartItems={cartItems}
        onUpdateQuantity={handleUpdateQuantity}
        onRemoveItem={handleRemoveItem}
        currentAddress={currentAddress}
        onPlaceOrder={handlePlaceOrder}
      />

      {/* Address Selector Modal */}
      <AddressModal
        isOpen={isAddressModalOpen}
        onClose={() => setIsAddressModalOpen(false)}
        addresses={addresses}
        currentAddress={currentAddress}
        onSelectAddress={(addr) => setCurrentAddress(addr)}
        onAddNewAddress={handleAddNewAddress}
        onOpenMapPicker={() => setIsMapPickerOpen(true)}
      />

      {/* Smart Geolocation Map Pinning Modal */}
      <MapAddressPicker
        isOpen={isMapPickerOpen}
        onClose={() => setIsMapPickerOpen(false)}
        currentAddress={currentAddress}
        onConfirmAddress={(confirmedAddr) => {
          handleAddNewAddress(confirmedAddr);
          setCurrentAddress(confirmedAddr);
        }}
      />

      {/* Google SERP SEO Preview Modal */}
      <GoogleSearchPreviewModal
        isOpen={isSeoModalOpen}
        onClose={() => setIsSeoModalOpen(false)}
      />

      {/* Backend Master Catalog & Schema Inspector Modal */}
      <AdminCatalogModal
        isOpen={isAdminModalOpen}
        onClose={() => setIsAdminModalOpen(false)}
        onPublishProduct={handlePublishFromAdmin}
        banners={banners}
        onUpdateBanners={setBanners}
      />

      {/* 6. Auth / Phone OTP / Gmail Modal */}
      <AuthView
        isOpen={isAuthModalOpen}
        onClose={handleCloseAuth}
        onLoginSuccess={handleLoginSuccess}
        allUsers={users}
        onOpenApkModal={() => {
          setIsAuthModalOpen(false);
          setIsApkModalOpen(true);
        }}
      />

      {/* 7. Owner Management & Role Assignment Modal */}
      <OwnerManagementModal
        isOpen={isOwnerModalOpen}
        onClose={() => setIsOwnerModalOpen(false)}
        currentUser={currentUser}
        allUsers={users}
        onUpdateUsers={setUsers}
        storeSettings={storeSettings}
        onUpdateStoreSettings={setStoreSettings}
        orders={orders}
        onOpenMapPicker={() => setIsMapPickerOpen(true)}
        onSwitchSimulatedRole={handleSwitchSimulatedRole}
      />

      {/* 8. Mobile APK / PWA Installation Modal */}
      <ApkDownloadModal
        isOpen={isApkModalOpen}
        onClose={() => setIsApkModalOpen(false)}
      />

      {/* 9. User Account Details & Profile Modal */}
      <UserDetailsModal
        isOpen={isUserDetailsModalOpen}
        onClose={() => setIsUserDetailsModalOpen(false)}
        currentUser={currentUser}
        onUpdateProfile={handleUpdateUserProfile}
        onLogout={handleLogout}
        currentAddress={currentAddress}
        onOpenAddressModal={() => {
          setIsUserDetailsModalOpen(false);
          setIsAddressModalOpen(true);
        }}
        onOpenMapPicker={() => {
          setIsUserDetailsModalOpen(false);
          setIsMapPickerOpen(true);
        }}
        orders={orders}
        onViewOrders={() => {
          setIsUserDetailsModalOpen(false);
          setActiveTab('orders');
        }}
        onOpenAuthModal={() => {
          setIsUserDetailsModalOpen(false);
          setIsAuthModalOpen(true);
        }}
      />

      {/* 10. Dedicated Festive & Sale Banner Management Modal */}
      {isBannersModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-2 sm:p-4 bg-black/70 backdrop-blur-xs animate-in fade-in duration-200">
          <div 
            className="bg-white rounded-3xl max-w-5xl w-full max-h-[92vh] flex flex-col overflow-hidden shadow-2xl border border-gray-100"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="p-4 sm:p-5 border-b border-gray-100 flex items-center justify-between bg-gradient-to-r from-red-900 via-rose-800 to-amber-900 text-white shrink-0">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-amber-400 text-gray-950 flex items-center justify-center font-black shadow-xs">
                  <Sparkles className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-base sm:text-lg font-bold">
                    Festive & Promotional Banner Manager
                  </h3>
                  <p className="text-xs text-rose-200">
                    Add or customize festive banners like Durga Puja Sale, Company Exclusive, Winner Sale & mega discounts
                  </p>
                </div>
              </div>
              <button
                onClick={() => setIsBannersModalOpen(false)}
                className="p-1.5 rounded-full text-white/80 hover:text-white hover:bg-white/20 transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="flex-grow overflow-y-auto p-4 sm:p-6 bg-gray-50/50">
              <BannerManagementTab
                banners={banners}
                onUpdateBanners={setBanners}
              />
            </div>
          </div>
        </div>
      )}

      {/* 5. Persistent Bottom Navigation Bar (Mobile) */}
      <BottomNavbar
        activeTab={activeTab}
        onTabChange={(tab) => {
          setActiveTab(tab);
          window.scrollTo({ top: 0, behavior: 'smooth' });
        }}
        cartItemCount={cartItemCount}
        onOpenCart={() => setIsCartOpen(true)}
      />

      {/* Desktop Footer */}
      <Footer />
    </div>
  );
};

export default App;
