
import React from 'react';
import type { CartItem, Product } from '../types';
import { XIcon, PlusIcon, MinusIcon, TrashIcon } from './icons';

interface CartProps {
  isOpen: boolean;
  onClose: () => void;
  cartItems: CartItem[];
  onUpdateQuantity: (product: Product, quantity: number) => void;
  onRemoveItem: (product: Product) => void;
}

const Cart: React.FC<CartProps> = ({ isOpen, onClose, cartItems, onUpdateQuantity, onRemoveItem }) => {
  const subtotal = cartItems.reduce((sum, item) => sum + item.product.price * item.quantity, 0);

  return (
    <>
      <div 
        className={`fixed inset-0 bg-black bg-opacity-50 z-40 transition-opacity ${isOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'}`}
        onClick={onClose}
      ></div>
      <div className={`fixed top-0 right-0 h-full w-full max-w-md bg-white shadow-2xl z-50 transform transition-transform ${isOpen ? 'translate-x-0' : 'translate-x-full'}`}>
        <div className="flex flex-col h-full">
          <div className="flex justify-between items-center p-4 border-b">
            <h2 className="text-xl font-bold text-gray-800">Your Cart</h2>
            <button onClick={onClose} className="p-2 rounded-full text-gray-500 hover:bg-gray-100 transition">
              <XIcon className="h-6 w-6" />
            </button>
          </div>
          
          {cartItems.length === 0 ? (
            <div className="flex-grow flex flex-col items-center justify-center text-center p-4">
              <svg className="w-24 h-24 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
              <p className="mt-4 text-lg font-semibold text-gray-700">Your cart is empty</p>
              <p className="text-gray-500">Add some groceries to get started!</p>
            </div>
          ) : (
            <div className="flex-grow overflow-y-auto p-4 space-y-4">
              {cartItems.map(item => (
                <div key={item.product.id} className="flex items-start space-x-4">
                  <img src={item.product.image} alt={item.product.name} className="w-20 h-20 rounded-lg object-cover flex-shrink-0" />
                  <div className="flex-grow">
                    <h3 className="font-semibold text-gray-800">{item.product.name}</h3>
                    <p className="text-sm text-gray-500">${item.product.price.toFixed(2)}</p>
                    <div className="flex items-center mt-2">
                      <button onClick={() => onUpdateQuantity(item.product, item.quantity - 1)} className="p-1 border rounded-full text-gray-600 hover:bg-gray-100 disabled:opacity-50" disabled={item.quantity <= 1}>
                        <MinusIcon className="h-4 w-4" />
                      </button>
                      <span className="px-3 text-lg font-medium">{item.quantity}</span>
                      <button onClick={() => onUpdateQuantity(item.product, item.quantity + 1)} className="p-1 border rounded-full text-gray-600 hover:bg-gray-100">
                        <PlusIcon className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                  <div className="flex flex-col items-end">
                    <p className="font-bold text-gray-900">${(item.product.price * item.quantity).toFixed(2)}</p>
                    <button onClick={() => onRemoveItem(item.product)} className="mt-2 p-1 text-red-500 hover:text-red-700">
                      <TrashIcon className="w-5 h-5" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          {cartItems.length > 0 && (
            <div className="p-4 border-t bg-gray-50">
              <div className="flex justify-between items-center mb-4">
                <span className="text-lg font-medium text-gray-600">Subtotal</span>
                <span className="text-xl font-bold text-gray-900">${subtotal.toFixed(2)}</span>
              </div>
              <button className="w-full bg-green-600 text-white font-bold py-3 rounded-lg shadow-md hover:bg-green-700 transition-colors">
                Proceed to Checkout
              </button>
            </div>
          )}
        </div>
      </div>
    </>
  );
};

export default Cart;
