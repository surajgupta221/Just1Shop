import React, { useState } from 'react';
import { Search, ArrowUpDown, X, Sparkles, Layers } from 'lucide-react';
import ProductCard from './ProductCard';
import type { Product, CartItem } from '../types';
import { SEARCH_SUGGESTIONS, CATEGORIES } from '../constants';

interface SearchViewProps {
  products: Product[];
  cartItems: CartItem[];
  onAddToCart: (product: Product) => void;
  onUpdateQuantity: (product: Product, quantity: number) => void;
  searchQuery: string;
  onSearchChange: (query: string) => void;
}

// Quick Typo Map
const SEARCH_TYPOS: Record<string, string> = {
  mlk: 'milk',
  mikl: 'milk',
  milkk: 'milk',
  doodh: 'milk',
  bred: 'bread',
  braed: 'bread',
  brd: 'bread',
  chps: 'chips',
  chpis: 'chips',
  layss: 'chips',
  egs: 'eggs',
  egss: 'eggs',
  buttr: 'butter',
  btr: 'butter',
  paner: 'paneer',
  panir: 'paneer',
  tmatr: 'tomato',
  tomto: 'tomato',
  tamatar: 'tomato',
  potto: 'potato',
  cofe: 'coffee',
  magi: 'maggi',
  nodls: 'noodles',
  choclat: 'chocolate',
  avcado: 'avocado',
  atta: 'atta',
};

