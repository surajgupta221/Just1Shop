-- ==============================================================================
-- Just1Shop: Master Catalog & Quick-Commerce PostgreSQL Database Schema
-- Architecture: High-throughput ingestion, zero-downtime indexing, and strict pricing safeguards
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For fuzzy search on brand and title

-- 1. Master Catalog Table (Ingestion & Scraping Pipeline Target)
CREATE TABLE IF NOT EXISTS master_catalog (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    barcode VARCHAR(64) UNIQUE NOT NULL,
    brand_name VARCHAR(128) NOT NULL,
    product_title VARCHAR(255) NOT NULL,
    weight_metric VARCHAR(64) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    image_url TEXT,
    image_source VARCHAR(64) DEFAULT 'unsplash_api',
    
    -- Crucial Rule: Defaults to NULL. If purchase_price or selling_price is NULL or 0,
    -- the product is strictly HIDDEN from the frontend customer storefront.
    purchase_price NUMERIC(10, 2) DEFAULT NULL,
    selling_price NUMERIC(10, 2) DEFAULT NULL,
    mrp NUMERIC(10, 2) DEFAULT NULL,
    
    status VARCHAR(32) DEFAULT 'pending_admin_pricing' CHECK (status IN ('pending_admin_pricing', 'active', 'archived', 'out_of_stock')),
    source_provider VARCHAR(128) NOT NULL DEFAULT 'local_market_cloud_api',
    raw_payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for lightning queries, barcode lookups, and auto-suggest
CREATE INDEX IF NOT EXISTS idx_master_catalog_barcode ON master_catalog(barcode);
CREATE INDEX IF NOT EXISTS idx_master_catalog_category ON master_catalog(category, subcategory);
CREATE INDEX IF NOT EXISTS idx_master_catalog_status ON master_catalog(status);
CREATE INDEX IF NOT EXISTS idx_master_catalog_pricing ON master_catalog(selling_price) WHERE selling_price > 0;
CREATE INDEX IF NOT EXISTS idx_master_catalog_search ON master_catalog USING gin (product_title gin_trgm_ops, brand_name gin_trgm_ops);

-- 2. Storefront Safe View (Exposes only priced & active items to end-users)
-- Ensures items with NULL or 0 purchase_price / selling_price NEVER leak to shoppers.
CREATE OR REPLACE VIEW customer_storefront_catalog AS
SELECT 
    id,
    barcode,
    brand_name,
    product_title,
    weight_metric,
    category,
    subcategory,
    image_url,
    selling_price,
    COALESCE(mrp, selling_price) AS mrp,
    ROUND(((COALESCE(mrp, selling_price) - selling_price) / NULLIF(COALESCE(mrp, selling_price), 0)) * 100) AS discount_percent,
    updated_at
FROM master_catalog
WHERE 
    status = 'active'
    AND selling_price IS NOT NULL 
    AND selling_price > 0
    AND purchase_price IS NOT NULL 
    AND purchase_price > 0;

-- 3. Trigger to Auto-Update 'updated_at' Timestamp
CREATE OR REPLACE FUNCTION update_catalog_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    
    -- Enforce auto-transition to active when valid pricing is supplied
    IF NEW.selling_price > 0 AND NEW.purchase_price > 0 AND NEW.status = 'pending_admin_pricing' THEN
        NEW.status = 'active';
    END IF;

    -- Enforce pending_admin_pricing if pricing is revoked
    IF (NEW.selling_price IS NULL OR NEW.selling_price = 0 OR NEW.purchase_price IS NULL OR NEW.purchase_price = 0) THEN
        NEW.status = 'pending_admin_pricing';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_catalog_timestamp ON master_catalog;
CREATE TRIGGER trg_update_catalog_timestamp
BEFORE UPDATE OR INSERT ON master_catalog
FOR EACH ROW
EXECUTE FUNCTION update_catalog_timestamp();
