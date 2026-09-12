import React, { useState, useEffect, useRef } from 'react';
import { 
  Search, 
  X, 
  Sparkles, 
  Tag, 
  ArrowRight, 
  Clock, 
  Check, 
  Plus, 
  Minus, 
  Layers
} from 'lucide-react';
import type { Product, Category, CartItem } from '../types';
import { CATEGORIES, SEARCH_SUGGESTIONS } from '../constants';

interface SmartSearchInputProps {
  searchQuery: string;
  onSearchChange: (query: string) => void;
  products: Product[];
  categories?: Category[];
  cartItems?: CartItem[];
  onAddToCart?: (product: Product) => void;
  onUpdateQuantity?: (product: Product, quantity: number) => void;
  onSelectCategory?: (categoryId: string) => void;
  onSelectProduct?: (product: Product) => void;
  placeholder?: string;
  autoFocus?: boolean;
  debounceMs?: number;
}

// Typo Dictionary for Hyperlocal Quick Commerce
const TYPO_DICTIONARY: Record<string, string> = {
  mlk: 'milk',
  mikl: 'milk',
  milkk: 'milk',
  doodh: 'milk',
  dud: 'milk',
  bred: 'bread',
  braed: 'bread',
  brd: 'bread',
  pav: 'bread',
  chps: 'chips',
  chpis: 'chips',
  layss: 'chips',
  wafers: 'chips',
  namken: 'namkeen',
  egs: 'eggs',
  egss: 'eggs',
  andey: 'eggs',
  ande: 'eggs',
  buttr: 'butter',
  btr: 'butter',
  makhan: 'butter',
  paner: 'paneer',
  panir: 'paneer',
  cottage: 'paneer',
  tmatr: 'tomato',
  tomto: 'tomato',
  tamatar: 'tomato',
  potto: 'potato',
  patato: 'potato',
  aalu: 'potato',
  cofe: 'coffee',
  coffie: 'coffee',
  magi: 'maggi',
  nodls: 'noodles',
  nodles: 'noodles',
  choclat: 'chocolate',
  choclate: 'chocolate',
  avcado: 'avocado',
  avocdo: 'avocado',
  coca: 'coke',
  cola: 'coke',
  atta: 'atta',
  aata: 'atta',
  rice: 'rice',
  chawal: 'rice',
};

