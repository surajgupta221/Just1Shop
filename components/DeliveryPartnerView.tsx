import React, { useState } from 'react';
import { 
  Bike, 
  MapPin, 
  Phone, 
  Clock, 
  CheckCircle2, 
  Navigation, 
  Package, 
  AlertTriangle,
  ChevronRight,
  ShieldCheck,
  UserCheck
} from 'lucide-react';
import type { Order, UserProfile, StoreSettings } from '../types';

interface DeliveryPartnerViewProps {
  currentUser: UserProfile;
  orders: Order[];
  onUpdateOrderStatus: (orderId: string, newStatus: 'placed' | 'packing' | 'out_for_delivery' | 'delivered') => void;
  storeSettings: StoreSettings;
  onSwitchRole?: () => void;
}

export const DeliveryPartnerView: React.FC<DeliveryPartnerViewProps> = ({
  currentUser,
  orders,
  onUpdateOrderStatus,
  storeSettings,
  onSwitchRole,
}) => {
  const [activeTab, setActiveTab] = useState<'pending' | 'delivered'>('pending');
  const [activeDeliveryId, setActiveDeliveryId] = useState<string | null>(null);
  const [successToast, setSuccessToast] = useState('');

  const activeOrders = orders.filter((o) => o.status !== 'delivered');
  const completedOrders = orders.filter((o) => o.status === 'delivered');

  const handleStatusClick = (orderId: string, nextStatus: 'out_for_delivery' | 'delivered') => {
    onUpdateOrderStatus(orderId, nextStatus);
    if (nextStatus === 'delivered') {
      setSuccessToast(`Order #${orderId.slice(-4)} marked delivered successfully! Payment confirmed.`);
      setTimeout(() => setSuccessToast(''), 4000);
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-3 sm:px-4 lg:px-6 py-4 space-y-4">
      {/* Toast */}
      {successToast && (
        <div className="p-3 bg-emerald-600 text-white rounded-2xl shadow-lg flex items-center gap-2 text-xs font-bold animate-in slide-in-from-top duration-200">
          <CheckCircle2 className="w-5 h-5 shrink-0" />
          <span>{successToast}</span>
        </div>
      )}

      {/* Driver Status Banner */}
      <div className="bg-gradient-to-r from-emerald-800 to-teal-900 text-white rounded-3xl p-5 shadow-md flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-2xl bg-white text-emerald-800 flex items-center justify-center font-black text-xl shadow-xs">
            <Bike className="w-7 h-7" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-base font-black text-white">{currentUser.name}</h2>
              <span className="bg-emerald-500 text-white text-[10px] font-black px-2 py-0.5 rounded-full uppercase">
                Active On-Duty
              </span>
            </div>
            <p className="text-xs text-emerald-200 mt-0.5">
              Just1Shop Express Fleet · +91 {currentUser.phone}
            </p>
          </div>
        </div>

        <div className="text-right">
          <span className="text-[10px] text-emerald-300 font-bold block uppercase">Hub Origin</span>
          <span className="text-xs font-black text-white truncate max-w-[150px] block">
            {storeSettings.storeName}
          </span>
          <span className="text-[10px] text-yellow-300 font-bold block">
            Max SLA: {storeSettings.maxDeliveryHours}h
          </span>
        </div>
      </div>

      {/* Delivery Metrics Bar */}
      <div className="grid grid-cols-3 gap-2 text-center">
        <div className="bg-white p-3 rounded-2xl border border-gray-100 shadow-2xs">
          <span className="text-[10px] text-gray-400 font-bold uppercase block">Pending Delivery</span>
          <span className="text-lg font-black text-emerald-700">{activeOrders.length}</span>
        </div>
        <div className="bg-white p-3 rounded-2xl border border-gray-100 shadow-2xs">
          <span className="text-[10px] text-gray-400 font-bold uppercase block">Completed Today</span>
          <span className="text-lg font-black text-gray-900">{completedOrders.length}</span>
        </div>
        <div className="bg-white p-3 rounded-2xl border border-gray-100 shadow-2xs">
          <span className="text-[10px] text-gray-400 font-bold uppercase block">On-Time Rating</span>
          <span className="text-lg font-black text-yellow-500">99.4%</span>
        </div>
      </div>

      {/* Tab Switcher */}
      <div className="flex items-center gap-2 bg-gray-100 p-1 rounded-2xl">
        <button
          onClick={() => setActiveTab('pending')}
          className={`flex-1 py-2 text-xs font-extrabold rounded-xl transition-all cursor-pointer ${
            activeTab === 'pending'
              ? 'bg-white text-gray-900 shadow-xs'
              : 'text-gray-500 hover:text-gray-800'
          }`}
        >
          Active Deliveries ({activeOrders.length})
        </button>
        <button
          onClick={() => setActiveTab('delivered')}
          className={`flex-1 py-2 text-xs font-extrabold rounded-xl transition-all cursor-pointer ${
            activeTab === 'delivered'
              ? 'bg-white text-gray-900 shadow-xs'
              : 'text-gray-500 hover:text-gray-800'
          }`}
        >
          Completed History ({completedOrders.length})
        </button>
      </div>

      {/* Deliveries List */}
      <div className="space-y-3">
        {(activeTab === 'pending' ? activeOrders : completedOrders).map((order) => {
          const isOut = order.status === 'out_for_delivery';
          const isDelivered = order.status === 'delivered';

          return (
            <div 
              key={order.id}
              className={`bg-white rounded-3xl p-4 sm:p-5 border transition-all ${
                isOut ? 'border-amber-300 ring-2 ring-amber-400/20 shadow-sm' : 'border-gray-200 shadow-2xs'
              }`}
            >
              <div className="flex items-start justify-between gap-3 border-b border-gray-100 pb-3">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-black text-gray-900">
                      Order {order.orderNumber}
                    </span>
                    <span className={`text-[10px] font-black px-2 py-0.5 rounded-full uppercase ${
                      isDelivered 
                        ? 'bg-emerald-100 text-emerald-800' 
                        : isOut 
                        ? 'bg-amber-100 text-amber-900 animate-pulse' 
                        : 'bg-blue-100 text-blue-800'
                    }`}>
                      {order.status.replace('_', ' ')}
                    </span>
                  </div>
                  <span className="text-[11px] text-gray-500 mt-0.5 block">
                    Placed: {order.date} · {order.items.length} items · Total: ₹{order.total} ({order.paymentMethod})
                  </span>
                </div>

                <div className="text-right">
                  <span className="text-[10px] text-emerald-700 font-extrabold bg-emerald-50 px-2 py-0.5 rounded-lg border border-emerald-200 flex items-center gap-1">
                    <Clock className="w-3 h-3" />
                    Delivery in Under 24h
                  </span>
                </div>
              </div>

              {/* Delivery Address & Contact */}
              <div className="my-3 grid grid-cols-1 sm:grid-cols-2 gap-3 bg-gray-50 p-3 rounded-2xl">
                <div>
                  <span className="text-[10px] text-gray-400 uppercase font-bold block mb-1">
                    Customer Drop Location
                  </span>
                  <p className="text-xs font-bold text-gray-900 flex items-start gap-1.5">
                    <MapPin className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                    <span>
                      {order.address.title}: {order.address.addressLine}
                      {order.address.landmark && ` (Near ${order.address.landmark})`}
                    </span>
                  </p>
                  <span className="text-[11px] text-emerald-700 font-bold ml-5 block mt-0.5">
                    Distance: ~{order.address.distanceKm || 3.2} km from Dark Store
                  </span>
                </div>

                <div className="flex flex-col justify-between sm:items-end">
                  <span className="text-[10px] text-gray-400 uppercase font-bold block mb-1">
                    Customer Contact
                  </span>
                  <div className="flex items-center gap-2">
                    <a
                      href="tel:9844556677"
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-1.5 transition-colors cursor-pointer"
                    >
                      <Phone className="w-3.5 h-3.5" />
                      <span>Call Customer</span>
                    </a>
                    <button
                      type="button"
                      onClick={() => alert(`Opening Google Maps navigation to: ${order.address.addressLine}`)}
                      className="px-3 py-1.5 bg-white hover:bg-gray-100 border border-gray-200 text-gray-800 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-colors cursor-pointer"
                    >
                      <Navigation className="w-3.5 h-3.5 text-blue-600" />
                      <span>Navigate</span>
                    </button>
                  </div>
                </div>
              </div>

              {/* Order Items Preview */}
              <div className="mb-3">
                <span className="text-[10px] text-gray-400 uppercase font-bold block mb-1">
                  Items to Deliver:
                </span>
                <div className="flex flex-wrap gap-1.5">
                  {order.items.map((item, idx) => (
                    <span 
                      key={idx}
                      className="text-[11px] bg-gray-100 text-gray-800 px-2 py-0.5 rounded-lg font-medium"
                    >
                      {item.quantity}x {item.product.name}
                    </span>
                  ))}
                </div>
              </div>

              {/* Action Buttons */}
              {!isDelivered && (
                <div className="flex items-center gap-2 pt-2 border-t border-gray-100">
                  {order.status !== 'out_for_delivery' ? (
                    <button
                      onClick={() => handleStatusClick(order.id, 'out_for_delivery')}
                      className="flex-1 py-2.5 bg-amber-500 hover:bg-amber-600 text-white rounded-xl text-xs font-black flex items-center justify-center gap-2 transition-all cursor-pointer shadow-2xs active:scale-98"
                    >
                      <Bike className="w-4 h-4" />
                      <span>Pick Up & Start Route (Out for Delivery)</span>
                    </button>
                  ) : (
                    <button
                      onClick={() => handleStatusClick(order.id, 'delivered')}
                      className="flex-1 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-black flex items-center justify-center gap-2 transition-all cursor-pointer shadow-2xs active:scale-98"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                      <span>Mark Delivered to Customer (Confirm OTP)</span>
                    </button>
                  )}
                </div>
              )}
            </div>
          );
        })}

        {(activeTab === 'pending' ? activeOrders : completedOrders).length === 0 && (
          <div className="text-center py-10 bg-white rounded-3xl border border-gray-200 p-6">
            <Package className="w-12 h-12 text-gray-300 mx-auto mb-2" />
            <h4 className="text-sm font-bold text-gray-800">No Orders in this Queue</h4>
            <p className="text-xs text-gray-400 mt-1">
              New orders placed within the 24-hour SLA will appear here automatically.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default DeliveryPartnerView;
