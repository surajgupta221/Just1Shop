/**
 * Just1Shop - Cron Job Scheduler & Webhook Endpoint
 * 
 * Runs the catalog sync pipeline automatically:
 * 1. Scheduled Cron: Every night at 02:00 AM (or configurable interval)
 * 2. Webhook: POST /api/webhooks/catalog-sync (with secure secret verification)
 */

import http from 'http';
import { runCatalogSyncPipeline } from './catalogSyncPipeline';

const PORT = process.env.SYNC_SERVICE_PORT ? parseInt(process.env.SYNC_SERVICE_PORT, 10) : 4005;
const WEBHOOK_SECRET = process.env.CATALOG_WEBHOOK_SECRET || 'just1shop-super-secure-key-2026';

let isSyncInProgress = false;
let lastSyncTimestamp: string | null = null;
let lastSyncResult: any = null;

async function executeSync(source: 'CRON' | 'WEBHOOK') {
  if (isSyncInProgress) {
    console.log(`⚠️ Sync already running. Skipping triggered ${source} request.`);
    return { status: 'already_running', timestamp: new Date().toISOString() };
  }

  try {
    isSyncInProgress = true;
    console.log(`\n========================================`);
    console.log(`⏰ Triggering Just1Shop Catalog Sync via ${source} at ${new Date().toISOString()}`);
    console.log(`========================================`);
    
    const result = await runCatalogSyncPipeline();
    lastSyncTimestamp = new Date().toISOString();
    lastSyncResult = {
      status: 'success',
      source,
      syncedCount: result.totalProcessed,
      timestamp: lastSyncTimestamp,
    };
    return lastSyncResult;
  } catch (error) {
    lastSyncResult = {
      status: 'failed',
      source,
      error: (error as Error).message,
      timestamp: new Date().toISOString(),
    };
    console.error('❌ Sync failed:', error);
    return lastSyncResult;
  } finally {
    isSyncInProgress = false;
  }
}

// 1. Webhook Server Setup
const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || '/', `http://${req.headers.host}`);

  // Health check
  if (req.method === 'GET' && url.pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ 
      service: 'Just1Shop Catalog Sync Service', 
      status: 'healthy',
      isSyncInProgress,
      lastSyncTimestamp,
      lastSyncResult
    }));
  }

  // Webhook trigger endpoint: POST /api/webhooks/catalog-sync
  if (req.method === 'POST' && url.pathname === '/api/webhooks/catalog-sync') {
    const authHeader = req.headers['x-webhook-secret'] || req.headers['authorization'];
    if (authHeader !== WEBHOOK_SECRET && authHeader !== `Bearer ${WEBHOOK_SECRET}`) {
      res.writeHead(401, { 'Content-Type': 'application/json' });
      return res.end(JSON.stringify({ error: 'Unauthorized: Invalid webhook secret' }));
    }

    const result = await executeSync('WEBHOOK');
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify(result));
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Endpoint not found' }));
});

// 2. Automated Periodic Cron Simulation (every 24 hours or on demand)
const CRON_INTERVAL_HOURS = 24;
setInterval(() => {
  console.log('⏰ Automated Cron Timer Fired...');
  executeSync('CRON');
}, CRON_INTERVAL_HOURS * 60 * 60 * 1000);

if (process.argv[1] && process.argv[1].endsWith('cronJobRunner.ts')) {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`⚡ Just1Shop Catalog Sync Server listening on port ${PORT}`);
    console.log(`📡 Webhook URL: http://localhost:${PORT}/api/webhooks/catalog-sync`);
  });
}