export const SmartSearchInput: React.FC<SmartSearchInputProps> = ({
  searchQuery,
  onSearchChange,
  products,
  categories = CATEGORIES,
  cartItems = [],
  onAddToCart,
  onUpdateQuantity,
  onSelectCategory,
  onSelectProduct,
  placeholder,
  autoFocus = false,
  debounceMs = 250,
}) => {
  const [inputValue, setInputValue] = useState<string>(searchQuery);
  const [debouncedQuery, setDebouncedQuery] = useState<string>(searchQuery);
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const [activeCorrection, setActiveCorrection] = useState<{ original: string; corrected: string } | null>(null);
  const [placeholderIndex, setPlaceholderIndex] = useState<number>(0);

  const containerRef = useRef<HTMLDivElement>(null);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  const ROTATING_SEARCH_HINTS = [
    'Search "milk, bread, eggs"',
    'Search "chips, cold drinks, namkeen"',
    'Search "fresh avocados, tomatoes"',
    'Search "maggi, atta, butter, coffee"',
    'Search "cadbury silk, chocolates"',
  ];

  // Sync external prop with local input
  useEffect(() => {
    setInputValue(searchQuery);
  }, [searchQuery]);

  // Placeholder rotation
  useEffect(() => {
    const interval = setInterval(() => {
      setPlaceholderIndex((prev) => (prev + 1) % ROTATING_SEARCH_HINTS.length);
    }, 2800);
    return () => clearInterval(interval);
  }, []);

  // Debounced API / Query Dispatch
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setInputValue(val);
    setIsOpen(true);

    if (timerRef.current) clearTimeout(timerRef.current);

    timerRef.current = setTimeout(() => {
      setDebouncedQuery(val);
      runTypoAndCategoryCheck(val);
      onSearchChange(val);
    }, debounceMs);
  };

  // Typo Auto-Correction Engine
  const runTypoAndCategoryCheck = (query: string) => {
    const clean = query.trim().toLowerCase();
    if (!clean) {
      setActiveCorrection(null);
      return;
    }

    // Check direct match in quick commerce typo dictionary
    if (TYPO_DICTIONARY[clean]) {
      setActiveCorrection({
        original: clean,
        corrected: TYPO_DICTIONARY[clean],
      });
      return;
    }

    // Check individual words
    const words = clean.split(' ');
    for (const word of words) {
      if (TYPO_DICTIONARY[word]) {
        setActiveCorrection({
          original: word,
          corrected: TYPO_DICTIONARY[word],
        });
        return;
      }
    }

    setActiveCorrection(null);
  };

  // Close suggestions on outside click
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Search Effective Term (Use corrected if present, or query)
  const effectiveTerm = activeCorrection ? activeCorrection.corrected : inputValue.trim().toLowerCase();

  // Instant Category Matches
  const matchingCategories = effectiveTerm
    ? categories.filter((cat) => {
        if (cat.id === 'all') return false;
        const nameMatch = cat.name.toLowerCase().includes(effectiveTerm);
        const termInCategory = products.some(
          (p) =>
            p.category === cat.id &&
            (p.name.toLowerCase().includes(effectiveTerm) ||
              p.brand.toLowerCase().includes(effectiveTerm))
        );
        return nameMatch || termInCategory;
      })
    : [];

  // Instant Matching Products
  const matchingProducts = effectiveTerm
    ? products
        .filter(
          (p) =>
            p.name.toLowerCase().includes(effectiveTerm) ||
            p.brand.toLowerCase().includes(effectiveTerm) ||
            p.category.toLowerCase().includes(effectiveTerm) ||
            (p.subcategory && p.subcategory.toLowerCase().includes(effectiveTerm))
        )
        .slice(0, 4)
    : [];

  const handleClear = () => {
    setInputValue('');
    setDebouncedQuery('');
    setActiveCorrection(null);
    onSearchChange('');
  };

  const handleApplyCorrection = (corrected: string) => {
    setInputValue(corrected);
    setDebouncedQuery(corrected);
    setActiveCorrection(null);
    onSearchChange(corrected);
  };

  const getProductQuantity = (productId: string) => {
    const item = cartItems.find((i) => i.product.id === productId);
    return item ? item.quantity : 0;
  };

  return (
    <div ref={containerRef} className="relative w-full">
      {/* Search Input Bar */}
      <div className="relative flex items-center">
        <div className="absolute left-3.5 text-gray-400 pointer-events-none flex items-center justify-center">
          <Search className="w-4 h-4 text-emerald-600" />
        </div>

        <input
          type="text"
          value={inputValue}
          onChange={handleInputChange}
          onFocus={() => setIsOpen(true)}
          autoFocus={autoFocus}
          placeholder={placeholder || ROTATING_SEARCH_HINTS[placeholderIndex]}
          className="w-full pl-10 pr-9 py-2 sm:py-2.5 bg-gray-100 hover:bg-gray-100/90 focus:bg-white text-xs sm:text-sm text-gray-900 rounded-xl border border-transparent focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 outline-none transition-all placeholder:text-gray-400 font-medium"
        />

        {inputValue && (
          <button
            type="button"
            onClick={handleClear}
            className="absolute right-2.5 text-gray-400 hover:text-gray-600 p-1 rounded-full hover:bg-gray-200 transition-colors cursor-pointer"
            title="Clear search"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        )}
      </div>

      {/* Real-time Popover Suggestions & Auto-correction Dropdown */}
      {isOpen && (
        <div className="absolute left-0 right-0 top-full mt-1.5 bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden z-50 animate-in fade-in slide-in-from-top-1 duration-150 max-h-[80vh] overflow-y-auto">
          
          {/* Typo Auto-Correction Notice Banner */}
          {activeCorrection && (
            <div className="p-2.5 bg-amber-50 border-b border-amber-200 flex items-center justify-between text-xs">
              <div className="flex items-center gap-2 text-amber-900">
                <Sparkles className="w-3.5 h-3.5 text-amber-600 shrink-0" />
                <span>
                  Showing results for{' '}
                  <strong className="font-extrabold text-emerald-800 underline">
                    "{activeCorrection.corrected}"
                  </strong>{' '}
                  <span className="text-amber-700 text-[11px]">(corrected from "{activeCorrection.original}")</span>
                </span>
              </div>
              <button
                type="button"
                onClick={() => handleApplyCorrection(activeCorrection.original)}
                className="text-[11px] font-bold text-gray-600 hover:text-gray-900 underline ml-2 cursor-pointer whitespace-nowrap"
              >
                Search "{activeCorrection.original}" instead
              </button>
            </div>
          )}

          {/* Instant Category Matches */}
          {matchingCategories.length > 0 && (
            <div className="p-2.5 border-b border-gray-50 bg-emerald-50/40">
              <span className="text-[10px] font-bold uppercase text-emerald-800 tracking-wider block mb-1.5 flex items-center gap-1">
                <Layers className="w-3 h-3 text-emerald-600" />
                <span>Matching Categories:</span>
              </span>
              <div className="flex flex-wrap gap-1.5">
                {matchingCategories.map((cat) => (
                  <button
                    key={cat.id}
                    type="button"
                    onClick={() => {
                      if (onSelectCategory) onSelectCategory(cat.id);
                      setIsOpen(false);
                    }}
                    className="px-2.5 py-1 text-xs font-bold text-emerald-900 bg-white hover:bg-emerald-600 hover:text-white rounded-lg transition-all border border-emerald-200 shadow-2xs flex items-center gap-1.5 cursor-pointer"
                  >
                    <span>{cat.icon}</span>
                    <span>{cat.name}</span>
                    <span className="text-[10px] opacity-70">({cat.itemCount || 4} items)</span>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Instant Product Previews */}
          {matchingProducts.length > 0 && (
            <div className="p-2.5 border-b border-gray-50">
              <span className="text-[10px] font-bold uppercase text-gray-400 tracking-wider px-1 block mb-1.5">
                Instant Products ({matchingProducts.length})
              </span>
              <div className="space-y-1.5">
                {matchingProducts.map((p) => {
                  const qty = getProductQuantity(p.id);
                  return (
                    <div
                      key={p.id}
                      className="flex items-center justify-between p-2 hover:bg-gray-50 rounded-xl transition-colors group cursor-pointer"
                      onClick={() => {
                        if (onSelectProduct) onSelectProduct(p);
                        setIsOpen(false);
                      }}
                    >
                      <div className="flex items-center gap-2.5 overflow-hidden">
                        <img
                          src={p.image}
                          alt={p.name}
                          className="w-10 h-10 rounded-lg object-cover bg-gray-100 shrink-0"
                        />
                        <div className="overflow-hidden">
                          <p className="text-xs font-bold text-gray-900 group-hover:text-emerald-700 truncate">
                            {p.name}
                          </p>
                          <p className="text-[10px] text-gray-500">
                            {p.unit} · <strong className="text-gray-900">₹{p.price}</strong>
                            {p.mrp > p.price && (
                              <span className="line-through text-gray-400 ml-1">₹{p.mrp}</span>
                            )}
                          </p>
                        </div>
                      </div>

                      {/* Quick-Add Quantity Inline Widget */}
                      <div className="shrink-0 ml-2" onClick={(e) => e.stopPropagation()}>
                        {qty === 0 ? (
                          <button
                            type="button"
                            onClick={() => onAddToCart && onAddToCart(p)}
                            className="px-2.5 py-1 text-xs font-bold text-emerald-700 bg-emerald-50 hover:bg-emerald-600 hover:text-white border border-emerald-600 rounded-lg transition-colors cursor-pointer"
                          >
                            + ADD
                          </button>
                        ) : (
                          <div className="flex items-center bg-emerald-600 text-white rounded-lg shadow-2xs overflow-hidden">
                            <button
                              type="button"
                              onClick={() => onUpdateQuantity && onUpdateQuantity(p, qty - 1)}
                              className="p-1 hover:bg-emerald-700 active:bg-emerald-800 transition-colors cursor-pointer"
                            >
                              <Minus className="w-3 h-3" />
                            </button>
                            <span className="px-1.5 text-xs font-bold">{qty}</span>
                            <button
                              type="button"
                              onClick={() => onUpdateQuantity && onUpdateQuantity(p, qty + 1)}
                              className="p-1 hover:bg-emerald-700 active:bg-emerald-800 transition-colors cursor-pointer"
                            >
                              <Plus className="w-3 h-3" />
                            </button>
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* Trending Grocery Quick Tags */}
          <div className="p-3 bg-gray-50/70">
            <span className="text-[10px] font-bold uppercase text-gray-400 tracking-wider block mb-2">
              Trending Quick Searches
            </span>
            <div className="flex flex-wrap gap-1.5">
              {SEARCH_SUGGESTIONS.slice(0, 8).map((suggestion, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => {
                    setInputValue(suggestion);
                    setDebouncedQuery(suggestion);
                    onSearchChange(suggestion);
                    setIsOpen(false);
                  }}
                  className="px-2.5 py-1 text-xs font-medium rounded-lg bg-white border border-gray-200 hover:border-emerald-300 hover:text-emerald-700 text-gray-700 shadow-2xs transition-colors flex items-center gap-1 cursor-pointer"
                >
                  <Search className="w-3 h-3 text-gray-400" />
                  <span>{suggestion}</span>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default SmartSearchInput;
