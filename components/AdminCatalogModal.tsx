import React, { useState } from 'react';
import { 
  X, 
  Database, 
  Code, 
  Play, 
  CheckCircle2, 
  AlertTriangle, 
  EyeOff, 
  Eye, 
  Clock, 
  RefreshCw,
  Terminal,
  ShieldAlert,
  Server,
  FileCode2,
  Lock,
  Layers,
  Sparkles
} from 'lucide-react';
import { MASTER_CATALOG_SAMPLES } from '../constants';
import type { MasterCatalogItem, PromoBanner } from '../types';
import AdminInventoryDashboard from './AdminInventoryDashboard';
import BannerManagementTab from './BannerManagementTab';

interface AdminCatalogModalProps {
  isOpen: boolean;
  onClose: () => void;
  onPublishProduct?: (item: MasterCatalogItem, sellingPrice: number, purchasePrice: number, isActive?: boolean) => void;
  banners?: PromoBanner[];
  onUpdateBanners?: (updated: PromoBanner[]) => void;
  initialTab?: 'inventory' | 'banners' | 'api' | 'schema' | 'script' | 'logs';
}

const AdminCatalogModal: React.FC<AdminCatalogModalProps> = ({
  isOpen,
  onClose,
  onPublishProduct,
  banners = [],
  onUpdateBanners,
  initialTab = 'inventory',
}) => {
  const [activeTab, setActiveTab] = useState<'inventory' | 'banners' | 'api' | 'schema' | 'script' | 'logs'>(initialTab);
  const [catalogItems, setCatalogItems] = useState<MasterCatalogItem[]>(MASTER_CATALOG_SAMPLES);
  const [logs, setLogs] = useState<string[]>([
    '[2026-09-12 06:00:00] [Cron] Automated local market wholesale sync initialized.',
    '[2026-09-12 06:00:01] Ingested 6 wholesale grocery items.',
    '[2026-09-12 06:00:02] Unsplash high-res visual asset resolution: 100% matched.',
    '[2026-09-12 06:00:03] [SAFEGUARD ENFORCED] purchase_price: NULL, selling_price: NULL for newly ingested records.',
    '[2026-09-12 06:00:04] Status: pending_admin_pricing. Hidden from customer catalog.',
    '[2026-09-12 07:15:00] [REST API Active] POST /api/admin/inventory/update-pricing listening for admin changes.',
  ]);

  if (!isOpen) return null;

  const handlePublishFromDashboard = (
    item: MasterCatalogItem,
    sellingPrice: number,
    purchasePrice: number,
    isActive: boolean
  ) => {
    if (onPublishProduct) {
      onPublishProduct(item, sellingPrice, purchasePrice, isActive);
    }
    setLogs((prev) => [
      ...prev,
      `[${new Date().toLocaleTimeString()}] 📡 [API POST /api/admin/inventory/update-pricing] "${item.product_title}": Purchase: ₹${purchasePrice}, Selling: ₹${sellingPrice}, is_active: ${isActive} (Storefront: ${isActive ? 'LIVE' : 'HIDDEN'}).`,
    ]);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-2 sm:p-4 bg-black/70 backdrop-blur-xs">
      <div 
        className="bg-white rounded-3xl max-w-6xl w-full max-h-[94vh] shadow-2xl flex flex-col overflow-hidden border border-gray-100 animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 border-b border-gray-100 flex items-center justify-between bg-gray-900 text-white shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-400 to-amber-600 text-gray-950 flex items-center justify-center font-black shadow-xs">
              <Layers className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-base sm:text-lg font-bold">
                  Just1Shop Admin Inventory & Pricing Controller
                </h3>
                <span className="bg-emerald-500 text-gray-950 text-[10px] font-black px-2 py-0.5 rounded-full">
                  REST API VERIFIED
                </span>
              </div>
              <p className="text-xs text-gray-400">
                Manage wholesale pricing, enforce non-negative margins, and publish items to the Zepto-style storefront
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full text-gray-400 hover:text-white hover:bg-gray-800 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Navigation */}
        <div className="flex items-center gap-2 px-4 pt-3 border-b border-gray-200 bg-gray-50 text-xs font-bold overflow-x-auto shrink-0">
          <button
            onClick={() => setActiveTab('inventory')}
            className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 shrink-0 ${
              activeTab === 'inventory'
                ? 'border-emerald-600 text-emerald-800'
                : 'border-transparent text-gray-500 hover:text-gray-900'
            }`}
          >
            <Layers className="w-4 h-4" />
            <span>Pricing & Inventory Dashboard ({catalogItems.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('banners')}
            className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 shrink-0 ${
              activeTab === 'banners'
                ? 'border-emerald-600 text-emerald-800'
                : 'border-transparent text-gray-500 hover:text-gray-900'
            }`}
          >
            <Sparkles className="w-4 h-4 text-amber-500" />
            <span>Festive & Sale Banners ({banners.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('api')}
            className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 shrink-0 ${
              activeTab === 'api'
                ? 'border-emerald-600 text-emerald-800'
                : 'border-transparent text-gray-500 hover:text-gray-900'
            }`}
          >
            <FileCode2 className="w-4 h-4" />
            <span>POST /api/admin/inventory/update-pricing</span>
          </button>

          <button
            onClick={() => setActiveTab('schema')}
            className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 shrink-0 ${
              activeTab === 'schema'
                ? 'border-emerald-600 text-emerald-800'
                : 'border-transparent text-gray-500 hover:text-gray-900'
            }`}
          >
            <Database className="w-4 h-4" />
            <span>Database Schema (PostgreSQL & Mongo)</span>
          </button>

          <button
            onClick={() => setActiveTab('script')}
            className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 shrink-0 ${
              activeTab === 'script'
                ? 'border-emerald-600 text-emerald-800'
                : 'border-transparent text-gray-500 hover:text-gray-900'
            }`}
          >
            <Code className="w-4 h-4" />
            <span>Scraping Pipeline</span>
          </button>

          <button
            onClick={() => setActiveTab('logs')}
            className={`pb-2.5 px-3 border-b-2 transition-colors cursor-pointer flex items-center gap-1.5 shrink-0 ${
              activeTab === 'logs'
                ? 'border-emerald-600 text-emerald-800'
                : 'border-transparent text-gray-500 hover:text-gray-900'
            }`}
          >
            <Terminal className="w-4 h-4" />
            <span>Sync & API Logs</span>
          </button>
        </div>

        {/* Tab Content Area */}
        <div className="flex-grow overflow-y-auto p-4 sm:p-6 bg-gray-50/50">
          {/* TAB 1: Tabular Admin Dashboard */}
          {activeTab === 'inventory' && (
            <AdminInventoryDashboard
              catalogItems={catalogItems}
              onUpdateCatalogItems={(items) => setCatalogItems(items)}
              onPublishToStorefront={handlePublishFromDashboard}
              onViewStorefront={onClose}
            />
          )}

          {/* TAB: Festive & Sale Banners Manager */}
          {activeTab === 'banners' && onUpdateBanners && (
            <BannerManagementTab
              banners={banners}
              onUpdateBanners={onUpdateBanners}
            />
          )}

          {/* TAB 2: REST API Controller Documentation & Code */}
          {activeTab === 'api' && (
            <div className="space-y-4 max-w-4xl">
              <div className="bg-emerald-900 text-emerald-50 p-4 rounded-2xl border border-emerald-800">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="bg-emerald-400 text-emerald-950 px-2 py-0.5 rounded font-black text-xs">POST</span>
                    <code className="text-sm font-bold text-white">/api/admin/inventory/update-pricing</code>
                  </div>
                  <span className="text-xs bg-emerald-800 px-2 py-0.5 rounded-full text-emerald-200">
                    HTTP 200 / 400
                  </span>
                </div>
                <p className="text-xs text-emerald-200 mt-2">
                  Receives <code className="text-white font-mono">product_id</code>, <code className="text-white font-mono">purchase_price</code>, and <code className="text-white font-mono">selling_price</code>. Enforces business rule that <code className="text-white font-mono">selling_price &gt;= purchase_price</code> and automatically calculates the net profit margin percentage to save in the database.
                </p>
              </div>

              {/* Verification Rules Checklist */}
              <div className="bg-white border border-gray-200 p-4 rounded-2xl shadow-2xs space-y-2.5">
                <h4 className="text-xs font-bold text-gray-900 uppercase tracking-wider">
                  Backend Verification Rules & Calculations
                </h4>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 text-xs">
                  <div className="p-3 bg-gray-50 border border-gray-200 rounded-xl space-y-1">
                    <div className="flex items-center gap-1.5 font-bold text-gray-900">
                      <Lock className="w-3.5 h-3.5 text-emerald-600" />
                      <span>Non-Negative Margins</span>
                    </div>
                    <p className="text-[11px] text-gray-500">
                      Rejects request with HTTP 400 if <code className="text-red-600 font-mono">selling_price &lt; purchase_price</code>.
                    </p>
                  </div>

                  <div className="p-3 bg-gray-50 border border-gray-200 rounded-xl space-y-1">
                    <div className="flex items-center gap-1.5 font-bold text-gray-900">
                      <CheckCircle2 className="w-3.5 h-3.5 text-teal-600" />
                      <span>Automated Net Margin %</span>
                    </div>
                    <p className="text-[11px] text-gray-500">
                      Formula: <code className="bg-gray-200 px-1 rounded font-mono">((selling - purchase) / selling) * 100</code> stored directly in DB.
                    </p>
                  </div>

                  <div className="p-3 bg-gray-50 border border-gray-200 rounded-xl space-y-1">
                    <div className="flex items-center gap-1.5 font-bold text-gray-900">
                      <Eye className="w-3.5 h-3.5 text-blue-600" />
                      <span>is_active Storefront Toggle</span>
                    </div>
                    <p className="text-[11px] text-gray-500">
                      Flips boolean in DB. Safeguard prevents activation if prices are zero or missing.
                    </p>
                  </div>
                </div>
              </div>

              {/* Sample Request & Response */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs font-mono">
                <div>
                  <p className="font-bold text-gray-700 mb-1">Request Payload (JSON)</p>
                  <pre className="bg-gray-900 text-emerald-300 p-3.5 rounded-2xl overflow-x-auto text-[11px]">
{`POST /api/admin/inventory/update-pricing
Content-Type: application/json

