import React from 'react';
import { Home, LayoutGrid, Search, Clock, User, ShoppingBag } from 'lucide-react';

export type TabType = 'home' | 'categories' | 'search' | 'orders' | 'profile';

interface BottomNavbarProps {
  activeTab: TabType;
  onTabChange: (tab: TabType) => void;
  cartItemCount: number;
  onOpenCart: () => void;
}

const BottomNavbar: React.FC<BottomNavbarProps> = ({
  activeTab,
  onTabChange,
  cartItemCount,
  onOpenCart,
}) => {
  const tabs = [
    { id: 'home' as TabType, label: 'Home', icon: Home },
    { id: 'categories' as TabType, label: 'Categories', icon: LayoutGrid },
    { id: 'search' as TabType, label: 'Search', icon: Search },
    { id: 'orders' as TabType, label: 'Orders', icon: Clock },
    { id: 'profile' as TabType, label: 'Profile', icon: User },
  ];

  return (
    <nav className="md:hidden fixed bottom-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-md border-t border-gray-200 shadow-lg px-2 py-1.5 pb-safe">
      <div className="flex items-center justify-around">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;

          return (
            <button
              key={tab.id}
              id={`nav-tab-${tab.id}`}
              onClick={() => onTabChange(tab.id)}
              className={`flex flex-col items-center justify-center py-1 px-3 rounded-xl transition-all duration-150 cursor-pointer relative ${
                isActive ? 'text-emerald-700' : 'text-gray-500 hover:text-gray-900'
              }`}
            >
              <div className="relative">
                <Icon className={`w-5 h-5 ${isActive ? 'stroke-[2.5px] scale-110' : 'stroke-[1.8px]'}`} />
                {tab.id === 'orders' && (
                  <span className="absolute -top-1 -right-1 w-2 h-2 rounded-full bg-emerald-500" />
                )}
              </div>
              <span
                className={`text-[10px] mt-1 font-medium transition-all ${
                  isActive ? 'font-bold text-emerald-800' : 'text-gray-500'
                }`}
              >
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};

export default BottomNavbar;
