import React, { useState } from 'react';
import { CATEGORIES } from '../constants';
import ProductCard from './ProductCard';
import type { Product, CartItem } from '../types';

interface CategoriesViewProps {
  products: Product[];
  cartItems: CartItem[];
  onAddToCart: (product: Product) => void;
  onUpdateQuantity: (product: Product, quantity: number) => void;
  selectedCategory: string;
  onSelectCategory: (categoryId: string) => void;
}

const CategoriesView: React.FC<CategoriesViewProps> = ({
  products,
  cartItems,
  onAddToCart,
  onUpdateQuantity,
  selectedCategory,
  onSelectCategory,
}) => {
  const [activeSubcat, setActiveSubcat] = useState<string>('all');

  const getQuantity = (productId: string) => {
    const item = cartItems.find((i) => i.product.id === productId);
    return item ? item.quantity : 0;
  };

  const filteredProducts = products.filter((p) => {
    const matchesCat = selectedCategory === 'all' || p.category === selectedCategory;
    const matchesSub = activeSubcat === 'all' || p.subcategory === activeSubcat;
    return matchesCat && matchesSub;
  });

  // Extract unique subcategories for selected category
  const availableSubcategories = Array.from(
    new Set(
      products
        .filter((p) => selectedCategory === 'all' || p.category === selectedCategory)
        .map((p) => p.subcategory)
        .filter(Boolean)
    )
  ) as string[];

  return (
    <div className="max-w-7xl mx-auto px-3 sm:px-4 lg:px-6 py-4">
      {/* Category Header */}
      <div className="mb-4">
        <h1 className="text-xl sm:text-2xl font-black text-gray-900">
          All Grocery Categories
        </h1>
        <p className="text-xs text-gray-500">
          Curated dark store catalog refreshed every morning
        </p>
      </div>

      {/* Two Column Layout: Left category rail + Right product grid (Flipkart Grocery / Zepto style) */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 items-start">
        {/* Category List Rail */}
        <div className="md:col-span-1 bg-white p-2 sm:p-3 rounded-2xl border border-gray-100 shadow-2xs space-y-1">
          <span className="text-[11px] font-bold uppercase text-gray-400 tracking-wider px-2 py-1 block">
            Department
          </span>
          {CATEGORIES.map((cat) => {
            const isSelected = selectedCategory === cat.id;
            return (
              <button
                key={cat.id}
                onClick={() => {
                  onSelectCategory(cat.id);
                  setActiveSubcat('all');
                }}
                className={`w-full flex items-center gap-2.5 p-2.5 rounded-xl text-left transition-all cursor-pointer ${
                  isSelected
                    ? 'bg-emerald-600 text-white font-bold shadow-xs'
                    : 'text-gray-700 hover:bg-gray-50 font-medium'
                }`}
              >
                <span className="text-lg">{cat.icon}</span>
                <div className="overflow-hidden">
                  <span className="text-xs truncate block">{cat.name}</span>
                  {cat.badge && !isSelected && (
                    <span className="text-[9px] text-emerald-600 font-semibold">{cat.badge}</span>
                  )}
                </div>
              </button>
            );
          })}
        </div>

        {/* Right Content: Subcategory Chips & Products */}
        <div className="md:col-span-3 space-y-4">
          {/* Subcategory Pills */}
          {availableSubcategories.length > 0 && (
            <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-1">
              <button
                onClick={() => setActiveSubcat('all')}
                className={`px-3 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap cursor-pointer transition-colors ${
                  activeSubcat === 'all'
                    ? 'bg-emerald-700 text-white'
                    : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                }`}
              >
                All ({products.filter((p) => selectedCategory === 'all' || p.category === selectedCategory).length})
              </button>
              {availableSubcategories.map((sub) => (
                <button
                  key={sub}
                  onClick={() => setActiveSubcat(sub)}
                  className={`px-3 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap cursor-pointer transition-colors ${
                    activeSubcat === sub
                      ? 'bg-emerald-700 text-white'
                      : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                  }`}
                >
                  {sub}
                </button>
              ))}
            </div>
          )}

          {/* Products Grid */}
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
            {filteredProducts.map((product) => (
              <ProductCard
                key={product.id}
                product={product}
                quantity={getQuantity(product.id)}
                onAddToCart={onAddToCart}
                onUpdateQuantity={onUpdateQuantity}
              />
            ))}
          </div>

          {filteredProducts.length === 0 && (
            <div className="bg-white p-8 rounded-2xl border border-gray-100 text-center text-gray-500">
              <p className="text-sm font-semibold text-gray-700">No items found in this subcategory</p>
              <button
                onClick={() => setActiveSubcat('all')}
                className="mt-3 text-xs text-emerald-700 font-bold hover:underline"
              >
                View all in category
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default CategoriesView;
