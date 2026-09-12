import React, { useRef } from 'react';
import { ChevronLeft, ChevronRight, Flame, Percent, History } from 'lucide-react';
import ProductCard from './ProductCard';
import type { Product, CartItem } from '../types';

interface ProductCarouselProps {
  title: string;
  subtitle?: string;
  type: 'trending' | 'deal_of_day' | 'recently_purchased';
  products: Product[];
  cartItems: CartItem[];
  onAddToCart: (product: Product) => void;
  onUpdateQuantity: (product: Product, quantity: number) => void;
  onViewAll?: () => void;
}

const ProductCarousel: React.FC<ProductCarouselProps> = ({
  title,
  subtitle,
  type,
  products,
  cartItems,
  onAddToCart,
  onUpdateQuantity,
  onViewAll,
}) => {
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  const getQuantity = (productId: string) => {
    const item = cartItems.find((i) => i.product.id === productId);
    return item ? item.quantity : 0;
  };

  const handleScroll = (direction: 'left' | 'right') => {
    if (scrollContainerRef.current) {
      const scrollAmount = direction === 'left' ? -320 : 320;
      scrollContainerRef.current.scrollBy({ left: scrollAmount, behavior: 'smooth' });
    }
  };

  const getIcon = () => {
    switch (type) {
      case 'trending':
        return <Flame className="w-5 h-5 text-amber-500 fill-amber-500" />;
      case 'deal_of_day':
        return <Percent className="w-5 h-5 text-rose-500" />;
      case 'recently_purchased':
        return <History className="w-5 h-5 text-blue-500" />;
      default:
        return null;
    }
  };

  if (products.length === 0) return null;

  return (
    <section className="my-6">
      {/* Header with Title and Scroll Controls */}
      <div className="flex items-center justify-between mb-3 px-1">
        <div className="flex items-center gap-2">
          <div className="p-1.5 rounded-lg bg-gray-50 border border-gray-100 shadow-2xs">
            {getIcon()}
          </div>
          <div>
            <h2 className="text-base sm:text-lg font-bold text-gray-900 leading-tight">
              {title}
            </h2>
            {subtitle && (
              <p className="text-xs text-gray-500">{subtitle}</p>
            )}
          </div>
        </div>

        <div className="flex items-center gap-2">
          {onViewAll && (
            <button
              onClick={onViewAll}
              className="text-xs font-bold text-emerald-700 hover:text-emerald-800 hover:underline mr-1"
            >
              see all
            </button>
          )}

          {/* Desktop Left/Right Controls */}
          <div className="hidden sm:flex items-center gap-1">
            <button
              id={`carousel-prev-${type}`}
              onClick={() => handleScroll('left')}
              className="w-8 h-8 rounded-full border border-gray-200 bg-white hover:bg-gray-100 flex items-center justify-center text-gray-600 shadow-xs transition-colors cursor-pointer"
              aria-label="Scroll left"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              id={`carousel-next-${type}`}
              onClick={() => handleScroll('right')}
              className="w-8 h-8 rounded-full border border-gray-200 bg-white hover:bg-gray-100 flex items-center justify-center text-gray-600 shadow-xs transition-colors cursor-pointer"
              aria-label="Scroll right"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Horizontal Scrolling Strip */}
      <div
        ref={scrollContainerRef}
        className="flex items-stretch gap-3 overflow-x-auto no-scrollbar py-1 scroll-smooth snap-x snap-mandatory"
        style={{ scrollbarWidth: 'none' }}
      >
        {products.map((product) => (
          <div
            key={product.id}
            className="w-[160px] sm:w-[190px] md:w-[210px] shrink-0 snap-start flex"
          >
            <ProductCard
              product={product}
              quantity={getQuantity(product.id)}
              onAddToCart={onAddToCart}
              onUpdateQuantity={onUpdateQuantity}
            />
          </div>
        ))}
      </div>
    </section>
  );
};

export default ProductCarousel;
