import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    return {
      server: {
        port: 3000,
        host: '0.0.0.0',
      },
      plugins: [
        react(),
        {
          name: 'admin-inventory-api',
          configureServer(server) {
            server.middlewares.use((req, res, next) => {
              if (req.url === '/api/admin/inventory/update-pricing' && req.method === 'POST') {
                let body = '';
                req.on('data', (chunk) => {
                  body += chunk;
                });
                req.on('end', () => {
                  try {
                    const parsed = JSON.parse(body || '{}');
                    const { product_id, purchase_price, selling_price, is_active } = parsed;

                    if (!product_id || typeof product_id !== 'string') {
                      res.statusCode = 400;
                      res.setHeader('Content-Type', 'application/json');
                      return res.end(JSON.stringify({
                        success: false,
                        error: 'MISSING_PRODUCT_ID',
                        message: 'Field product_id is required.',
                      }));
                    }

                    const purchasePrice = Number(purchase_price);
                    const sellingPrice = Number(selling_price);

                    if (isNaN(purchasePrice) || purchasePrice < 0) {
                      res.statusCode = 400;
                      res.setHeader('Content-Type', 'application/json');
                      return res.end(JSON.stringify({
                        success: false,
                        error: 'INVALID_PURCHASE_PRICE',
                        message: 'Purchase price must be a valid non-negative number.',
                      }));
                    }

                    if (isNaN(sellingPrice) || sellingPrice < 0) {
                      res.statusCode = 400;
                      res.setHeader('Content-Type', 'application/json');
                      return res.end(JSON.stringify({
                        success: false,
                        error: 'INVALID_SELLING_PRICE',
                        message: 'Selling price must be a valid non-negative number.',
                      }));
                    }

                    // CRUCIAL VERIFICATION RULE: selling_price must be >= purchase_price
                    if (sellingPrice < purchasePrice) {
                      res.statusCode = 400;
                      res.setHeader('Content-Type', 'application/json');
                      return res.end(JSON.stringify({
                        success: false,
                        error: 'SELLING_PRICE_LESS_THAN_PURCHASE_PRICE',
                        message: `Verification rule violation: Selling price (₹${sellingPrice}) cannot be lower than Purchase price (₹${purchasePrice}). A negative margin would incur losses.`,
                      }));
                    }

                    // Calculate Net Profit Margin Percentage automatically
                    const netProfitMarginAmount = Number((sellingPrice - purchasePrice).toFixed(2));
                    const netProfitMarginPercent = sellingPrice > 0
                      ? Number((((sellingPrice - purchasePrice) / sellingPrice) * 100).toFixed(2))
                      : 0;

                    let activeStatus = is_active !== undefined ? Boolean(is_active) : (sellingPrice > 0 && purchasePrice > 0);

                    // Safeguard: Cannot publish with zero pricing
                    if (activeStatus && (sellingPrice <= 0 || purchasePrice <= 0)) {
                      res.statusCode = 400;
                      res.setHeader('Content-Type', 'application/json');
                      return res.end(JSON.stringify({
                        success: false,
                        error: 'CANNOT_PUBLISH_ZERO_PRICE',
                        message: 'Cannot publish to storefront with zero or unset prices. Please set valid purchase and selling amounts.',
                      }));
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

                    res.statusCode = 200;
                    res.setHeader('Content-Type', 'application/json');
                    return res.end(JSON.stringify({
                      success: true,
                      message: `Pricing verified & saved. Net profit margin: ${netProfitMarginPercent}%. Storefront status: ${activeStatus ? 'LIVE' : 'HIDDEN'}.`,
                      data: updatedRecord,
                    }));
                  } catch (e) {
                    res.statusCode = 400;
                    res.setHeader('Content-Type', 'application/json');
                    return res.end(JSON.stringify({
                      success: false,
                      error: 'BAD_REQUEST',
                      message: 'Invalid JSON body: ' + (e as Error).message,
                    }));
                  }
                });
                return;
              }
              next();
            });
          }
        }
      ],
      define: {
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY)
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, '.'),
        }
      }
    };
});
