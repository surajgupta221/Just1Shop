import React, { useState } from 'react';
import { Plus, Minus, Zap, Star, Check } from 'lucide-react';
import type { Product } from '../types';

interface ProductCardProps {
  product: Product;
  quantity: number;
  onAddToCart: (product: Product) => void;
  onUpdateQuantity: (product: Product, quantity: number) => void;
  onSelectProduct?: (product: Product) => void;
}

const ProductCard: React.FC<ProductCardProps> = ({
  product,
  quantity,
  onAddToCart,
  onUpdateQuantity,
  onSelectProduct,
}) => {
  const [justChanged, setJustChanged] = useState<boolean>(false);

  const triggerAnimation = () => {
    setJustChanged(true);
    setTimeout(() => setJustChanged(false), 200);
  };

  const handleAddClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerAnimation();
    onAddToCart(product);
  };

  const handleDecrement = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerAnimation();
    onUpdateQuantity(product, quantity - 1);
  };

  const handleIncrement = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerAnimation();
    onUpdateQuantity(product, quantity + 1);
  };

  return (
    <div 
      id={`product-card-${product.id}`}
      onClick={() => onSelectProduct && onSelectProduct(product)}
      className="bg-white rounded-2xl border border-gray-100 shadow-2xs hover:shadow-md transition-all duration-200 flex flex-col justify-between overflow-hidden group relative w-full cursor-pointer hover:border-emerald-200"
    >
      {/* Top Badges: Discount & Delivery Time */}
      <div className="absolute top-2.5 left-2.5 right-2.5 flex items-center justify-between z-10 pointer-events-none">
        {product.discountPercent && product.discountPercent > 0 ? (
          <span className="bg-blue-600 text-white text-[10px] font-bold px-1.5 py-0.5 rounded shadow-2xs tracking-tight">
            {product.discountPercent}% OFF
          </span>
        ) : (
          <span />
        )}
        
        {/* Dynamic delivery tag */}
        <div className="flex items-center gap-0.5 bg-white/95 backdrop-blur-xs text-gray-800 text-[10px] font-bold px-1.5 py-0.5 rounded-full shadow-2xs border border-gray-100">
          <Zap className="w-2.5 h-2.5 text-emerald-600 fill-emerald-600" />
          <span>{product.deliveryTime || '8 MINS'}</span>
        </div>
      </div>

      {/* Floating In-Cart Micro Badge */}
      {quantity > 0 && (
        <div className="absolute top-10 left-2.5 z-10 bg-emerald-600 text-white text-[9px] font-black px-1.5 py-0.5 rounded-md shadow-xs flex items-center gap-1 animate-in fade-in zoom-in-95 duration-150 pointer-events-none">
          <Check className="w-2.5 h-2.5 stroke-[3]" />
          <span>{quantity} in cart</span>
        </div>
      )}

      {/* Product Image Area */}
      <div className="relative pt-6 px-3 pb-2 flex items-center justify-center bg-gradient-to-b from-gray-50/60 to-white">
        <div className="w-full aspect-square max-h-36 flex items-center justify-center overflow-hidden rounded-xl bg-gray-50/50">
          <img
            src={product.image}
            alt={product.name}
            className="w-full h-full object-cover object-center group-hover:scale-105 transition-transform duration-300"
            loading="lazy"
          />
        </div>
      </div>

      {/* Product Info */}
      <div className="p-3 pt-1 flex flex-col flex-grow justify-between">
        <div>
          {/* Brand & Unit */}
          <div className="flex items-center justify-between text-[11px] text-gray-500 font-medium mb-1">
            <span className="truncate max-w-[110px] font-semibold text-emerald-700">{product.brand}</span>
            <span className="text-gray-400">{product.unit}</span>
          </div>

          {/* Title */}
          <h3 
            className="text-xs sm:text-sm font-semibold text-gray-800 line-clamp-2 leading-snug group-hover:text-emerald-700 transition-colors"
            title={product.name}
          >
            {product.name}
          </h3>

          {/* Rating */}
          {product.rating && (
            <div className="flex items-center gap-1 mt-1.5">
              <div className="flex items-center gap-0.5 bg-emerald-50 px-1.5 py-0.5 rounded text-[10px] font-bold text-emerald-700 border border-emerald-200">
                <Star className="w-2.5 h-2.5 fill-emerald-600 text-emerald-600" />
                <span>{product.rating}</span>
              </div>
              <span className="text-[10px] text-gray-400 font-medium">({product.ratingCount})</span>
            </div>
          )}
        </div>

        {/* Price & Quick-Add Quantity Badge Stepper */}
        <div className="flex items-center justify-between mt-3 pt-2 border-t border-gray-100">
          <div className="flex flex-col">
            <div className="flex items-baseline gap-1.5">
              <span className="text-sm sm:text-base font-black text-gray-900">
                ₹{product.price}
              </span>
              {product.mrp > product.price && (
                <span className="text-[11px] text-gray-400 line-through">
                  ₹{product.mrp}
                </span>
              )}
            </div>
          </div>

          {/* Inline Quantity Increment/Decrement Stepper Button (Zepto/Blinkit style) */}
          <div className="relative">
            {quantity === 0 ? (
              <button
                id={`add-btn-${product.id}`}
                type="button"
                onClick={handleAddClick}
                className="px-3.5 py-1.5 rounded-xl border border-emerald-600 bg-emerald-50/80 hover:bg-emerald-600 text-emerald-700 hover:text-white font-black text-xs tracking-wider transition-all duration-150 active:scale-90 shadow-2xs hover:shadow-xs cursor-pointer flex items-center gap-1 group/btn"
                title={`Add ${product.name} to cart`}
              >
                <Plus className="w-3 h-3 stroke-[2.5] group-hover/btn:rotate-90 transition-transform duration-200" />
                <span>ADD</span>
              </button>
            ) : (
              <div 
                id={`qty-stepper-${product.id}`}
                className={`flex items-center bg-emerald-600 text-white rounded-xl shadow-xs overflow-hidden border border-emerald-700 transition-transform duration-150 ${
                  justChanged ? 'scale-105 ring-2 ring-emerald-400/50' : 'scale-100'
                }`}
              >
                {/* Decrement Button */}
                <button
                  id={`qty-dec-${product.id}`}
                  type="button"
                  onClick={handleDecrement}
                  className="px-2.5 py-1.5 hover:bg-emerald-700 active:bg-emerald-800 transition-colors cursor-pointer flex items-center justify-center focus:outline-none"
                  title="Decrease quantity"
                  aria-label="Decrease quantity"
                >
                  <Minus className="w-3 h-3 stroke-[2.5]" />
                </button>

                {/* Instant Live Quantity Count */}
                <span className="px-2 font-black text-xs min-w-[22px] text-center select-none tabular-nums text-white">
                  {quantity}
                </span>

                {/* Increment Button */}
                <button
                  id={`qty-inc-${product.id}`}
                  type="button"
                  onClick={handleIncrement}
                  className="px-2.5 py-1.5 hover:bg-emerald-700 active:bg-emerald-800 transition-colors cursor-pointer flex items-center justify-center focus:outline-none"
                  title="Increase quantity"
                  aria-label="Increase quantity"
                >
                  <Plus className="w-3 h-3 stroke-[2.5]" />
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProductCard;

