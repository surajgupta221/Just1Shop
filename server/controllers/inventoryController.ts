/**
 * Just1Shop - Admin Inventory & Pricing Controller
 * File: /server/controllers/inventoryController.ts
 * 
 * Provides secure backend business logic for Admin inventory pricing, verification rules,
 * net profit margin calculations, and storefront publishing toggles.
 */

export interface PricingUpdateRequestBody {
  product_id: string;
  purchase_price: number | string;
  selling_price: number | string;
  is_active?: boolean;
}

export interface VerificationResult {
  isValid: boolean;
  error?: string;
  code?: string;
  data?: {
    purchasePrice: number;
    sellingPrice: number;
    netProfitMarginAmount: number;
    netProfitMarginPercent: number;
  };
}

/**
 * Verification Rule Engine
 * 1. Checks valid positive numbers
 * 2. Enforces: selling_price >= purchase_price
 * 3. Computes net profit margin %: ((selling - purchase) / selling) * 100
 */
export function verifyAndCalculatePricing(
  rawPurchasePrice: number | string,
  rawSellingPrice: number | string
): VerificationResult {
  const purchasePrice = Number(rawPurchasePrice);
  const sellingPrice = Number(rawSellingPrice);

  // 1. Validate numeric input
  if (isNaN(purchasePrice) || purchasePrice < 0) {
    return {
      isValid: false,
      code: 'INVALID_PURCHASE_PRICE',
      error: 'Purchase price must be a valid non-negative number.',
    };
  }

  if (isNaN(sellingPrice) || sellingPrice < 0) {
    return {
      isValid: false,
      code: 'INVALID_SELLING_PRICE',
      error: 'Selling price must be a valid non-negative number.',
    };
  }

  // 2. CRUCIAL VERIFICATION RULE: selling_price must always be >= purchase_price
  if (sellingPrice < purchasePrice) {
    return {
      isValid: false,
      code: 'SELLING_PRICE_LESS_THAN_PURCHASE_PRICE',
      error: `Verification rule violation: Selling price (₹${sellingPrice}) cannot be lower than Purchase price (₹${purchasePrice}). A negative margin would incur losses.`,
    };
  }

  // 3. Calculate Net Profit Margin % and Margin Amount automatically
  const netProfitMarginAmount = Number((sellingPrice - purchasePrice).toFixed(2));
  const netProfitMarginPercent = sellingPrice > 0
    ? Number((((sellingPrice - purchasePrice) / sellingPrice) * 100).toFixed(2))
    : 0;

  return {
    isValid: true,
    data: {
      purchasePrice,
      sellingPrice,
      netProfitMarginAmount,
      netProfitMarginPercent,
    },
  };
}

/**
 * Controller Handler: POST /api/admin/inventory/update-pricing
 * 
 * Works with Express (req, res) or standard Web Request/Response.
 */
export async function updatePricingHandler(body: PricingUpdateRequestBody) {
  const { product_id, purchase_price, selling_price, is_active } = body;

  if (!product_id || typeof product_id !== 'string') {
    return {
      status: 400,
      body: {
        success: false,
        error: 'MISSING_PRODUCT_ID',
        message: 'Field product_id is required.',
      },
    };
  }

  // Execute verification rules
  const verification = verifyAndCalculatePricing(purchase_price, selling_price);
  if (!verification.isValid || !verification.data) {
    return {
      status: 400,
      body: {
        success: false,
        error: verification.code,
        message: verification.error,
      },
    };
  }

  const { purchasePrice, sellingPrice, netProfitMarginAmount, netProfitMarginPercent } = verification.data;

  // Determine storefront activation status:
  // If is_active is explicitly passed, use it (provided prices are > 0).
  // Otherwise, default active if both prices > 0, or pending if 0.
  let activeStatus: boolean = is_active !== undefined ? Boolean(is_active) : (sellingPrice > 0 && purchasePrice > 0);

  // Safeguard: Cannot be active if prices are 0
  if (activeStatus && (sellingPrice <= 0 || purchasePrice <= 0)) {
    return {
      status: 400,
      body: {
        success: false,
        error: 'CANNOT_PUBLISH_ZERO_PRICE',
        message: 'Cannot publish to storefront with zero or unset prices. Please set valid purchase and selling amounts.',
      },
    };
  }

  const updatedRecord = {
    product_id,
    purchase_price: purchasePrice,
    selling_price: sellingPrice,
    profit_margin_amount: netProfitMarginAmount,
    profit_margin_percent: netProfitMarginPercent,
    is_active: activeStatus,
    status: activeStatus ? 'active' : 'pending_admin_pricing',
    updated_at: new Date().toISOString(),
  };

  return {
    status: 200,
    body: {
      success: true,
      message: `Pricing verified and updated successfully. Net profit margin: ${netProfitMarginPercent}%. Storefront: ${activeStatus ? 'LIVE' : 'HIDDEN'}.`,
      data: updatedRecord,
    },
  };
}
