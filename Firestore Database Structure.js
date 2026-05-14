// Collections Structure

// users
users: {
  userId: {
    name: string,
    phone: string,
    email: string,
    role: 'customer' | 'owner' | 'delivery',
    addresses: [
      {
        id: string,
        name: string,
        address: string,
        landmark: string,
        pincode: string,
        isDefault: boolean
      }
    ],
    createdAt: timestamp,
    updatedAt: timestamp
  }
}

// categories
categories: {
  categoryId: {
    name: string,
    image: string,
    isActive: boolean,
    sortOrder: number,
    createdAt: timestamp
  }
}

// products
products: {
  productId: {
    name: string,
    description: string,
    price: number,
    discountPrice: number,
    images: [string],
    categoryId: string,
    unit: string,
    stock: number,
    isActive: boolean,
    tags: [string],
    createdAt: timestamp,
    updatedAt: timestamp
  }
}

// orders
orders: {
  orderId: {
    userId: string,
    items: [
      {
        productId: string,
        name: string,
        price: number,
        quantity: number,
        image: string
      }
    ],
    totalAmount: number,
    discountAmount: number,
    deliveryCharge: number,
    finalAmount: number,
    paymentMethod: 'online' | 'cod',
    paymentStatus: 'pending' | 'paid' | 'failed',
    paymentId: string,
    deliveryAddress: object,
    status: 'placed' | 'packed' | 'out_for_delivery' | 'delivered' | 'cancelled',
    deliveryBoyId: string,
    couponCode: string,
    orderDate: timestamp,
    deliveryDate: timestamp,
    statusHistory: [
      {
        status: string,
        timestamp: timestamp,
        updatedBy: string
      }
    ]
  }
}

// banners
banners: {
  bannerId: {
    title: string,
    image: string,
    link: string,
    type: 'product' | 'category' | 'external',
    isActive: boolean,
    sortOrder: number,
    createdAt: timestamp
  }
}

// coupons
coupons: {
  couponId: {
    code: string,
    type: 'percentage' | 'fixed',
    value: number,
    minOrderAmount: number,
    maxDiscountAmount: number,
    isActive: boolean,
    validFrom: timestamp,
    validTo: timestamp,
    usageLimit: number,
    usedCount: number
  }
}
