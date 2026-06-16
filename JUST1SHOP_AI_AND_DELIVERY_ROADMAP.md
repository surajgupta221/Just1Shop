# Just1Shop AI, Delivery Zones, and Admin Import

## Production Web ID

Primary public web domain:

- `https://www.just1shop.com`

Firebase Hosting is configured to serve `build/web` and rewrite all web routes to `index.html`, so direct links such as `/home`, `/ai-assistant`, and `/products` work after deployment.

## Python-First AI Features Added

- AI product draft from manual text: `/ai/product-draft`
- AI product extraction from bill text: `/ai/product-from-bill`
- AI product draft from uploaded photo and notes: `/ai/product-from-photo`
- Bulk product import from JSON: `/bulk-products`
- Bulk product import from CSV: `/bulk-products/csv`
- Admin UI: `/ai-products`

The current implementation is useful without a paid model API. It uses Python heuristics for category, unit, tag, price, and product normalization. A future model can be added inside `ai_catalog_tools.py` without changing the admin workflow.

## Delivery Targeting

- Delivery PIN-code collection: `delivery_zones`
- Backend management endpoints:
  - `GET /delivery-zones`
  - `POST /delivery-zones`
  - `DELETE /delivery-zones/{pincode}`
  - `GET /delivery/check/{pincode}`
- Admin UI: `/delivery-zones`
- Customer UI: delivery location sheet PIN-code checker

## Admin and Owner Product Intake

Admin/Owner can now add products through:

- Manual form
- AI manual draft
- Product photo plus notes
- Bill/invoice pasted text
- Bulk CSV upload

Sample CSV is available from the admin app at:

- `/sample-products.csv`
