import React, { useState } from 'react';
import { 
  X, 
  ShoppingBag, 
  Plus, 
  Minus, 
  Trash2, 
  Zap, 
  ShieldCheck, 
  ArrowRight,
  HeartHandshake,
  Sparkles
} from 'lucide-react';
import confetti from 'canvas-confetti';
import type { CartItem, Product, Address } from '../types';

interface CartDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  cartItems: CartItem[];
  onUpdateQuantity: (product: Product, quantity: number) => void;
  onRemoveItem: (product: Product) => void;
  currentAddress: Address;
  onPlaceOrder: (orderTotal: number, tip: number) => void;
}

const FREE_DELIVERY_THRESHOLD = 199;
const HANDLING_FEE = 4;
const BASE_DELIVERY_FEE = 25;

const CartDrawer: React.FC<CartDrawerProps> = ({
  isOpen,
  onClose,
  cartItems,
  onUpdateQuantity,
  onRemoveItem,
  currentAddress,
  onPlaceOrder,
}) => {
  const [selectedTip, setSelectedTip] = useState<number>(10);
  const [isPlacingOrder, setIsPlacingOrder] = useState(false);

  if (!isOpen) return null;

  const itemTotal = cartItems.reduce(
    (sum, item) => sum + item.product.price * item.quantity,
    0
  );

  const totalSaved = cartItems.reduce(
    (sum, item) => sum + (Math.max(0, item.product.mrp - item.product.price)) * item.quantity,
    0
  );

  const deliveryFee = itemTotal >= FREE_DELIVERY_THRESHOLD ? 0 : BASE_DELIVERY_FEE;
  const grandTotal = itemTotal > 0 ? itemTotal + deliveryFee + HANDLING_FEE + selectedTip : 0;
  const amountToFreeDelivery = Math.max(0, FREE_DELIVERY_THRESHOLD - itemTotal);

  const handleCheckout = () => {
    setIsPlacingOrder(true);

    // Launch celebration confetti
    confetti({
      particleCount: 80,
      spread: 70,
      origin: { y: 0.6 },
      colors: ['#0c831f', '#facc15', '#2563eb', '#10b981']
    });

    setTimeout(() => {
      setIsPlacingOrder(false);
      onPlaceOrder(grandTotal, selectedTip);
      onClose();
    }, 900);
  };

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-black/60 backdrop-blur-2xs transition-opacity duration-200"
        onClick={onClose}
      />

      {/* Slide-over Panel */}
      <div className="relative w-full max-w-md bg-white h-full shadow-2xl flex flex-col z-10 animate-in slide-in-from-right duration-250">
        {/* Cart Header */}
        <div className="p-4 border-b border-gray-100 flex items-center justify-between bg-white">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
              <ShoppingBag className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-base font-bold text-gray-900 leading-tight">
                My Cart ({cartItems.reduce((acc, i) => acc + i.quantity, 0)} items)
              </h3>
              <div className="flex items-center gap-1 text-[11px] text-emerald-700 font-semibold">
                <Zap className="w-3 h-3 fill-emerald-600" />
                <span>Delivery to {currentAddress.title} in 8 mins</span>
              </div>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-full text-gray-400 hover:text-gray-700 hover:bg-gray-100 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Free Delivery Goal Progress Banner */}
        {cartItems.length > 0 && (
          <div className="bg-emerald-50 px-4 py-2 border-b border-emerald-100">
            {amountToFreeDelivery > 0 ? (
              <div>
                <p className="text-xs text-emerald-900 font-medium">
                  Add <span className="font-bold text-emerald-700">₹{amountToFreeDelivery}</span> more to get <span className="font-bold">FREE Delivery</span>!
                </p>
                <div className="w-full bg-emerald-200 h-1.5 rounded-full mt-1.5 overflow-hidden">
                  <div 
                    className="bg-emerald-600 h-full rounded-full transition-all duration-300"
                    style={{ width: `${Math.min(100, (itemTotal / FREE_DELIVERY_THRESHOLD) * 100)}%` }}
                  />
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-1.5 text-xs text-emerald-800 font-bold">
                <Sparkles className="w-3.5 h-3.5 text-emerald-600" />
                <span>Yay! You unlocked FREE Delivery on this order!</span>
              </div>
            )}
          </div>
        )}

        {/* Cart Items List */}
        <div className="flex-grow overflow-y-auto p-4 divide-y divide-gray-100">
          {cartItems.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center p-6 text-gray-500">
              <div className="w-20 h-20 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-600 mb-4">
                <ShoppingBag className="w-10 h-10" />
              </div>
              <h4 className="text-base font-bold text-gray-900">Your cart is empty</h4>
              <p className="text-xs text-gray-500 mt-1 max-w-xs">
                Explore our fresh vegetables, dairy, snacks, and chilled beverages delivered in 8 minutes!
              </p>
              <button
                onClick={onClose}
                className="mt-5 px-5 py-2.5 rounded-xl bg-emerald-600 text-white font-bold text-xs shadow-sm hover:bg-emerald-700 transition-colors"
              >
                Start Shopping
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              {cartItems.map((item) => (
                <div key={item.product.id} className="pt-3 first:pt-0 flex items-center gap-3">
                  <img
                    src={item.product.image}
                    alt={item.product.name}
                    className="w-14 h-14 rounded-xl object-cover border border-gray-100 shrink-0"
                  />
                  <div className="flex-grow min-w-0">
                    <h4 className="text-xs font-semibold text-gray-900 truncate">
                      {item.product.name}
                    </h4>
                    <p className="text-[11px] text-gray-400 font-medium">
                      {item.product.unit} · ₹{item.product.price}
                    </p>
                    <span className="text-xs font-bold text-gray-900 mt-0.5 block">
                      ₹{item.product.price * item.quantity}
                    </span>
                  </div>

                  {/* Quantity Stepper */}
                  <div className="flex items-center bg-emerald-50 rounded-lg border border-emerald-200 overflow-hidden shrink-0">
                    <button
                      onClick={() => onUpdateQuantity(item.product, item.quantity - 1)}
                      className="px-2 py-1 text-emerald-700 hover:bg-emerald-100 transition-colors"
                    >
                      <Minus className="w-3.5 h-3.5" />
                    </button>
                    <span className="px-2 text-xs font-bold text-emerald-900">
                      {item.quantity}
                    </span>
                    <button
                      onClick={() => onUpdateQuantity(item.product, item.quantity + 1)}
                      className="px-2 py-1 text-emerald-700 hover:bg-emerald-100 transition-colors"
                    >
                      <Plus className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              ))}

              {/* Delivery Tip Section */}
              <div className="pt-4 border-t border-gray-100">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-1.5 text-xs font-bold text-gray-800">
                    <HeartHandshake className="w-4 h-4 text-emerald-600" />
                    <span>Tip your delivery partner</span>
                  </div>
                  <span className="text-[10px] text-gray-500">100% goes to driver</span>
                </div>
                <div className="grid grid-cols-4 gap-2">
                  {[0, 10, 20, 30].map((tip) => (
                    <button
                      key={tip}
                      onClick={() => setSelectedTip(tip)}
                      className={`py-1.5 rounded-xl text-xs font-bold border transition-colors ${
                        selectedTip === tip
                          ? 'border-emerald-600 bg-emerald-600 text-white shadow-xs'
                          : 'border-gray-200 bg-gray-50 text-gray-700 hover:bg-gray-100'
                      }`}
                    >
                      {tip === 0 ? 'No tip' : `₹${tip}`}
                    </button>
                  ))}
                </div>
              </div>

              {/* Bill Summary */}
              <div className="pt-4 border-t border-gray-100 space-y-1.5 text-xs text-gray-600">
                <h5 className="text-xs font-bold uppercase text-gray-400 tracking-wider mb-2">
                  Bill Summary
                </h5>
                <div className="flex justify-between">
                  <span>Item Total</span>
                  <span className="font-semibold text-gray-900">₹{itemTotal}</span>
                </div>
                {totalSaved > 0 && (
                  <div className="flex justify-between text-emerald-700 font-semibold">
                    <span>Discount Savings</span>
                    <span>-₹{totalSaved}</span>
                  </div>
                )}
                <div className="flex justify-between">
                  <span>Delivery Fee</span>
                  <span>
                    {deliveryFee === 0 ? (
                      <span className="text-emerald-600 font-bold">FREE</span>
                    ) : (
                      `₹${deliveryFee}`
                    )}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Handling & Packaging</span>
                  <span className="font-semibold text-gray-900">₹{HANDLING_FEE}</span>
                </div>
                {selectedTip > 0 && (
                  <div className="flex justify-between">
                    <span>Delivery Partner Tip</span>
                    <span className="font-semibold text-gray-900">₹{selectedTip}</span>
                  </div>
                )}
                <div className="flex justify-between pt-2 border-t border-gray-200 text-sm font-black text-gray-900">
                  <span>To Pay</span>
                  <span className="text-emerald-700">₹{grandTotal}</span>
                </div>
              </div>

              {/* Safety & Hygiene Guarantee Badge */}
              <div className="p-3 bg-gray-50 rounded-2xl flex items-center gap-2 text-gray-600 text-xs mt-2">
                <ShieldCheck className="w-5 h-5 text-emerald-600 shrink-0" />
                <span className="text-[11px] leading-snug">
                  Temperature controlled dark stores. 100% hygienic contact-free delivery.
                </span>
              </div>
            </div>
          )}
        </div>

        {/* Sticky Footer: Place Order */}
        {cartItems.length > 0 && (
          <div className="p-4 border-t border-gray-100 bg-white">
            <div className="flex items-center justify-between text-xs text-gray-500 mb-2">
              <span className="truncate">Delivering to: <strong className="text-gray-900">{currentAddress.title}</strong></span>
              <span className="text-emerald-700 font-bold shrink-0">⚡ 8 MINS</span>
            </div>

            <button
              id="checkout-order-btn"
              onClick={handleCheckout}
              disabled={isPlacingOrder}
              className="w-full py-3.5 px-4 rounded-2xl bg-emerald-600 hover:bg-emerald-700 active:bg-emerald-800 text-white font-extrabold text-sm flex items-center justify-between shadow-lg hover:shadow-xl transition-all active:scale-98 cursor-pointer disabled:opacity-75"
            >
              <div className="flex flex-col text-left">
                <span className="text-xs text-emerald-100 font-semibold">Total: ₹{grandTotal}</span>
                <span className="text-sm">Place Order</span>
              </div>
              <div className="flex items-center gap-1">
                <span>{isPlacingOrder ? 'Routing Dark Store...' : 'Instant Checkout'}</span>
                <ArrowRight className="w-4 h-4" />
              </div>
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default CartDrawer;