const SearchView: React.FC<SearchViewProps> = ({
  products,
  cartItems,
  onAddToCart,
  onUpdateQuantity,
  searchQuery,
  onSearchChange,
}) => {
  const [sortBy, setSortBy] = useState<'relevance' | 'price_low' | 'price_high' | 'rating'>('relevance');

  const getQuantity = (productId: string) => {
    const item = cartItems.find((i) => i.product.id === productId);
    return item ? item.quantity : 0;
  };

  const rawQuery = searchQuery.trim().toLowerCase();
  const correctedTerm = SEARCH_TYPOS[rawQuery] || null;
  const effectiveQuery = correctedTerm || rawQuery;

  const filteredProducts = products.filter((p) => {
    if (!effectiveQuery) return true;
    return (
      p.name.toLowerCase().includes(effectiveQuery) ||
      p.brand.toLowerCase().includes(effectiveQuery) ||
      p.category.toLowerCase().includes(effectiveQuery) ||
      (p.subcategory && p.subcategory.toLowerCase().includes(effectiveQuery))
    );
  });

  const sortedProducts = [...filteredProducts].sort((a, b) => {
    if (sortBy === 'price_low') return a.price - b.price;
    if (sortBy === 'price_high') return b.price - a.price;
    if (sortBy === 'rating') return (b.rating || 0) - (a.rating || 0);
    return 0;
  });

  // Matching Categories
  const matchingCategories = effectiveQuery
    ? CATEGORIES.filter((c) => {
        if (c.id === 'all') return false;
        return (
          c.name.toLowerCase().includes(effectiveQuery) ||
          products.some((p) => p.category === c.id && p.name.toLowerCase().includes(effectiveQuery))
        );
      })
    : [];

  return (
    <div className="max-w-7xl mx-auto px-3 sm:px-4 lg:px-6 py-4 space-y-4">
      {/* Search Input Bar with Filter Controls */}
      <div className="bg-white p-3 sm:p-4 rounded-2xl border border-gray-100 shadow-2xs space-y-3">
        <div className="relative">
          <Search className="w-5 h-5 absolute left-3.5 top-1/2 -translate-y-1/2 text-emerald-600" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search groceries, brands, vegetables, milk..."
            className="w-full pl-11 pr-10 py-3 bg-gray-100 rounded-xl text-sm text-gray-900 placeholder:text-gray-400 focus:bg-white focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 outline-none border border-transparent transition-all font-medium"
            autoFocus
          />
          {searchQuery && (
            <button
              onClick={() => onSearchChange('')}
              className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 p-1 cursor-pointer"
            >
              <X className="w-4 h-4" />
            </button>
          )}
        </div>

        {/* Quick Suggestion Pills */}
        <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar py-1">
          <span className="text-[11px] font-bold text-gray-400 uppercase tracking-wider shrink-0 mr-1">
            Popular:
          </span>
          {SEARCH_SUGGESTIONS.map((tag, idx) => (
            <button
              key={idx}
              onClick={() => onSearchChange(tag)}
              className="px-2.5 py-1 text-xs font-semibold rounded-lg bg-gray-100 hover:bg-emerald-50 hover:text-emerald-700 text-gray-700 shrink-0 transition-colors cursor-pointer"
            >
              {tag}
            </button>
          ))}
        </div>
      </div>

      {/* Typo Auto-Correction Notice Banner */}
      {correctedTerm && (
        <div className="p-3 bg-amber-50 rounded-2xl border border-amber-200 flex items-center justify-between text-xs">
          <div className="flex items-center gap-2 text-amber-900">
            <Sparkles className="w-4 h-4 text-amber-600 shrink-0" />
            <span>
              Showing results for{' '}
              <strong className="font-black text-emerald-800 text-sm underline">
                "{correctedTerm}"
              </strong>{' '}
              <span className="text-amber-700">(auto-corrected from "{rawQuery}")</span>
            </span>
          </div>
          <button
            type="button"
            onClick={() => onSearchChange(rawQuery)}
            className="text-xs font-bold text-gray-600 hover:text-gray-900 underline ml-2 cursor-pointer whitespace-nowrap"
          >
            Search literal "{rawQuery}"
          </button>
        </div>
      )}

      {/* Category Match Badges */}
      {matchingCategories.length > 0 && (
        <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-1">
          <span className="text-xs font-bold text-gray-500 flex items-center gap-1 shrink-0">
            <Layers className="w-3.5 h-3.5 text-emerald-600" />
            Categories:
          </span>
          {matchingCategories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => onSearchChange(cat.name.split(' ')[0])}
              className="px-2.5 py-1 bg-emerald-50 text-emerald-800 text-xs font-bold rounded-lg border border-emerald-200 flex items-center gap-1 cursor-pointer hover:bg-emerald-600 hover:text-white transition-all shadow-2xs shrink-0"
            >
              <span>{cat.icon}</span>
              <span>{cat.name}</span>
            </button>
          ))}
        </div>
      )}

      {/* Results Header with Sorting */}
      <div className="flex items-center justify-between px-1">
        <span className="text-xs font-semibold text-gray-500">
          Showing <strong className="text-gray-900">{sortedProducts.length}</strong> items {effectiveQuery && `for "${effectiveQuery}"`}
        </span>
        <div className="flex items-center gap-2">
          <ArrowUpDown className="w-3.5 h-3.5 text-gray-400" />
          <select
            value={sortBy}
            onChange={(e: any) => setSortBy(e.target.value)}
            className="text-xs font-semibold text-gray-700 bg-white border border-gray-200 rounded-lg px-2 py-1 outline-none focus:border-emerald-500 cursor-pointer"
          >
            <option value="relevance">Sort: Relevance</option>
            <option value="price_low">Price: Low to High</option>
            <option value="price_high">Price: High to Low</option>
            <option value="rating">Top Rated</option>
          </select>
        </div>
      </div>

      {/* Products Grid with Quick-Add Quantity Badges */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
        {sortedProducts.map((product) => (
          <ProductCard
            key={product.id}
            product={product}
            quantity={getQuantity(product.id)}
            onAddToCart={onAddToCart}
            onUpdateQuantity={onUpdateQuantity}
          />
        ))}
      </div>

      {sortedProducts.length === 0 && (
        <div className="bg-white p-12 rounded-3xl border border-gray-100 text-center space-y-3">
          <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto text-gray-400">
            <Search className="w-8 h-8" />
          </div>
          <h3 className="text-base font-bold text-gray-900">No matching items found</h3>
          <p className="text-xs text-gray-500 max-w-sm mx-auto">
            Try searching for another keyword or check out trending items like milk, bread, eggs, and snacks.
          </p>
          <button
            onClick={() => onSearchChange('')}
            className="px-4 py-2 bg-emerald-600 text-white rounded-xl text-xs font-bold hover:bg-emerald-700 cursor-pointer"
          >
            Reset Search
          </button>
        </div>
      )}
    </div>
  );
};

export default SearchView;
