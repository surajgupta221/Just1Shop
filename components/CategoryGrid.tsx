import React from 'react';
import { CATEGORIES } from '../constants';

interface CategoryGridProps {
  selectedCategory: string;
  onSelectCategory: (categoryId: string) => void;
}

const CategoryGrid: React.FC<CategoryGridProps> = ({
  selectedCategory,
  onSelectCategory,
}) => {
  return (
    <section className="my-5">
      <div className="flex items-center justify-between mb-3 px-1">
        <div>
          <h2 className="text-base sm:text-lg font-bold text-gray-900 leading-tight">
            Explore Categories
          </h2>
          <p className="text-xs text-gray-500">Fresh from dark stores delivered in 8 mins</p>
        </div>
        {selectedCategory !== 'all' && (
          <button
            onClick={() => onSelectCategory('all')}
            className="text-xs font-semibold text-emerald-700 bg-emerald-50 px-2 py-1 rounded-md hover:bg-emerald-100 transition-colors"
          >
            Clear Filter
          </button>
        )}
      </div>

      {/* Multi-row Responsive Grid: 4 cols on mobile, 8 on larger screens */}
      <div className="grid grid-cols-4 sm:grid-cols-4 md:grid-cols-8 gap-2 sm:gap-3">
        {CATEGORIES.map((cat) => {
          const isSelected = selectedCategory === cat.id;

          return (
            <button
              key={cat.id}
              id={`cat-card-${cat.id}`}
              onClick={() => onSelectCategory(cat.id)}
              className={`flex flex-col items-center justify-center p-2.5 rounded-2xl transition-all duration-200 cursor-pointer relative group text-center border ${
                isSelected
                  ? 'border-emerald-600 bg-emerald-50/80 shadow-xs ring-2 ring-emerald-500/20'
                  : 'border-gray-100 bg-white hover:bg-gray-50/80 hover:border-gray-200 shadow-2xs'
              }`}
            >
              {/* Optional Micro-badge */}
              {cat.badge && (
                <span className="absolute -top-1.5 text-[8px] sm:text-[9px] font-bold px-1.5 py-0.2 rounded-full bg-emerald-600 text-white shadow-2xs whitespace-nowrap">
                  {cat.badge}
                </span>
              )}

              {/* Icon Container with subtle gradient */}
              <div
                className={`w-12 h-12 sm:w-14 sm:h-14 rounded-xl flex items-center justify-center text-2xl sm:text-3xl mb-1.5 bg-gradient-to-br ${
                  cat.bgGradient || 'from-gray-50 to-gray-100'
                } group-hover:scale-108 transition-transform duration-200`}
              >
                <span>{cat.icon}</span>
              </div>

              {/* Category Title */}
              <span
                className={`text-[11px] sm:text-xs font-semibold leading-tight line-clamp-2 px-0.5 ${
                  isSelected ? 'text-emerald-800 font-bold' : 'text-gray-700 group-hover:text-gray-900'
                }`}
              >
                {cat.name}
              </span>
            </button>
          );
        })}
      </div>
    </section>
  );
};

export default CategoryGrid;
