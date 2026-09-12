import React, { useState, useMemo } from 'react';
import { 
  Search, 
  Filter, 
  CheckCircle2, 
  AlertTriangle, 
  Eye, 
  EyeOff, 
  Save, 
  RefreshCw, 
  TrendingUp, 
  TrendingDown, 
  DollarSign, 
  Package, 
  ShieldCheck, 
  ShieldAlert, 
  ArrowUpDown, 
  ExternalLink,
  Info,
  Sparkles,
  Zap
} from 'lucide-react';
import type { MasterCatalogItem, Product } from '../types';
import { apiUpdatePricing } from '../services/inventoryApi';

interface AdminInventoryDashboardProps {
  catalogItems: MasterCatalogItem[];
  onUpdateCatalogItems: (items: MasterCatalogItem[]) => void;
  onPublishToStorefront: (item: MasterCatalogItem, sellingPrice: number, purchasePrice: number, isActive: boolean) => void;
  onViewStorefront?: () => void;
}

type FilterTab = 'all' | 'missing_price' | 'active' | 'hidden';

export const AdminInventoryDashboard: React.FC<AdminInventoryDashboardProps> = ({
  catalogItems,
  onUpdateCatalogItems,
  onPublishToStorefront,
  onViewStorefront,
}) => {
  // Search & Filter State
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilterTab, setActiveFilterTab] = useState<FilterTab>('all');
  const [categoryFilter, setCategoryFilter] = useState('all');

  // Local row draft states for live editable cells
  // Map of item.id -> { purchasePrice: string, sellingPrice: string, isSaving: boolean, error?: string, successMsg?: string }
  const [rowDrafts, setRowDrafts] = useState<Record<string, {
    purchasePrice: string;
    sellingPrice: string;
    isSaving: boolean;
    error?: string;
    successMsg?: string;
  }>>(() => {
    const initial: Record<string, any> = {};
    catalogItems.forEach((item) => {
      initial[item.id] = {
        purchasePrice: item.purchase_price !== null ? String(item.purchase_price) : '',
        sellingPrice: item.selling_price !== null && item.selling_price > 0 ? String(item.selling_price) : '',
        isSaving: false,
      };
    });
    return initial;
  });

  // Global Notification Banner
  const [notification, setNotification] = useState<{
    type: 'success' | 'error' | 'info';
    message: string;
  } | null>(null);

  // Sync row drafts whenever catalogItems changes
  React.useEffect(() => {
    setRowDrafts((prev) => {
      const updated = { ...prev };
      catalogItems.forEach((item) => {
        if (!updated[item.id]) {
          updated[item.id] = {
            purchasePrice: item.purchase_price !== null ? String(item.purchase_price) : '',
            sellingPrice: item.selling_price !== null && item.selling_price > 0 ? String(item.selling_price) : '',
            isSaving: false,
          };
        }
      });
      return updated;
    });
  }, [catalogItems]);

  // Distinct categories for dropdown
  const categories = useMemo(() => {
    const set = new Set<string>();
    catalogItems.forEach((item) => set.add(item.category));
    return Array.from(set);
  }, [catalogItems]);

  // Aggregate Metrics
  const metrics = useMemo(() => {
    const total = catalogItems.length;
    const missingPriceCount = catalogItems.filter(
      (i) => i.purchase_price === null || i.purchase_price === 0 || i.selling_price === null || i.selling_price === 0
    ).length;
    const activeCount = catalogItems.filter((i) => i.is_active && i.selling_price && i.selling_price > 0).length;
    const hiddenCount = total - activeCount;

    // Average margin of priced items
    const pricedItems = catalogItems.filter(
      (i) => i.selling_price && i.purchase_price && i.selling_price > 0 && i.purchase_price > 0
    );
    const avgMargin = pricedItems.length > 0
      ? (pricedItems.reduce((sum, i) => sum + (i.profit_margin_percent || 0), 0) / pricedItems.length).toFixed(1)
      : '0.0';

    return { total, missingPriceCount, activeCount, hiddenCount, avgMargin };
  }, [catalogItems]);

  // Filtered Table Items
  const filteredItems = useMemo(() => {
    return catalogItems.filter((item) => {
      // 1. Text Search
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase();
        const matchesText =
          item.product_title.toLowerCase().includes(query) ||
          item.brand_name.toLowerCase().includes(query) ||
          item.barcode.includes(query) ||
          item.category.toLowerCase().includes(query);
        if (!matchesText) return false;
      }

      // 2. Category Filter
      if (categoryFilter !== 'all' && item.category !== categoryFilter) {
        return false;
      }

      // 3. Tab Filter
      if (activeFilterTab === 'missing_price') {
        const isMissing =
          item.purchase_price === null ||
          item.purchase_price === 0 ||
          item.selling_price === null ||
          item.selling_price === 0;
        if (!isMissing) return false;
      } else if (activeFilterTab === 'active') {
        if (!item.is_active) return false;
      } else if (activeFilterTab === 'hidden') {
        if (item.is_active) return false;
      }

      return true;
    });
  }, [catalogItems, searchQuery, categoryFilter, activeFilterTab]);

  // Handle cell inputs
  const handlePriceChange = (itemId: string, field: 'purchasePrice' | 'sellingPrice', value: string) => {
    setRowDrafts((prev) => ({
      ...prev,
      [itemId]: {
        ...prev[itemId],
        [field]: value,
        error: undefined,
        successMsg: undefined,
      },
    }));
  };

  // Helper to calculate margin dynamically from inputs
  const calculateRowMargin = (itemId: string) => {
    const draft = rowDrafts[itemId];
    if (!draft) return null;
    const purchase = parseFloat(draft.purchasePrice);
    const selling = parseFloat(draft.sellingPrice);

    if (isNaN(purchase) || isNaN(selling) || selling <= 0) {
      return null;
    }

    const netAmount = Number((selling - purchase).toFixed(2));
    const marginPercent = Number((((selling - purchase) / selling) * 100).toFixed(2));
    const isLoss = selling < purchase;

    return { netAmount, marginPercent, isLoss };
  };

  // Save Pricing Action (calls POST /api/admin/inventory/update-pricing)
  const handleSavePricing = async (item: MasterCatalogItem, forceActive?: boolean) => {
    const draft = rowDrafts[item.id];
    if (!draft) return;

    const purchase = parseFloat(draft.purchasePrice);
    const selling = parseFloat(draft.sellingPrice);

    // Frontline validation
    if (isNaN(purchase) || purchase < 0) {
      setRowDrafts((prev) => ({
        ...prev,
        [item.id]: { ...prev[item.id], error: 'Enter valid purchase price' },
      }));
      return;
    }

    if (isNaN(selling) || selling < 0) {
      setRowDrafts((prev) => ({
        ...prev,
        [item.id]: { ...prev[item.id], error: 'Enter valid selling price' },
      }));
      return;
    }

    // Crucial Rule: selling_price >= purchase_price
    if (selling < purchase) {
      setRowDrafts((prev) => ({
        ...prev,
        [item.id]: {
          ...prev[item.id],
          error: `Rule violation: Selling price (₹${selling}) cannot be lower than Purchase price (₹${purchase}). Negative margins are forbidden.`,
        },
      }));
      setNotification({
        type: 'error',
        message: `Validation Error for ${item.product_title}: Selling price cannot be less than Purchase price!`,
      });
      return;
    }

    // Determine is_active status
    const targetIsActive = forceActive !== undefined ? forceActive : item.is_active;

    // Set saving spinner
    setRowDrafts((prev) => ({
      ...prev,
      [item.id]: { ...prev[item.id], isSaving: true, error: undefined, successMsg: undefined },
    }));

    try {
      // Call REST API
      const response = await apiUpdatePricing({
        product_id: item.id,
        purchase_price: purchase,
        selling_price: selling,
        is_active: targetIsActive,
      });

      if (!response.success || !response.data) {
        throw new Error(response.message || 'API rejected pricing update');
      }

      const resData = response.data;

      // Update Catalog state
      const updatedCatalog = catalogItems.map((c) => {
        if (c.id === item.id) {
          return {
            ...c,
            purchase_price: resData.purchase_price,
            selling_price: resData.selling_price,
            profit_margin_amount: resData.profit_margin_amount,
            profit_margin_percent: resData.profit_margin_percent,
            is_active: resData.is_active,
            status: resData.status,
            updated_at: resData.updated_at,
          };
        }
        return c;
      });

      onUpdateCatalogItems(updatedCatalog);

      // Trigger Storefront update in customer UI
      onPublishToStorefront(item, resData.selling_price, resData.purchase_price, resData.is_active);

      setRowDrafts((prev) => ({
        ...prev,
        [item.id]: {
          ...prev[item.id],
          isSaving: false,
          successMsg: `Saved! Margin: ${resData.profit_margin_percent}%`,
        },
      }));

      setNotification({
        type: 'success',
        message: `Successfully verified & saved pricing for "${item.product_title}". ${resData.is_active ? 'Now LIVE on Storefront!' : 'Saved as Draft.'}`,
      });

      // Clear row success text after 3s
      setTimeout(() => {
        setRowDrafts((prev) => ({
          ...prev,
          [item.id]: { ...prev[item.id], successMsg: undefined },
        }));
      }, 3500);
    } catch (err: any) {
      setRowDrafts((prev) => ({
        ...prev,
        [item.id]: {
          ...prev[item.id],
          isSaving: false,
          error: err.message || 'Failed to update pricing',
        },
      }));
      setNotification({
        type: 'error',
        message: err.message || 'Failed to update pricing',
      });
    }
  };

  // Toggle "Publish to Storefront" Switch
  const handleToggleStorefront = async (item: MasterCatalogItem) => {
    const draft = rowDrafts[item.id];
    const purchase = parseFloat(draft?.purchasePrice || String(item.purchase_price || 0));
    const selling = parseFloat(draft?.sellingPrice || String(item.selling_price || 0));
    const nextActiveState = !item.is_active;

    // Check if activating without valid pricing
    if (nextActiveState) {
      if (isNaN(purchase) || purchase <= 0 || isNaN(selling) || selling <= 0) {
        setNotification({
          type: 'error',
          message: `Cannot publish "${item.product_title}"! Please specify valid non-zero Purchase & Selling amounts first.`,
        });
        setRowDrafts((prev) => ({
          ...prev,
          [item.id]: {
            ...prev[item.id],
            error: 'Missing prices. Set purchase & selling amounts to publish.',
          },
        }));
        return;
      }

      if (selling < purchase) {
        setNotification({
          type: 'error',
          message: `Cannot publish "${item.product_title}" at a loss! Selling price (₹${selling}) must be >= Purchase price (₹${purchase}).`,
        });
        return;
      }
    }

    // Save with the toggled state
    await handleSavePricing(item, nextActiveState);
  };

  // Simulate Wholesale Sync Ingestion (Demonstrates pipeline pulling new items with zero/missing prices)
  const handleSimulateWholesaleSync = () => {
    const sampleBarcodes = ['8904018301124', '8901725139981', '8901233029182'];
    const sampleItems = [
      {
        title: 'Epigamia Greek Yogurt Natural',
        brand: 'Epigamia',
        cat: 'Dairy, Bread & Eggs',
        sub: 'Yogurt',
        size: '100 g cup',
        photo: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&auto=format&fit=crop&q=80',
      },
      {
        title: 'Bikanervala Masala Kaju Roasted',
        brand: 'Bikanervala',
        cat: 'Munchies & Chips',
        sub: 'Dry Fruits',
        size: '200 g pack',
        photo: 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=600&auto=format&fit=crop&q=80',
      },
    ];

    const pick = sampleItems[Math.floor(Math.random() * sampleItems.length)];
    const newItem: MasterCatalogItem = {
      id: `mc-${Date.now()}`,
      barcode: sampleBarcodes[Math.floor(Math.random() * sampleBarcodes.length)],
      brand_name: pick.brand,
      product_title: pick.title,
      weight_metric: pick.size,
      category: pick.cat,
      subcategory: pick.sub,
      image_url: pick.photo,
      purchase_price: null, // STRICT RULE ENFORCEMENT: NULL
      selling_price: null,  // STRICT RULE ENFORCEMENT: NULL
      profit_margin_amount: null,
      profit_margin_percent: null,
      is_active: false,
      status: 'pending_admin_pricing',
      source_provider: 'Wholesale Mandi Automated Pipeline',
      created_at: new Date().toISOString().replace('T', ' ').slice(0, 19),
      updated_at: new Date().toISOString().replace('T', ' ').slice(0, 19),
    };

    onUpdateCatalogItems([newItem, ...catalogItems]);
    setActiveFilterTab('missing_price'); // jump to missing price filter
    setNotification({
      type: 'info',
      message: `Scraper ingested new item: "${newItem.product_title}". In accordance with business rules, prices are NULL and item is HIDDEN pending your review!`,
    });
  };

  return (
    <div className="space-y-4">
      {/* 1. Global Alert Notification */}
      {notification && (
        <div 
          className={`p-3.5 rounded-2xl text-xs font-semibold flex items-center justify-between shadow-xs transition-all ${
            notification.type === 'error'
              ? 'bg-red-50 text-red-900 border border-red-200'
              : notification.type === 'success'
              ? 'bg-emerald-50 text-emerald-900 border border-emerald-200'
              : 'bg-blue-50 text-blue-900 border border-blue-200'
          }`}
        >
          <div className="flex items-center gap-2">
            {notification.type === 'error' ? (
              <ShieldAlert className="w-4 h-4 text-red-600 shrink-0" />
            ) : notification.type === 'success' ? (
              <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
            ) : (
              <Info className="w-4 h-4 text-blue-600 shrink-0" />
            )}
            <span>{notification.message}</span>
          </div>
          <button
            onClick={() => setNotification(null)}
            className="text-gray-400 hover:text-gray-700 font-bold px-2 py-0.5 rounded cursor-pointer"
          >
            ✕
          </button>
        </div>
      )}

      {/* 2. Top Summary KPI Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 sm:gap-3">
        {/* Metric 1: Total Master Items */}
        <div className="bg-gray-50 border border-gray-200 rounded-2xl p-3 flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gray-200 flex items-center justify-center text-gray-700 font-bold">
            <Package className="w-4 h-4" />
          </div>
          <div>
            <p className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Catalog Items</p>
            <p className="text-lg font-black text-gray-900 leading-none mt-0.5">{metrics.total}</p>
          </div>
        </div>

        {/* Metric 2: Missing / Zero Price Items (Flagged) */}
        <div 
          onClick={() => setActiveFilterTab('missing_price')}
          className={`border rounded-2xl p-3 flex items-center gap-3 cursor-pointer transition-all ${
            activeFilterTab === 'missing_price' 
              ? 'bg-amber-100 border-amber-400 ring-2 ring-amber-400/30' 
              : 'bg-amber-50/70 border-amber-200 hover:bg-amber-100/60'
          }`}
        >
          <div className="w-9 h-9 rounded-xl bg-amber-500 text-gray-950 flex items-center justify-center font-bold">
            <AlertTriangle className="w-4 h-4" />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <p className="text-[11px] font-bold text-amber-900 uppercase tracking-wider">Missing Price</p>
              {metrics.missingPriceCount > 0 && (
                <span className="bg-amber-500 text-gray-950 text-[9px] font-black px-1.5 py-0.2 rounded-full">
                  ACTION
                </span>
              )}
            </div>
            <p className="text-lg font-black text-amber-950 leading-none mt-0.5">
              {metrics.missingPriceCount} items
            </p>
          </div>
        </div>

        {/* Metric 3: Active on Storefront */}
        <div 
          onClick={() => setActiveFilterTab('active')}
          className={`border rounded-2xl p-3 flex items-center gap-3 cursor-pointer transition-all ${
            activeFilterTab === 'active' 
              ? 'bg-emerald-100 border-emerald-400 ring-2 ring-emerald-400/30' 
              : 'bg-emerald-50/70 border-emerald-200 hover:bg-emerald-100/60'
          }`}
        >
          <div className="w-9 h-9 rounded-xl bg-emerald-600 text-white flex items-center justify-center font-bold">
            <Eye className="w-4 h-4" />
          </div>
          <div>
            <p className="text-[11px] font-bold text-emerald-900 uppercase tracking-wider">Storefront Live</p>
            <p className="text-lg font-black text-emerald-950 leading-none mt-0.5">{metrics.activeCount} live</p>
          </div>
        </div>

        {/* Metric 4: Average Profit Margin */}
        <div className="bg-teal-50 border border-teal-200 rounded-2xl p-3 flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-teal-600 text-white flex items-center justify-center font-bold">
            <TrendingUp className="w-4 h-4" />
          </div>
          <div>
            <p className="text-[11px] font-bold text-teal-900 uppercase tracking-wider">Avg Profit Margin</p>
            <p className="text-lg font-black text-teal-950 leading-none mt-0.5">+{metrics.avgMargin}%</p>
          </div>
        </div>
      </div>

      {/* 3. Search & Filter Controls Toolbar */}
      <div className="bg-white border border-gray-200 rounded-2xl p-3 sm:p-4 shadow-2xs space-y-3">
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
          {/* Search Box */}
          <div className="relative flex-grow max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search by title, brand, barcode (EAN-13)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full text-xs pl-9 pr-8 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none transition-all"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 text-xs font-bold"
              >
                ✕
              </button>
            )}
          </div>

          {/* Action Tools */}
          <div className="flex items-center gap-2 self-end sm:self-auto shrink-0">
            {/* Category Dropdown */}
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="text-xs bg-gray-50 border border-gray-200 rounded-xl px-2.5 py-2 font-medium text-gray-700 outline-none focus:border-emerald-500"
            >
              <option value="all">All Categories ({categories.length})</option>
              {categories.map((cat) => (
                <option key={cat} value={cat}>
                  {cat}
                </option>
              ))}
            </select>

            {/* Ingest Simulation Button */}
            <button
              onClick={handleSimulateWholesaleSync}
              className="flex items-center gap-1.5 px-3 py-2 bg-gray-900 hover:bg-gray-800 text-amber-400 font-bold text-xs rounded-xl shadow-xs transition-all active:scale-95 cursor-pointer shrink-0"
              title="Pull a new FMCG product with NULL price to demonstrate the unpriced filter"
            >
              <RefreshCw className="w-3.5 h-3.5" />
              <span>Simulate Cloud Ingest</span>
            </button>
          </div>
        </div>

        {/* Filter Tabs Chips */}
        <div className="flex items-center gap-2 overflow-x-auto pt-1 pb-0.5 text-xs font-bold">
          <button
            onClick={() => setActiveFilterTab('all')}
            className={`px-3 py-1.5 rounded-xl transition-all cursor-pointer ${
              activeFilterTab === 'all'
                ? 'bg-gray-900 text-white shadow-xs'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            All Items ({metrics.total})
          </button>

          <button
            onClick={() => setActiveFilterTab('missing_price')}
            className={`px-3 py-1.5 rounded-xl flex items-center gap-1.5 transition-all cursor-pointer ${
              activeFilterTab === 'missing_price'
                ? 'bg-amber-600 text-white shadow-xs'
                : 'bg-amber-50 text-amber-800 border border-amber-200 hover:bg-amber-100'
            }`}
          >
            <AlertTriangle className="w-3.5 h-3.5" />
            <span>Zero / Missing Price ({metrics.missingPriceCount})</span>
          </button>

          <button
            onClick={() => setActiveFilterTab('active')}
            className={`px-3 py-1.5 rounded-xl flex items-center gap-1.5 transition-all cursor-pointer ${
              activeFilterTab === 'active'
                ? 'bg-emerald-600 text-white shadow-xs'
                : 'bg-emerald-50 text-emerald-800 border border-emerald-200 hover:bg-emerald-100'
            }`}
          >
            <Eye className="w-3.5 h-3.5" />
            <span>Live on Storefront ({metrics.activeCount})</span>
          </button>

          <button
            onClick={() => setActiveFilterTab('hidden')}
            className={`px-3 py-1.5 rounded-xl flex items-center gap-1.5 transition-all cursor-pointer ${
              activeFilterTab === 'hidden'
                ? 'bg-gray-700 text-white shadow-xs'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            <EyeOff className="w-3.5 h-3.5" />
            <span>Hidden / Draft ({metrics.hiddenCount})</span>
          </button>

          {onViewStorefront && (
            <button
              onClick={onViewStorefront}
              className="ml-auto text-xs font-bold text-emerald-700 hover:text-emerald-800 flex items-center gap-1 cursor-pointer"
            >
              <span>View Customer Storefront</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </button>
          )}
        </div>
      </div>

      {/* 4. Tabular Admin Table */}
      <div className="bg-white border border-gray-200 rounded-3xl overflow-hidden shadow-xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs divide-y divide-gray-200">
            <thead className="bg-gray-50/90 text-gray-700 font-bold uppercase tracking-wider text-[10px]">
              <tr>
                <th className="p-3.5">Product & Barcode</th>
                <th className="p-3.5">Category & Feed</th>
                <th className="p-3.5 w-36">Purchase Amount (₹)</th>
                <th className="p-3.5 w-36">Selling Amount (₹)</th>
                <th className="p-3.5 w-32">Net Margin %</th>
                <th className="p-3.5 w-44">Storefront Status</th>
                <th className="p-3.5 text-right w-28">Actions</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-gray-100">
              {filteredItems.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-gray-500">
                    <div className="max-w-xs mx-auto space-y-2">
                      <Package className="w-8 h-8 text-gray-400 mx-auto" />
                      <p className="font-bold text-gray-800">No items match your criteria</p>
                      <p className="text-[11px] text-gray-400">
                        {activeFilterTab === 'missing_price'
                          ? 'All ingested catalog items currently have valid pricing!'
                          : 'Try changing your search query or category filter.'}
                      </p>
                      {activeFilterTab !== 'all' && (
                        <button
                          onClick={() => {
                            setActiveFilterTab('all');
                            setSearchQuery('');
                          }}
                          className="mt-2 text-xs font-bold text-emerald-700 underline"
                        >
                          Clear all filters
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                filteredItems.map((item) => {
                  const draft = rowDrafts[item.id] || {
                    purchasePrice: '',
                    sellingPrice: '',
                    isSaving: false,
                  };

                  const liveMargin = calculateRowMargin(item.id);
                  const isMissingPricing =
                    !draft.purchasePrice ||
                    parseFloat(draft.purchasePrice) <= 0 ||
                    !draft.sellingPrice ||
                    parseFloat(draft.sellingPrice) <= 0;

                  const hasLoss = liveMargin?.isLoss;

                  return (
                    <tr 
                      key={item.id} 
                      className={`hover:bg-gray-50/80 transition-colors ${
                        isMissingPricing ? 'bg-amber-50/25' : ''
                      }`}
                    >
                      {/* 1. Product Details */}
                      <td className="p-3.5">
                        <div className="flex items-center gap-3">
                          <img
                            src={item.image_url}
                            alt={item.product_title}
                            className="w-11 h-11 rounded-xl object-cover border border-gray-200 bg-white shrink-0 shadow-2xs"
                            onError={(e) => {
                              (e.target as HTMLImageElement).src =
                                'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop&q=80';
                            }}
                          />
                          <div className="space-y-0.5">
                            <p className="font-bold text-gray-900 leading-snug">{item.product_title}</p>
                            <div className="flex items-center gap-2 text-[11px] text-gray-500">
                              <span className="font-semibold text-gray-700">{item.brand_name}</span>
                              <span>·</span>
                              <span>{item.weight_metric}</span>
                            </div>
                            <div className="flex items-center gap-1.5 pt-0.5">
                              <span className="font-mono text-[10px] text-gray-400 bg-gray-100 px-1.5 py-0.2 rounded">
                                {item.barcode}
                              </span>
                              {isMissingPricing && (
                                <span className="text-[9px] font-black text-amber-700 bg-amber-100 px-1.5 py-0.2 rounded-full uppercase">
                                  Price Unset
                                </span>
                              )}
                            </div>
                          </div>
                        </div>
                      </td>

                      {/* 2. Category & Source */}
                      <td className="p-3.5">
                        <div className="space-y-1">
                          <span className="inline-block bg-gray-100 text-gray-700 px-2 py-0.5 rounded text-[10px] font-bold">
                            {item.category}
                          </span>
                          <p className="text-[10px] text-gray-400 truncate max-w-[140px]" title={item.source_provider}>
                            {item.source_provider}
                          </p>
                        </div>
                      </td>

                      {/* 3. Editable Purchase Amount */}
                      <td className="p-3.5">
                        <div className="space-y-1">
                          <div className="relative">
                            <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-gray-400 font-bold text-xs">
                              ₹
                            </span>
                            <input
                              type="number"
                              min="0"
                              step="0.5"
                              placeholder="0.00"
                              value={draft.purchasePrice}
                              onChange={(e) => handlePriceChange(item.id, 'purchasePrice', e.target.value)}
                              className="w-full text-xs pl-6 pr-2 py-1.5 font-bold bg-white border border-gray-300 rounded-xl focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none transition-all"
                            />
                          </div>
                          {(!draft.purchasePrice || parseFloat(draft.purchasePrice) <= 0) && (
                            <p className="text-[10px] text-amber-600 font-semibold italic">Missing purchase</p>
                          )}
                        </div>
                      </td>

                      {/* 4. Editable Selling Amount with Live Validation */}
                      <td className="p-3.5">
                        <div className="space-y-1">
                          <div className="relative">
                            <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-gray-400 font-bold text-xs">
                              ₹
                            </span>
                            <input
                              type="number"
                              min="0"
                              step="0.5"
                              placeholder="0.00"
                              value={draft.sellingPrice}
                              onChange={(e) => handlePriceChange(item.id, 'sellingPrice', e.target.value)}
                              className={`w-full text-xs pl-6 pr-2 py-1.5 font-black rounded-xl outline-none transition-all ${
                                hasLoss
                                  ? 'bg-red-50 border-2 border-red-500 text-red-900'
                                  : 'bg-white border border-gray-300 text-emerald-800 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500'
                              }`}
                            />
                          </div>

                          {/* Error Banner when selling < purchase */}
                          {hasLoss ? (
                            <p className="text-[10px] text-red-600 font-bold flex items-center gap-1">
                              <AlertTriangle className="w-3 h-3 text-red-500 shrink-0" />
                              <span>Selling &lt; Purchase (Loss!)</span>
                            </p>
                          ) : (!draft.sellingPrice || parseFloat(draft.sellingPrice) <= 0) ? (
                            <p className="text-[10px] text-amber-600 font-semibold italic">Missing selling</p>
                          ) : null}
                        </div>
                      </td>

                      {/* 5. Automatic Net Margin % Calculation */}
                      <td className="p-3.5">
                        {liveMargin ? (
                          <div className="space-y-0.5">
                            <div
                              className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-lg text-xs font-black ${
                                liveMargin.isLoss
                                  ? 'bg-red-100 text-red-800'
                                  : liveMargin.marginPercent >= 20
                                  ? 'bg-emerald-100 text-emerald-800'
                                  : liveMargin.marginPercent >= 10
                                  ? 'bg-teal-100 text-teal-800'
                                  : 'bg-amber-100 text-amber-800'
                              }`}
                            >
                              {liveMargin.isLoss ? (
                                <TrendingDown className="w-3 h-3" />
                              ) : (
                                <TrendingUp className="w-3 h-3" />
                              )}
                              <span>{liveMargin.marginPercent}%</span>
                            </div>
                            <p className="text-[10px] text-gray-500 font-medium">
                              Profit: {liveMargin.netAmount >= 0 ? `+₹${liveMargin.netAmount}` : `-₹${Math.abs(liveMargin.netAmount)}`}
                            </p>
                          </div>
                        ) : (
                          <span className="text-gray-400 italic text-[11px]">—</span>
                        )}
                      </td>

                      {/* 6. Active Toggle Switch: "Publish to Storefront" */}
                      <td className="p-3.5">
                        <div className="flex items-center gap-2.5">
                          <button
                            type="button"
                            onClick={() => handleToggleStorefront(item)}
                            disabled={draft.isSaving}
                            className={`relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                              item.is_active ? 'bg-emerald-600' : 'bg-gray-300'
                            }`}
                            role="switch"
                            aria-checked={item.is_active}
                            title={
                              item.is_active
                                ? 'Active on Storefront: Click to unpublish'
                                : 'Draft / Hidden: Click to publish to customer storefront'
                            }
                          >
                            <span
                              className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out ${
                                item.is_active ? 'translate-x-5' : 'translate-x-0'
                              }`}
                            />
                          </button>

                          <div className="leading-tight">
                            {item.is_active ? (
                              <span className="text-[11px] font-bold text-emerald-700 flex items-center gap-1">
                                <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                                <span>Published</span>
                              </span>
                            ) : (
                              <span className="text-[11px] font-bold text-gray-500 flex items-center gap-1">
                                <EyeOff className="w-3 h-3 text-gray-400" />
                                <span>Hidden Draft</span>
                              </span>
                            )}
                            <p className="text-[9px] text-gray-400">
                              {item.is_active ? 'Visible to shoppers' : 'Zero customer view'}
                            </p>
                          </div>
                        </div>
                      </td>

                      {/* 7. Quick Save Action Button */}
                      <td className="p-3.5 text-right">
                        <button
                          onClick={() => handleSavePricing(item)}
                          disabled={draft.isSaving || hasLoss}
                          className={`inline-flex items-center gap-1 px-3 py-1.5 rounded-xl font-bold text-[11px] shadow-2xs transition-all active:scale-95 cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed ${
                            hasLoss
                              ? 'bg-gray-200 text-gray-500'
                              : 'bg-emerald-600 hover:bg-emerald-700 text-white'
                          }`}
                        >
                          {draft.isSaving ? (
                            <RefreshCw className="w-3 h-3 animate-spin" />
                          ) : (
                            <Save className="w-3 h-3" />
                          )}
                          <span>Save</span>
                        </button>

                        {/* Inline Row Feedback */}
                        {draft.error && (
                          <p className="text-[10px] text-red-600 font-semibold mt-1 text-right">
                            {draft.error}
                          </p>
                        )}
                        {draft.successMsg && (
                          <p className="text-[10px] text-emerald-600 font-bold mt-1 text-right animate-pulse">
                            ✓ {draft.successMsg}
                          </p>
                        )}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Footer info strip */}
        <div className="p-3 bg-gray-50 border-t border-gray-200 text-xs text-gray-500 flex flex-col sm:flex-row items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <ShieldCheck className="w-4 h-4 text-emerald-600" />
            <span>
              <strong>Safeguard Active:</strong> Backend strictly rejects any product where <code className="bg-gray-200 px-1 py-0.2 rounded font-mono">selling_price &lt; purchase_price</code>.
            </span>
          </div>
          <span className="text-[11px] text-gray-400">
            Connected to <code className="font-mono bg-gray-200 px-1 rounded">POST /api/admin/inventory/update-pricing</code>
          </span>
        </div>
      </div>
    </div>
  );
};

export default AdminInventoryDashboard;
