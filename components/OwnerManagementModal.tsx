import React, { useState } from 'react';
import { 
  X, 
  Award, 
  Users, 
  MapPin, 
  Sliders, 
  Clock, 
  ShieldCheck, 
  Bike, 
  ShoppingBag, 
  Plus, 
  CheckCircle2, 
  AlertCircle, 
  Save, 
  Navigation,
  Phone,
  Mail,
  Zap,
  Radio,
  Eye,
  Package,
  Layers,
  Check
} from 'lucide-react';
import type { UserProfile, UserRole, StoreSettings, Order } from '../types';

interface OwnerManagementModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentUser: UserProfile;
  allUsers: UserProfile[];
  onUpdateUsers: (users: UserProfile[]) => void;
  storeSettings: StoreSettings;
  onUpdateStoreSettings: (settings: StoreSettings) => void;
  orders: Order[];
  onOpenMapPicker?: () => void;
  onSwitchSimulatedRole?: (targetRole: UserRole) => void;
}

export const OwnerManagementModal: React.FC<OwnerManagementModalProps> = ({
  isOpen,
  onClose,
  currentUser,
  allUsers,
  onUpdateUsers,
  storeSettings,
  onUpdateStoreSettings,
  orders,
  onOpenMapPicker,
  onSwitchSimulatedRole,
}) => {
  const [activeTab, setActiveTab] = useState<'roles' | 'delivery_zone' | 'orders'>('roles');

  // New staff form state
  const [newStaffName, setNewStaffName] = useState('');
  const [newStaffPhone, setNewStaffPhone] = useState('');
  const [newStaffEmail, setNewStaffEmail] = useState('');
  const [newStaffRole, setNewStaffRole] = useState<UserRole>('delivery');
  const [formSuccess, setFormSuccess] = useState('');
  const [formError, setFormError] = useState('');

  // Store settings form state
  const [localSettings, setLocalSettings] = useState<StoreSettings>(storeSettings);
  const [settingsSavedMsg, setSettingsSavedMsg] = useState('');

  if (!isOpen) return null;

  // Compute live parcel counts carried by each delivery boy
  const getRiderParcels = (riderId: string) => {
    const riderOrders = orders.filter((o) => o.assignedRiderId === riderId);
    const activeCarriedOrders = riderOrders.filter((o) => o.status !== 'delivered');
    const totalParcelsCarried = activeCarriedOrders.reduce((sum, o) => {
      const itemsCount = o.items.reduce((acc, item) => acc + item.quantity, 0);
      return sum + itemsCount;
    }, 0);
    const deliveredCount = riderOrders.filter((o) => o.status === 'delivered').length;

    return {
      activeOrdersCount: activeCarriedOrders.length,
      totalParcelsCarried,
      deliveredCount,
      activeOrders: activeCarriedOrders,
    };
  };

  // Handle changing user role
  const handleRoleChange = (userId: string, newRole: UserRole) => {
    const updated = allUsers.map((u) => {
      if (u.id === userId) {
        return { ...u, role: newRole };
      }
      return u;
    });
    onUpdateUsers(updated);
  };

  // Handle toggle user active status
  const handleToggleActive = (userId: string) => {
    const updated = allUsers.map((u) => {
      if (u.id === userId) {
        return { ...u, isActive: !u.isActive };
      }
      return u;
    });
    onUpdateUsers(updated);
  };

  // Handle adding new staff member
  const handleAddStaff = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanPhone = newStaffPhone.trim().replace(/\D/g, '');
    if (!newStaffName.trim()) {
      setFormError('Please enter the team member name.');
      return;
    }
    if (cleanPhone.length !== 10) {
      setFormError('Please enter a valid 10-digit mobile number.');
      return;
    }

    // Check if phone already registered
    const existing = allUsers.find((u) => u.phone === cleanPhone);
    if (existing) {
      setFormError(`Mobile +91 ${cleanPhone} is already registered as ${existing.name} (${existing.role}).`);
      return;
    }

    const newUser: UserProfile = {
      id: `usr-${Date.now()}`,
      name: newStaffName.trim(),
      phone: cleanPhone,
      email: newStaffEmail.trim() || undefined,
      role: newStaffRole,
      createdAt: new Date().toISOString().split('T')[0],
      isActive: true,
      assignedOrdersCount: newStaffRole === 'delivery' ? 0 : undefined,
    };

    onUpdateUsers([...allUsers, newUser]);
    setNewStaffName('');
    setNewStaffPhone('');
    setNewStaffEmail('');
    setFormError('');
    setFormSuccess(`Successfully onboarded ${newUser.name} as ${newUser.role.toUpperCase()}! They can now log in using +91 ${cleanPhone}`);
    setTimeout(() => setFormSuccess(''), 5000);
  };

  // Handle saving store & delivery radius settings
  const handleSaveSettings = (e: React.FormEvent) => {
    e.preventDefault();
    onUpdateStoreSettings(localSettings);
    setSettingsSavedMsg('Store origin location and 24h delivery radius updated successfully!');
    setTimeout(() => setSettingsSavedMsg(''), 4000);
  };

  const getRoleBadge = (role: UserRole) => {
    switch (role) {
      case 'owner':
        return (
          <span className="bg-amber-100 text-amber-900 border border-amber-300 text-xs font-black px-2.5 py-0.5 rounded-full flex items-center gap-1">
            <Award className="w-3 h-3 text-amber-600" />
            Store Owner
          </span>
        );
      case 'admin':
        return (
          <span className="bg-blue-100 text-blue-900 border border-blue-300 text-xs font-black px-2.5 py-0.5 rounded-full flex items-center gap-1">
            <ShieldCheck className="w-3 h-3 text-blue-600" />
            Admin
          </span>
        );
      case 'delivery':
        return (
          <span className="bg-emerald-100 text-emerald-900 border border-emerald-300 text-xs font-black px-2.5 py-0.5 rounded-full flex items-center gap-1">
            <Bike className="w-3 h-3 text-emerald-700" />
            Delivery Boy
          </span>
        );
      default:
        return (
          <span className="bg-gray-100 text-gray-800 border border-gray-200 text-xs font-semibold px-2.5 py-0.5 rounded-full flex items-center gap-1">
            <ShoppingBag className="w-3 h-3 text-gray-500" />
            Customer
          </span>
        );
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-2 sm:p-4 bg-black/75 backdrop-blur-xs">
      <div 
        className="bg-white rounded-3xl max-w-5xl w-full max-h-[94vh] shadow-2xl flex flex-col overflow-hidden border border-gray-100 animate-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header Bar */}
        <div className="p-4 sm:p-5 border-b border-gray-100 flex items-center justify-between bg-slate-900 text-white shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-amber-400 to-amber-600 text-gray-950 flex items-center justify-center font-black shadow-md">
              <Award className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-base sm:text-lg font-black text-white">
                  Owner Command Center
                </h2>
                <span className="bg-amber-400 text-gray-950 text-[10px] font-black px-2 py-0.5 rounded-full uppercase">
                  Master Store Access
                </span>
              </div>
              <p className="text-xs text-slate-300 mt-0.5">
                Staff management, parcel carriage monitor & simulated role perspective inspector
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="w-9 h-9 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white flex items-center justify-center transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* OWNER PERSPECTIVE INSPECTOR BAR (Role Switcher) */}
        <div className="bg-gradient-to-r from-amber-500/15 via-indigo-500/10 to-emerald-500/15 border-b border-amber-200/60 p-3 sm:px-6 flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center">
              <Eye className="w-4 h-4" />
            </div>
            <div>
              <span className="text-xs font-black text-gray-900 block leading-none">
                Inspect App Perspective (Owner Role Simulation)
              </span>
              <span className="text-[11px] text-gray-600">
                Choose a role to test and preview how the UI looks and behaves:
              </span>
            </div>
          </div>

          {/* Quick Switch Dropdown / Buttons */}
          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={() => {
                if (onSwitchSimulatedRole) onSwitchSimulatedRole('owner');
                onClose();
              }}
              className={`px-3 py-1.5 rounded-xl text-xs font-black flex items-center gap-1.5 transition-all cursor-pointer ${
                currentUser.role === 'owner'
                  ? 'bg-amber-500 text-slate-950 shadow-xs'
                  : 'bg-white hover:bg-amber-50 text-amber-900 border border-amber-300'
              }`}
            >
              <Award className="w-3.5 h-3.5" />
              <span>👑 Owner View</span>
            </button>

            <button
              type="button"
              onClick={() => {
                if (onSwitchSimulatedRole) onSwitchSimulatedRole('admin');
                onClose();
              }}
              className={`px-3 py-1.5 rounded-xl text-xs font-black flex items-center gap-1.5 transition-all cursor-pointer ${
                currentUser.role === 'admin'
                  ? 'bg-blue-600 text-white shadow-xs'
                  : 'bg-white hover:bg-blue-50 text-blue-800 border border-blue-200'
              }`}
            >
              <ShieldCheck className="w-3.5 h-3.5 text-blue-600" />
              <span>🛡️ Admin View</span>
            </button>

            <button
              type="button"
              onClick={() => {
                if (onSwitchSimulatedRole) onSwitchSimulatedRole('delivery');
                onClose();
              }}
              className={`px-3 py-1.5 rounded-xl text-xs font-black flex items-center gap-1.5 transition-all cursor-pointer ${
                currentUser.role === 'delivery'
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'bg-white hover:bg-emerald-50 text-emerald-800 border border-emerald-200'
              }`}
            >
              <Bike className="w-3.5 h-3.5 text-emerald-600" />
              <span>🛵 Delivery Boy View</span>
            </button>

            <button
              type="button"
              onClick={() => {
                if (onSwitchSimulatedRole) onSwitchSimulatedRole('user');
                onClose();
              }}
              className={`px-3 py-1.5 rounded-xl text-xs font-black flex items-center gap-1.5 transition-all cursor-pointer ${
                currentUser.role === 'user'
                  ? 'bg-gray-800 text-white shadow-xs'
                  : 'bg-white hover:bg-gray-50 text-gray-800 border border-gray-200'
              }`}
            >
              <ShoppingBag className="w-3.5 h-3.5 text-gray-600" />
              <span>🛍️ Customer View</span>
            </button>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="flex items-center gap-2 p-3 bg-gray-50 border-b border-gray-200 overflow-x-auto shrink-0">
          <button
            onClick={() => setActiveTab('roles')}
            className={`px-4 py-2 rounded-xl text-xs font-extrabold flex items-center gap-2 transition-all cursor-pointer whitespace-nowrap ${
              activeTab === 'roles'
                ? 'bg-slate-900 text-white shadow-xs'
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            <Users className="w-4 h-4" />
            <span>Staff Roles & Roster ({allUsers.length})</span>
          </button>

          <button
            onClick={() => setActiveTab('orders')}
            className={`px-4 py-2 rounded-xl text-xs font-extrabold flex items-center gap-2 transition-all cursor-pointer whitespace-nowrap ${
              activeTab === 'orders'
                ? 'bg-slate-900 text-white shadow-xs'
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            <Package className="w-4 h-4 text-emerald-500" />
            <span>Delivery Fleet & Parcels Carried ({allUsers.filter(u => u.role === 'delivery').length} Riders)</span>
          </button>

          <button
            onClick={() => setActiveTab('delivery_zone')}
            className={`px-4 py-2 rounded-xl text-xs font-extrabold flex items-center gap-2 transition-all cursor-pointer whitespace-nowrap ${
              activeTab === 'delivery_zone'
                ? 'bg-slate-900 text-white shadow-xs'
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            <MapPin className="w-4 h-4 text-amber-500" />
            <span>Dark Store Hub & Service Radius ({localSettings.serviceRadiusKm} km)</span>
          </button>
        </div>

        {/* Tab Content */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-6">
          {/* TAB 1: TEAM & ROLE DECISION MANAGER */}
          {activeTab === 'roles' && (
            <div className="space-y-6">
              {/* Success / Error Banners */}
              {formSuccess && (
                <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-2xl flex items-center gap-2 text-xs font-bold text-emerald-800 animate-in fade-in">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  <span>{formSuccess}</span>
                </div>
              )}

              {formError && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-2xl flex items-center gap-2 text-xs font-bold text-red-700 animate-in fade-in">
                  <AlertCircle className="w-4 h-4 text-red-600 shrink-0" />
                  <span>{formError}</span>
                </div>
              )}

              {/* Add New Staff / Assign Role Card */}
              <div className="bg-slate-50 border border-slate-200 rounded-2xl p-4 sm:p-5">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className="w-6 h-6 rounded-lg bg-indigo-600 text-white flex items-center justify-center font-bold text-xs">
                      +
                    </span>
                    <h3 className="text-sm font-black text-gray-900">
                      Appoint New Staff (Delivery Boy / Store Admin)
                    </h3>
                  </div>
                  <span className="text-[11px] text-gray-500">
                    Staff members log in using their verified phone number
                  </span>
                </div>

                <form onSubmit={handleAddStaff} className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                  <div>
                    <label className="text-xs font-bold text-gray-700 block mb-1">
                      Full Name *
                    </label>
                    <input
                      type="text"
                      placeholder="e.g. Ramesh Kumar"
                      value={newStaffName}
                      onChange={(e) => setNewStaffName(e.target.value)}
                      className="w-full px-3 py-2 bg-white border border-gray-200 rounded-xl text-xs font-medium text-gray-900 outline-none focus:border-indigo-500"
                    />
                  </div>

                  <div>
                    <label className="text-xs font-bold text-gray-700 block mb-1">
                      Phone Number * (10 Digits)
                    </label>
                    <div className="flex items-center bg-white border border-gray-200 rounded-xl overflow-hidden focus-within:border-indigo-500">
                      <span className="text-xs text-gray-500 pl-2.5 font-bold">+91</span>
                      <input
                        type="tel"
                        maxLength={10}
                        placeholder="9876543210"
                        value={newStaffPhone}
                        onChange={(e) => setNewStaffPhone(e.target.value.replace(/\D/g, ''))}
                        className="w-full px-2 py-2 text-xs font-medium text-gray-900 outline-none bg-transparent"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="text-xs font-bold text-gray-700 block mb-1">
                      Assigned Role *
                    </label>
                    <select
                      value={newStaffRole}
                      onChange={(e) => setNewStaffRole(e.target.value as UserRole)}
                      className="w-full px-3 py-2 bg-white border border-gray-200 rounded-xl text-xs font-bold text-gray-800 outline-none focus:border-indigo-500 cursor-pointer"
                    >
                      <option value="delivery">🛵 Delivery Boy (Deliver orders)</option>
                      <option value="admin">🛡️ Admin (Manage store ops & pricing)</option>
                      <option value="user">🛍️ Customer (Order groceries)</option>
                    </select>
                  </div>

                  <div className="flex items-end">
                    <button
                      type="submit"
                      className="w-full py-2 px-4 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-black flex items-center justify-center gap-1.5 shadow-sm transition-colors cursor-pointer"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Save & Assign Role</span>
                    </button>
                  </div>
                </form>
              </div>

              {/* User Roster Table */}
              <div className="bg-white rounded-2xl border border-gray-200 overflow-hidden shadow-2xs">
                <div className="p-3.5 bg-gray-50 border-b border-gray-200 flex items-center justify-between">
                  <span className="text-xs font-black text-gray-900 uppercase tracking-wide">
                    All Registered Accounts & Role Assignments
                  </span>
                  <span className="text-xs text-gray-500">
                    Owner can reassign any role anytime
                  </span>
                </div>

                <div className="divide-y divide-gray-100 overflow-x-auto">
                  {allUsers.map((user) => {
                    const isMasterOwner = user.phone === '8987767301';
                    const riderMetrics = user.role === 'delivery' ? getRiderParcels(user.id) : null;

                    return (
                      <div key={user.id} className="p-3.5 flex items-center justify-between gap-3 hover:bg-gray-50/80 transition-colors">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center font-bold text-sm overflow-hidden shrink-0">
                            {user.avatar ? (
                              <img src={user.avatar} alt={user.name} className="w-full h-full object-cover" />
                            ) : (
                              user.name.slice(0, 2).toUpperCase()
                            )}
                          </div>

                          <div>
                            <div className="flex items-center gap-2">
                              <span className="text-xs font-black text-gray-900">{user.name}</span>
                              {getRoleBadge(user.role)}
                              {isMasterOwner && (
                                <span className="bg-amber-400 text-gray-950 text-[9px] font-black px-1.5 py-0.2 rounded-full">
                                  MASTER OWNER
                                </span>
                              )}
                              {riderMetrics && (
                                <span className="bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold px-2 py-0.5 rounded-md flex items-center gap-1">
                                  <Package className="w-3 h-3 text-emerald-600" />
                                  {riderMetrics.totalParcelsCarried} parcels active
                                </span>
                              )}
                            </div>
                            <div className="flex items-center gap-2 text-[11px] text-gray-500 mt-0.5">
                              <span className="flex items-center gap-1">
                                <Phone className="w-3 h-3 text-emerald-600" />
                                +91 {user.phone}
                              </span>
                              {user.email && (
                                <span>· {user.email}</span>
                              )}
                              <span>· Joined: {user.createdAt}</span>
                            </div>
                          </div>
                        </div>

                        {/* Role Selector Controls */}
                        <div className="flex items-center gap-2 shrink-0">
                          {isMasterOwner ? (
                            <span className="text-xs font-bold text-amber-700 bg-amber-50 px-3 py-1.5 rounded-xl border border-amber-200">
                              Permanent Store Owner
                            </span>
                          ) : (
                            <div className="flex items-center gap-2">
                              <select
                                value={user.role}
                                onChange={(e) => handleRoleChange(user.id, e.target.value as UserRole)}
                                className="px-2.5 py-1.5 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-gray-800 outline-none focus:border-indigo-500 cursor-pointer"
                              >
                                <option value="user">Customer</option>
                                <option value="delivery">Delivery Boy</option>
                                <option value="admin">Admin</option>
                              </select>

                              <button
                                type="button"
                                onClick={() => handleToggleActive(user.id)}
                                className={`px-2.5 py-1.5 rounded-xl text-xs font-bold transition-colors cursor-pointer ${
                                  user.isActive
                                    ? 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200'
                                    : 'bg-red-50 text-red-700 hover:bg-red-100 border border-red-200'
                                }`}
                              >
                                {user.isActive ? 'Active' : 'Suspended'}
                              </button>
                            </div>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: DELIVERY FLEET DISPATCH & PARCEL CARRIAGE MONITOR */}
          {activeTab === 'orders' && (
            <div className="space-y-6">
              <div>
                <h3 className="text-base font-black text-gray-900 flex items-center gap-2">
                  <Bike className="w-5 h-5 text-emerald-600" />
                  <span>Delivery Fleet & Live Parcels Carried</span>
                </h3>
                <p className="text-xs text-gray-500 mt-0.5">
                  Monitor how many delivery boys are active and the exact count of grocery parcels each rider is carrying right now.
                </p>
              </div>

              {/* Fleet Summary KPI Row */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 flex items-center justify-between">
                  <div>
                    <span className="text-[10px] text-emerald-700 font-black uppercase tracking-wider block">
                      Active Delivery Boys
                    </span>
                    <span className="text-2xl font-black text-emerald-950 mt-0.5 block">
                      {allUsers.filter((u) => u.role === 'delivery' && u.isActive).length}
                    </span>
                  </div>
                  <div className="w-10 h-10 rounded-xl bg-emerald-600 text-white flex items-center justify-center">
                    <Bike className="w-5 h-5" />
                  </div>
                </div>

                <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 flex items-center justify-between">
                  <div>
                    <span className="text-[10px] text-amber-700 font-black uppercase tracking-wider block">
                      Total Parcels in Transit
                    </span>
                    <span className="text-2xl font-black text-amber-950 mt-0.5 block">
                      {orders
                        .filter((o) => o.status !== 'delivered' && o.assignedRiderId)
                        .reduce((sum, o) => sum + o.items.reduce((a, i) => a + i.quantity, 0), 0)} Parcels
                    </span>
                  </div>
                  <div className="w-10 h-10 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center">
                    <Package className="w-5 h-5" />
                  </div>
                </div>

                <div className="p-4 rounded-2xl bg-blue-50 border border-blue-200 flex items-center justify-between">
                  <div>
                    <span className="text-[10px] text-blue-700 font-black uppercase tracking-wider block">
                      Max Guaranteed SLA
                    </span>
                    <span className="text-2xl font-black text-blue-950 mt-0.5 block">
                      Under {storeSettings.maxDeliveryHours} Hours
                    </span>
                  </div>
                  <div className="w-10 h-10 rounded-xl bg-blue-600 text-white flex items-center justify-center">
                    <Clock className="w-5 h-5" />
                  </div>
                </div>
              </div>

              {/* Delivery Boys List with Parcel Carriage Breakdown */}
              <div className="space-y-4">
                <h4 className="text-xs font-black uppercase tracking-wider text-gray-600">
                  Rider-by-Rider Parcel Carriage Breakdown
                </h4>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {allUsers
                    .filter((u) => u.role === 'delivery')
                    .map((rider) => {
                      const metrics = getRiderParcels(rider.id);
                      return (
                        <div key={rider.id} className="p-4 rounded-2xl border border-gray-200 bg-white shadow-2xs hover:border-emerald-300 transition-all">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3">
                              <div className="w-11 h-11 rounded-2xl bg-emerald-600 text-white flex items-center justify-center font-bold text-base shadow-xs shrink-0">
                                <Bike className="w-6 h-6" />
                              </div>
                              <div>
                                <span className="text-sm font-black text-gray-900 block">{rider.name}</span>
                                <span className="text-xs text-gray-500 block">+91 {rider.phone}</span>
                              </div>
                            </div>

                            {/* Prominent Parcel Count Badge */}
                            <div className="text-right">
                              <span className="text-[10px] font-bold text-gray-500 uppercase block">Carrying Now</span>
                              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-xl bg-emerald-50 border border-emerald-300 text-emerald-900 font-black text-xs shadow-2xs">
                                <Package className="w-3.5 h-3.5 text-emerald-600" />
                                <strong>{metrics.totalParcelsCarried}</strong> parcels ({metrics.activeOrdersCount} orders)
                              </span>
                            </div>
                          </div>

                          {/* Order Details Preview */}
                          <div className="mt-3 pt-3 border-t border-gray-100">
                            <span className="text-[10px] font-bold uppercase text-gray-400 block mb-1">
                              Current Parcel Dispatch List:
                            </span>

                            {metrics.activeOrders.length > 0 ? (
                              <div className="space-y-1.5">
                                {metrics.activeOrders.map((ord) => (
                                  <div key={ord.id} className="p-2 rounded-xl bg-gray-50 text-xs flex items-center justify-between">
                                    <div className="flex items-center gap-2">
                                      <span className="font-bold text-gray-900">{ord.orderNumber}</span>
                                      <span className="text-[11px] text-gray-600">
                                        ({ord.items.reduce((s, i) => s + i.quantity, 0)} items)
                                      </span>
                                    </div>
                                    <div className="flex items-center gap-2">
                                      <span className="text-[10px] font-bold uppercase px-2 py-0.5 rounded-full bg-amber-100 text-amber-800">
                                        {ord.status.replace('_', ' ')}
                                      </span>
                                      <span className="text-[11px] font-black text-emerald-700">₹{ord.total}</span>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            ) : (
                              <div className="p-2.5 rounded-xl bg-gray-50 text-center text-xs text-gray-500">
                                All parcels delivered. Ready at dark store for next batch dispatch.
                              </div>
                            )}
                          </div>
                        </div>
                      );
                    })}
                </div>
              </div>

              {/* All Orders Queue */}
              <div className="bg-white rounded-2xl border border-gray-200 overflow-hidden shadow-2xs">
                <div className="p-3.5 bg-gray-50 border-b border-gray-200 text-xs font-black text-gray-900 uppercase">
                  All Pipeline Orders ({orders.length})
                </div>

                <div className="divide-y divide-gray-100">
                  {orders.map((order) => (
                    <div key={order.id} className="p-3.5 flex items-center justify-between gap-3 text-xs">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="font-black text-gray-900">{order.orderNumber}</span>
                          <span className="bg-amber-100 text-amber-800 text-[10px] font-bold px-2 py-0.5 rounded-full">
                            Under 24h SLA
                          </span>
                          {order.assignedRiderName && (
                            <span className="bg-emerald-50 text-emerald-800 border border-emerald-200 text-[10px] font-bold px-2 py-0.5 rounded-md flex items-center gap-1">
                              <Bike className="w-3 h-3 text-emerald-600" />
                              Rider: {order.assignedRiderName}
                            </span>
                          )}
                        </div>
                        <span className="text-[11px] text-gray-500 block mt-0.5">
                          {order.items.length} items ({order.items.reduce((s, i) => s + i.quantity, 0)} total parcels) · Total: ₹{order.total} · Destination: {order.address.title}
                        </span>
                      </div>

                      <div className="flex items-center gap-2">
                        <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-xl border border-emerald-200">
                          {order.status.replace('_', ' ').toUpperCase()}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* TAB 3: SHOP LOCATION & DELIVERY RADIUS (KM) */}
          {activeTab === 'delivery_zone' && (
            <div className="space-y-6">
              {settingsSavedMsg && (
                <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-2xl flex items-center gap-2 text-xs font-bold text-emerald-800 animate-in fade-in">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  <span>{settingsSavedMsg}</span>
                </div>
              )}

              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                {/* Configuration Column */}
                <div className="lg:col-span-7 space-y-4">
                  <div className="bg-white p-5 rounded-2xl border border-gray-200 shadow-2xs space-y-4">
                    <h3 className="text-sm font-black text-gray-900 flex items-center gap-2">
                      <MapPin className="w-4 h-4 text-emerald-600" />
                      Shop Coordinates & Hub Address
                    </h3>

                    <div>
                      <label className="text-xs font-bold text-gray-700 block mb-1">
                        Store Name
                      </label>
                      <input
                        type="text"
                        value={localSettings.storeName}
                        onChange={(e) => setLocalSettings({ ...localSettings, storeName: e.target.value })}
                        className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs font-bold text-gray-900 focus:bg-white focus:border-emerald-500 outline-none"
                      />
                    </div>

                    <div>
                      <label className="text-xs font-bold text-gray-700 block mb-1">
                        Physical Store Address
                      </label>
                      <textarea
                        rows={2}
                        value={localSettings.address}
                        onChange={(e) => setLocalSettings({ ...localSettings, address: e.target.value })}
                        className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs font-medium text-gray-900 focus:bg-white focus:border-emerald-500 outline-none"
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="text-xs font-bold text-gray-700 block mb-1">
                          Latitude (°N)
                        </label>
                        <input
                          type="number"
                          step="0.000001"
                          value={localSettings.latitude}
                          onChange={(e) => setLocalSettings({ ...localSettings, latitude: parseFloat(e.target.value) || 0 })}
                          className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs font-medium text-gray-900 focus:bg-white focus:border-emerald-500 outline-none font-mono"
                        />
                      </div>
                      <div>
                        <label className="text-xs font-bold text-gray-700 block mb-1">
                          Longitude (°E)
                        </label>
                        <input
                          type="number"
                          step="0.000001"
                          value={localSettings.longitude}
                          onChange={(e) => setLocalSettings({ ...localSettings, longitude: parseFloat(e.target.value) || 0 })}
                          className="w-full px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs font-medium text-gray-900 focus:bg-white focus:border-emerald-500 outline-none font-mono"
                        />
                      </div>
                    </div>

                    {/* Delivery Radius Slider */}
                    <div className="pt-2 border-t border-gray-100">
                      <div className="flex items-center justify-between mb-2">
                        <label className="text-xs font-black text-gray-900 flex items-center gap-1.5">
                          <Radio className="w-4 h-4 text-emerald-600" />
                          Delivery Service Radius:
                        </label>
                        <span className="text-sm font-black text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-lg border border-emerald-200">
                          {localSettings.serviceRadiusKm} km
                        </span>
                      </div>
                      <input
                        type="range"
                        min={1}
                        max={35}
                        step={1}
                        value={localSettings.serviceRadiusKm}
                        onChange={(e) => setLocalSettings({ ...localSettings, serviceRadiusKm: parseInt(e.target.value) || 1 })}
                        className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-emerald-600"
                      />
                      <div className="flex justify-between text-[10px] text-gray-500 font-semibold mt-1">
                        <span>1 km (Hyperlocal)</span>
                        <span>15 km (Standard Hub)</span>
                        <span>35 km (Max City Coverage)</span>
                      </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="pt-3 border-t border-gray-100 flex items-center justify-between gap-3">
                      {onOpenMapPicker && (
                        <button
                          type="button"
                          onClick={onOpenMapPicker}
                          className="px-3.5 py-2 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-colors cursor-pointer"
                        >
                          <Navigation className="w-3.5 h-3.5 text-blue-600" />
                          <span>Pick Pin on Live Map</span>
                        </button>
                      )}

                      <button
                        type="button"
                        onClick={handleSaveSettings}
                        className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-black flex items-center gap-1.5 shadow-sm transition-colors cursor-pointer ml-auto"
                      >
                        <Save className="w-3.5 h-3.5" />
                        <span>Save Store Settings</span>
                      </button>
                    </div>
                  </div>
                </div>

                {/* Visual Coverage Preview Column */}
                <div className="lg:col-span-5 bg-gradient-to-br from-slate-900 to-slate-800 text-white p-5 rounded-2xl border border-slate-700 flex flex-col justify-between">
                  <div>
                    <span className="text-[10px] font-black tracking-wider uppercase text-amber-400 block mb-1">
                      Live Delivery Zone Coverage
                    </span>
                    <h4 className="text-base font-bold text-white">
                      Radial Radius: {localSettings.serviceRadiusKm} km
                    </h4>
                    <p className="text-xs text-slate-300 mt-1">
                      Origin: {localSettings.latitude.toFixed(4)}°N, {localSettings.longitude.toFixed(4)}°E
                    </p>

                    {/* Schematic Radar Circle */}
                    <div className="my-6 relative w-48 h-48 mx-auto flex items-center justify-center">
                      <div className="absolute inset-0 rounded-full border border-dashed border-emerald-400/40 animate-spin" style={{ animationDuration: '20s' }} />
                      <div className="w-36 h-36 rounded-full bg-emerald-500/10 border border-emerald-400/60 flex items-center justify-center">
                        <div className="w-20 h-20 rounded-full bg-emerald-500/20 border-2 border-emerald-400 flex items-center justify-center text-center">
                          <div className="w-6 h-6 rounded-full bg-yellow-400 text-gray-950 flex items-center justify-center font-black text-xs shadow-md">
                            🏪
                          </div>
                        </div>
                      </div>
                      <span className="absolute bottom-1 bg-slate-800 text-emerald-400 text-[10px] font-bold px-2 py-0.5 rounded-full border border-emerald-400/40">
                        {localSettings.serviceRadiusKm} km Radius
                      </span>
                    </div>

                    <div className="space-y-2 text-xs">
                      <div className="flex items-center justify-between p-2 rounded-lg bg-slate-800/80 border border-slate-700">
                        <span className="text-slate-300">Hub:</span>
                        <span className="font-bold text-white truncate max-w-[170px]">{localSettings.storeName}</span>
                      </div>
                      <div className="flex items-center justify-between p-2 rounded-lg bg-slate-800/80 border border-slate-700">
                        <span className="text-slate-300">Max Delivery Time:</span>
                        <span className="font-bold text-yellow-300">Under 24 Hours</span>
                      </div>
                      <div className="flex items-center justify-between p-2 rounded-lg bg-slate-800/80 border border-slate-700">
                        <span className="text-slate-300">Estimated Transit:</span>
                        <span className="font-bold text-emerald-400">8 to 45 mins</span>
                      </div>
                    </div>
                  </div>

                  <div className="mt-4 pt-3 border-t border-slate-700 text-[11px] text-slate-400">
                    Customers beyond {localSettings.serviceRadiusKm} km will be notified that they are outside the current delivery boundary.
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default OwnerManagementModal;
