import React from 'react';
import { Zap, ShieldCheck, Clock, Award, Heart } from 'lucide-react';

const Footer: React.FC = () => {
  return (
    <footer className="bg-white border-t border-gray-200 mt-12 hidden md:block">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        {/* Value Propositions */}
        <div className="grid grid-cols-4 gap-6 pb-8 border-b border-gray-100">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center shrink-0">
              <Clock className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-bold text-gray-900">Superfast 8-Min Delivery</h4>
              <p className="text-[11px] text-gray-500 mt-0.5">
                Dark store network located within 1.8km radius of your neighborhood.
              </p>
            </div>
          </div>

          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center shrink-0">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-bold text-gray-900">Best Prices & Offers</h4>
              <p className="text-[11px] text-gray-500 mt-0.5">
                Direct mandi sourcing eliminating middleman markup on fresh produce.
              </p>
            </div>
          </div>

          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-xl bg-amber-50 text-amber-700 flex items-center justify-center shrink-0">
              <Award className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-bold text-gray-900">100% Quality Guarantee</h4>
              <p className="text-[11px] text-gray-500 mt-0.5">
                No questions asked instant replacement or refund policy on damaged items.
              </p>
            </div>
          </div>

          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center shrink-0">
              <Zap className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-bold text-gray-900">Wide 5,000+ Catalog</h4>
              <p className="text-[11px] text-gray-500 mt-0.5">
                Dairy, vegetables, munchies, staples, beverages and household essentials.
              </p>
            </div>
          </div>
        </div>

        {/* Brand & Links */}
        <div className="py-8 grid grid-cols-5 gap-6 text-xs text-gray-600">
          <div className="col-span-2 space-y-3">
            <div className="flex items-center gap-1.5">
              <div className="w-7 h-7 rounded-xl bg-emerald-600 flex items-center justify-center text-white font-black text-sm">
                J1
              </div>
              <span className="text-xl font-black text-gray-900 tracking-tight">
                Just<span className="text-emerald-600">1</span>Shop
              </span>
            </div>
            <p className="text-gray-500 text-xs leading-relaxed max-w-sm">
              Just1Shop is an ultra-fast quick-commerce grocery delivery service delivering fresh fruits, vegetables, dairy, bakery, snacks, and daily essentials directly to your doorstep in 8 minutes.
            </p>
            <div className="flex items-center gap-2 pt-1">
              <span className="text-[11px] text-gray-400">Accepted Payments:</span>
              <span className="px-2 py-0.5 rounded bg-gray-100 font-bold text-[10px] text-gray-700">UPI</span>
              <span className="px-2 py-0.5 rounded bg-gray-100 font-bold text-[10px] text-gray-700">GPay</span>
              <span className="px-2 py-0.5 rounded bg-gray-100 font-bold text-[10px] text-gray-700">Cards</span>
              <span className="px-2 py-0.5 rounded bg-gray-100 font-bold text-[10px] text-gray-700">COD</span>
            </div>
          </div>

          <div>
            <h5 className="font-bold text-gray-900 uppercase tracking-wider text-[11px] mb-3">Categories</h5>
            <ul className="space-y-1.5 text-gray-500">
              <li className="hover:text-emerald-700 cursor-pointer">Vegetables & Fruits</li>
              <li className="hover:text-emerald-700 cursor-pointer">Dairy, Bread & Eggs</li>
              <li className="hover:text-emerald-700 cursor-pointer">Munchies & Chips</li>
              <li className="hover:text-emerald-700 cursor-pointer">Cold Drinks & Juices</li>
              <li className="hover:text-emerald-700 cursor-pointer">Atta, Rice & Dal</li>
            </ul>
          </div>

          <div>
            <h5 className="font-bold text-gray-900 uppercase tracking-wider text-[11px] mb-3">Company</h5>
            <ul className="space-y-1.5 text-gray-500">
              <li className="hover:text-emerald-700 cursor-pointer">About Just1Shop</li>
              <li className="hover:text-emerald-700 cursor-pointer">Dark Store Careers</li>
              <li className="hover:text-emerald-700 cursor-pointer">Delivery Partner Signup</li>
              <li className="hover:text-emerald-700 cursor-pointer">Privacy & Terms</li>
              <li className="hover:text-emerald-700 cursor-pointer">Google SEO Sitemap</li>
            </ul>
          </div>

          <div>
            <h5 className="font-bold text-gray-900 uppercase tracking-wider text-[11px] mb-3">Customer Care</h5>
            <ul className="space-y-1.5 text-gray-500">
              <li className="hover:text-emerald-700 cursor-pointer">Track My Order</li>
              <li className="hover:text-emerald-700 cursor-pointer">Instant 1-Click Refund</li>
              <li className="hover:text-emerald-700 cursor-pointer">24x7 Help Center</li>
              <li className="hover:text-emerald-700 cursor-pointer">support@just1shop.com</li>
              <li className="hover:text-emerald-700 cursor-pointer">+91 1800-JUST1SHOP</li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="pt-6 border-t border-gray-100 flex items-center justify-between text-[11px] text-gray-400">
          <p>© {new Date().getFullYear()} Just1Shop Technologies Private Limited. All rights reserved.</p>
          <p className="flex items-center gap-1">
            <span>Engineered with</span>
            <Heart className="w-3 h-3 text-red-500 fill-current" />
            <span>for instant neighborhood grocery delivery</span>
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
