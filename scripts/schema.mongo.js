/**
 * Just1Shop: Master Catalog MongoDB (Mongoose) Schema Definition
 * Enforces schema validation, indexing, and the strict hidden pricing rule.
 */

import mongoose from 'mongoose';

const MasterCatalogSchema = new mongoose.Schema(
  {
    barcode: {
      type: String,
      required: [true, 'Barcode is required for fast POS & scanner cataloging'],
      unique: true,
      trim: true,
      index: true,
    },
    brand_name: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    product_title: {
      type: String,
      required: true,
      trim: true,
      index: 'text',
    },
    weight_metric: {
      type: String,
      required: true,
      trim: true,
    },
    category: {
      type: String,
      required: true,
      index: true,
    },
    subcategory: {
      type: String,
      default: '',
    },
    image_url: {
      type: String,
      default: '',
    },
    image_source: {
      type: String,
      enum: ['unsplash_api', 'google_custom_search', 'retail_media_cdn', 'placeholder'],
      default: 'unsplash_api',
    },
    // CRUCIAL RULE:
    // Default to null. Hidden from frontend customers until an Admin sets prices.
    purchase_price: {
      type: Number,
      default: null,
    },
    selling_price: {
      type: Number,
      default: null,
    },
    mrp: {
      type: Number,
      default: null,
    },
    status: {
      type: String,
      enum: ['pending_admin_pricing', 'active', 'archived', 'out_of_stock'],
      default: 'pending_admin_pricing',
      index: true,
    },
    source_provider: {
      type: String,
      default: 'local_market_cloud_api',
    },
    raw_payload: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' },
  }
);

// Pre-save hook enforcing the hidden status unless prices exist
MasterCatalogSchema.pre('save', function (next) {
  if (!this.selling_price || this.selling_price <= 0 || !this.purchase_price || this.purchase_price <= 0) {
    this.status = 'pending_admin_pricing';
  } else if (this.status === 'pending_admin_pricing') {
    this.status = 'active';
  }
  next();
});

// Compound Index for Customer Storefront queries
MasterCatalogSchema.index({ status: 1, category: 1, selling_price: 1 });

export const MasterCatalog = mongoose.models.MasterCatalog || mongoose.model('MasterCatalog', MasterCatalogSchema);
