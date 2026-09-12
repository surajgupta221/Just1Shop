/**
 * Just1Shop - Admin Inventory Router
 * File: /server/routes/adminRoutes.ts
 * 
 * Express Router exposing admin inventory management routes:
 * - POST /api/admin/inventory/update-pricing
 * - POST /api/admin/inventory/toggle-storefront
 */

import { updatePricingHandler, PricingUpdateRequestBody } from '../controllers/inventoryController';

export function createAdminInventoryRouter(expressInstance?: any) {
  // If express is passed or imported
  if (expressInstance && expressInstance.Router) {
    const router = expressInstance.Router();

    /**
     * POST /api/admin/inventory/update-pricing
     */
    router.post('/inventory/update-pricing', async (req: any, res: any) => {
      try {
        const result = await updatePricingHandler(req.body as PricingUpdateRequestBody);
        return res.status(result.status).json(result.body);
      } catch (err) {
        return res.status(500).json({
          success: false,
          error: 'INTERNAL_SERVER_ERROR',
          message: (err as Error).message,
        });
      }
    });

    /**
     * POST /api/admin/inventory/toggle-storefront
     */
    router.post('/inventory/toggle-storefront', async (req: any, res: any) => {
      try {
        const { product_id, is_active, purchase_price, selling_price } = req.body;
        const result = await updatePricingHandler({
          product_id,
          purchase_price: purchase_price ?? 0,
          selling_price: selling_price ?? 0,
          is_active: Boolean(is_active),
        });
        return res.status(result.status).json(result.body);
      } catch (err) {
        return res.status(500).json({
          success: false,
          error: 'INTERNAL_SERVER_ERROR',
          message: (err as Error).message,
        });
      }
    });

    return router;
  }

  return null;
}