{
  "product_id": "mc-002",
  "purchase_price": 85,
  "selling_price": 110,
  "is_active": true
}`}
                  </pre>
                </div>

                <div>
                  <p className="font-bold text-gray-700 mb-1">Success Response (HTTP 200)</p>
                  <pre className="bg-gray-900 text-gray-200 p-3.5 rounded-2xl overflow-x-auto text-[11px]">
{`{
  "success": true,
  "message": "Pricing verified & updated successfully",
  "data": {
    "product_id": "mc-002",
    "purchase_price": 85,
    "selling_price": 110,
    "profit_margin_amount": 25,
    "profit_margin_percent": 22.73,
    "is_active": true,
    "status": "active",
    "updated_at": "2026-09-12T07:30:00.000Z"
  }
}`}
                  </pre>
                </div>
              </div>

              {/* Controller Code */}
              <div>
                <p className="font-bold text-gray-700 mb-1 text-xs">
                  Backend Controller Code (<code className="font-mono bg-gray-200 px-1 rounded">/server/controllers/inventoryController.ts</code>)
                </p>
                <pre className="bg-gray-950 text-gray-200 p-4 rounded-2xl overflow-x-auto text-[11px] font-mono max-h-[360px]">
{`export function verifyAndCalculatePricing(purchase_price, selling_price) {
  const purchase = Number(purchase_price);
  const selling = Number(selling_price);

  // Verification rule: selling_price must be >= purchase_price
  if (selling < purchase) {
    return {
      isValid: false,
      code: 'SELLING_PRICE_LESS_THAN_PURCHASE_PRICE',
      error: \`Verification rule violation: Selling price (₹\${selling}) cannot be lower than Purchase price (₹\${purchase}). A negative margin would incur losses.\`,
    };
  }

  // Calculate Net Profit Margin Percentage automatically
  const profit_margin_amount = Number((selling - purchase).toFixed(2));
  const profit_margin_percent = selling > 0 
    ? Number((((selling - purchase) / selling) * 100).toFixed(2)) 
    : 0;

  return {
    isValid: true,
    data: { purchase, selling, profit_margin_amount, profit_margin_percent },
  };
}`}
                </pre>
              </div>
            </div>
          )}

          {/* TAB 3: Schema View */}
          {activeTab === 'schema' && (
            <div className="space-y-4 max-w-4xl">
              <div>
                <h4 className="text-xs font-bold text-gray-900 mb-1 flex items-center gap-1">
                  <Database className="w-4 h-4 text-blue-600" />
                  <span>PostgreSQL DDL with Profit Margin & Safe Storefront View</span>
                </h4>
                <pre className="bg-gray-900 text-gray-200 p-3.5 rounded-2xl text-[11px] font-mono overflow-x-auto">
{`CREATE TABLE master_catalog (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barcode VARCHAR(64) UNIQUE NOT NULL,
    brand_name VARCHAR(128) NOT NULL,
    product_title VARCHAR(255) NOT NULL,
    weight_metric VARCHAR(64) NOT NULL,
    category VARCHAR(100) NOT NULL,
    image_url TEXT,
    
    -- Pricing fields with NULL default
    purchase_price NUMERIC(10, 2) DEFAULT NULL,
    selling_price NUMERIC(10, 2) DEFAULT NULL,
    profit_margin_percent NUMERIC(5, 2) DEFAULT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    status VARCHAR(32) DEFAULT 'pending_admin_pricing',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Storefront safe view excludes unpriced or inactive items
CREATE VIEW customer_storefront_catalog AS
SELECT * FROM master_catalog
WHERE is_active = TRUE AND status = 'active' AND selling_price > 0 AND purchase_price > 0;`}
                </pre>
              </div>
            </div>
          )}

          {/* TAB 4: Script View */}
          {activeTab === 'script' && (
            <div className="space-y-2 max-w-4xl">
              <p className="text-xs text-gray-600">
                Automated wholesale catalog scraping pipeline runner stored in <code className="font-mono bg-gray-200 px-1 py-0.5 rounded">/scripts/catalogSyncPipeline.ts</code>:
              </p>
              <pre className="bg-gray-900 text-emerald-300 p-4 rounded-2xl text-[11px] font-mono overflow-x-auto max-h-[460px]">
{`export async function processAndSaveItem(rawItem: RawMarketItem): Promise<MasterCatalogRecord> {
  const photo = await lookupProductPhoto(rawItem.brand, rawItem.title);

  // Enforces crucial pricing safeguard:
  const record: MasterCatalogRecord = {
    barcode: rawItem.ean_barcode,
    brand_name: rawItem.brand,
    product_title: rawItem.title,
    weight_metric: rawItem.package_size,
    category: rawItem.primary_cat,
    image_url: photo.url,
    purchase_price: null, // STRICT RULE: NULL
    selling_price: null,  // STRICT RULE: NULL
    profit_margin_percent: null,
    is_active: false,     // HIDDEN FROM SHOPPERS
    status: 'pending_admin_pricing',
  };

  return record;
}`}
              </pre>
            </div>
          )}

          {/* TAB 5: Logs View */}
          {activeTab === 'logs' && (
            <div className="bg-gray-950 text-emerald-400 p-4 rounded-2xl font-mono text-xs space-y-1.5 overflow-x-auto shadow-inner border border-gray-800">
              <div className="flex items-center justify-between pb-2 border-b border-gray-800 text-gray-400 text-[11px]">
                <span className="flex items-center gap-1.5">
                  <Terminal className="w-3.5 h-3.5" />
                  <span>Admin & Pipeline Execution Stream</span>
                </span>
                <span>REST API Active</span>
              </div>
              {logs.map((log, i) => (
                <div key={i} className="leading-relaxed">
                  {log}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AdminCatalogModal;
