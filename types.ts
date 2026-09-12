export interface Product {
  id: string;
  name: string;
  brand: string;
  unit: string;
  price: number;
  mrp: number;
  discountPercent?: number;
  image: string;
  category: string;
  subcategory?: string;
  description?: string;
  deliveryTime?: string;
  rating?: number;
  ratingCount?: number;
  inStock: boolean;
  barcode?: string;
  tags?: ('trending' | 'deal_of_day' | 'recently_purchased' | 'bestseller')[];
  purchase_price?: number | null;
  selling_price?: number | null;
  profit_margin_percent?: number | null;
  is_published?: boolean;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  badge?: string;
  bgGradient?: string;
  itemCount?: number;
}

export interface Address {
  id: string;
  title: string;
  addressLine: string;
  landmark?: string;
  tag: 'home' | 'work' | 'other';
  isDefault: boolean;
  latitude?: number;
  longitude?: number;
  coordinates?: { lat: number; lng: number };
  etaMinutes?: number;
  distanceKm?: number;
  darkStoreName?: string;
  houseNumber?: string;
  floorBuilding?: string;
}

export interface DarkStoreHub {
  id: string;
  name: string;
  code: string;
  coordinates: { lat: number; lng: number };
  baseEtaMinutes: number;
  status: 'active' | 'high_demand' | 'closed';
  ridersActive: number;
}

export interface Order {
  id: string;
  orderNumber: string;
  date: string;
  items: CartItem[];
  total: number;
  status: 'placed' | 'packing' | 'out_for_delivery' | 'delivered';
  address: Address;
  deliveryEta: string;
  paymentMethod: string;
  assignedRiderId?: string;
  assignedRiderName?: string;
}

export interface MasterCatalogItem {
  id: string;
  barcode: string;
  brand_name: string;
  product_title: string;
  weight_metric: string;
  category: string;
  subcategory: string;
  image_url: string;
  purchase_price: number | null;
  selling_price: number | null;
  mrp?: number | null;
  profit_margin_percent?: number | null;
  profit_margin_amount?: number | null;
  is_active: boolean;
  status: 'pending_admin_pricing' | 'active' | 'archived';
  source_provider: string;
  created_at: string;
  updated_at: string;
}

export interface UpdatePricingPayload {
  product_id: string;
  purchase_price: number;
  selling_price: number;
  is_active?: boolean;
}

export interface UpdatePricingResponse {
  success: boolean;
  message: string;
  data?: {
    product_id: string;
    product_title: string;
    brand_name: string;
    purchase_price: number;
    selling_price: number;
    profit_margin_amount: number;
    profit_margin_percent: number;
    is_active: boolean;
    status: 'pending_admin_pricing' | 'active';
    updated_at: string;
  };
  error?: string;
}

export interface GroundingChunk {
  web: {
    uri: string;
    title: string;
  };
}

export type UserRole = 'user' | 'owner' | 'admin' | 'delivery';

export interface UserProfile {
  id: string;
  name: string;
  phone: string;
  email?: string;
  role: UserRole;
  avatar?: string;
  createdAt: string;
  isActive: boolean;
  assignedOrdersCount?: number;
}

export interface StoreSettings {
  storeName: string;
  address: string;
  latitude: number;
  longitude: number;
  serviceRadiusKm: number;
  maxDeliveryHours: number;
  isDeliveryActive: boolean;
  ownerPhone: string;
}

export type PromoBannerTheme = 'durga_puja' | 'diwali' | 'exclusive' | 'winner_sale' | 'monsoon' | 'mega_deals' | 'custom';

export interface PromoBanner {
  id: string;
  title: string;
  subtitle: string;
  badge: string;
  discountText: string;
  couponCode?: string;
  ctaText: string;
  bannerType: 'festive' | 'exclusive' | 'sale';
  theme: PromoBannerTheme;
  gradient: string;
  emojiIcon: string;
  isActive: boolean;
  priority: number;
  validUntil?: string;
}
