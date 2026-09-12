import React, { useState } from 'react';
import { 
  PackageCheck, 
  Clock, 
  MapPin, 
  CheckCircle2, 
  Bike, 
  Store, 
  ArrowRight,
  RotateCcw,
  Sparkles
} from 'lucide-react';
import type { Order, Product } from '../types';

interface OrdersViewProps {
  orders: Order[];
  onReorder: (order: Order) => void;
  onExploreProducts: () => void;
}

const OrdersView: React.FC<OrdersViewProps> = ({
  orders,
  onReorder,
  onExploreProducts,
}) => {
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(orders[0] || null);

  const getStatusStep = (status: Order['status']) => {
    switch (status) {
      case 'placed':
        return 1;
      case 'packing':
        return 2;
      case 'out_for_delivery':
        return 3;
      case 'delivered':
        return 4;
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-3 sm:px-4 lg:px-6 py-4 space-y-4">
      {/* Header */}
      <div>
        <h1 className="text-xl sm:text-2xl font-black text-gray-900">Your Orders</h1>
        <p className="text-xs text-gray-500">Live order status, 8-min tracking and past history</p>
      </div>

      {orders.length === 0 ? (
        <div className="bg-white p-12 rounded-3xl border border-gray-100 text-center space-y-4">
          <div className="w-16 h-16 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto">
            <PackageCheck className="w-8 h-8" />
          </div>
          <h3 className="text-base font-bold text-gray-900">No orders placed yet</h3>
          <p className="text-xs text-gray-500 max-w-sm mx-auto">
            Place your first order to experience 8-minute grocery delivery from your nearest dark store!
          </p>
          <button
            onClick={onExploreProducts}
            className="px-5 py-2.5 bg-emerald-600 text-white rounded-xl text-xs font-bold hover:bg-emerald-700 transition-colors cursor-pointer"
          >
            Explore Groceries
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {orders.map((order) => {
            const step = getStatusStep(order.status);
            const isDelivered = order.status === 'delivered';

            return (
              <div
                key={order.id}
                className="bg-white rounded-3xl border border-gray-100 shadow-2xs overflow-hidden p-4 sm:p-5 space-y-4"
              >
                {/* Order Top Bar */}
                <div className="flex flex-wrap items-center justify-between gap-2 border-b border-gray-100 pb-3">
                  <div className="flex items-center gap-2">
                    <div className="w-9 h-9 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center font-bold text-xs">
                      <Clock className="w-4 h-4" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h3 className="text-xs sm:text-sm font-bold text-gray-900">
                          Order #{order.orderNumber}
                        </h3>
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${
                          isDelivered
                            ? 'bg-emerald-100 text-emerald-800'
                            : 'bg-amber-100 text-amber-800 animate-pulse'
                        }`}>
                          {order.status.replace('_', ' ')}
                        </span>
                      </div>
                      <p className="text-[11px] text-gray-400 mt-0.5">{order.date}</p>
                    </div>
                  </div>

                  <div className="text-right">
                    <span className="text-xs sm:text-sm font-black text-gray-900 block">
                      ₹{order.total}
                    </span>
                    <span className="text-[10px] text-emerald-700 font-semibold">
                      {order.deliveryEta}
                    </span>
                  </div>
                </div>

                {/* 4-Step Quick Commerce Live Progress Tracker */}
                <div className="py-2">
                  <div className="grid grid-cols-4 gap-1 relative">
                    {/* Connecting Bar */}
                    <div className="absolute top-3 left-6 right-6 h-1 bg-gray-100 -z-0">
                      <div
                        className="h-full bg-emerald-600 transition-all duration-500"
                        style={{ width: `${((step - 1) / 3) * 100}%` }}
                      />
                    </div>

                    {/* Step 1 */}
                    <div className="flex flex-col items-center text-center z-10">
                      <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold ${
                        step >= 1 ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-400'
                      }`}>
                        ✓
                      </div>
                      <span className="text-[10px] font-bold text-gray-800 mt-1">Confirmed</span>
                    </div>

                    {/* Step 2 */}
                    <div className="flex flex-col items-center text-center z-10">
                      <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold ${
                        step >= 2 ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-400'
                      }`}>
                        <Store className="w-3.5 h-3.5" />
                      </div>
                      <span className="text-[10px] font-bold text-gray-800 mt-1">Packed</span>
                    </div>

                    {/* Step 3 */}
                    <div className="flex flex-col items-center text-center z-10">
                      <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold ${
                        step >= 3 ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-400'
                      }`}>
                        <Bike className="w-3.5 h-3.5" />
                      </div>
                      <span className="text-[10px] font-bold text-gray-800 mt-1">Rider Out</span>
                    </div>

                    {/* Step 4 */}
                    <div className="flex flex-col items-center text-center z-10">
                      <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold ${
                        step >= 4 ? 'bg-emerald-600 text-white' : 'bg-gray-100 text-gray-400'
                      }`}>
                        <CheckCircle2 className="w-3.5 h-3.5" />
                      </div>
                      <span className="text-[10px] font-bold text-gray-800 mt-1">Delivered</span>
                    </div>
                  </div>
                </div>

                {/* Items in Order */}
                <div className="bg-gray-50/70 rounded-2xl p-3 divide-y divide-gray-100">
                  <span className="text-[11px] font-bold uppercase text-gray-400 tracking-wider block mb-2 px-1">
                    Items ({order.items.reduce((s, i) => s + i.quantity, 0)})
                  </span>
                  {order.items.map((item, idx) => (
                    <div key={idx} className="py-2 first:pt-0 flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <img
                          src={item.product.image}
                          alt={item.product.name}
                          className="w-10 h-10 rounded-lg object-cover"
                        />
                        <div>
                          <p className="text-xs font-semibold text-gray-900">{item.product.name}</p>
                          <p className="text-[10px] text-gray-400">
                            {item.quantity} x {item.product.unit} (₹{item.product.price} each)
                          </p>
                        </div>
                      </div>
                      <span className="text-xs font-bold text-gray-900">
                        ₹{item.product.price * item.quantity}
                      </span>
                    </div>
                  ))}
                </div>

                {/* Delivery Address & Actions */}
                <div className="flex flex-wrap items-center justify-between gap-3 pt-2">
                  <div className="flex items-center gap-1.5 text-xs text-gray-500">
                    <MapPin className="w-3.5 h-3.5 text-emerald-600" />
                    <span className="truncate max-w-[280px]">
                      Delivered to: <strong className="text-gray-800">{order.address.title}</strong> ({order.address.addressLine})
                    </span>
                  </div>

                  <button
                    onClick={() => onReorder(order)}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-emerald-50 hover:bg-emerald-100 text-emerald-800 font-bold text-xs transition-colors cursor-pointer"
                  >
                    <RotateCcw className="w-3.5 h-3.5" />
                    <span>Repeat Order</span>
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default OrdersView;
