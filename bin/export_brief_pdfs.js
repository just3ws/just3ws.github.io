#!/usr/bin/env node

/**
 * bin/export_brief_pdfs.js
 * Generates print-optimized 1-page PDF documents for all executive pitch briefs in exports/briefs/
 */

const fs = require('fs');
const path = require('path');
let chromium;
try {
  ({ chromium } = require('playwright'));
} catch (err) {
  console.warn('⚠️ [Brief PDF Exporter] Playwright module not available in this environment. Skipping PDF re-rendering (pre-built PDFs in exports/ will be preserved).');
  process.exit(0);
}
const http = require('http');

const ROOT_DIR = path.resolve(__dirname, '..');
const BRIEFS_DIR = path.join(ROOT_DIR, 'exports', 'briefs');
const PDF_OUTPUT_DIR = path.join(BRIEFS_DIR, 'pdfs');
const SITE_DIR = path.join(ROOT_DIR, '_site');

if (!fs.existsSync(PDF_OUTPUT_DIR)) {
  fs.mkdirSync(PDF_OUTPUT_DIR, { recursive: true });
}

// Find all brief directories
const briefDirs = fs.readdirSync(BRIEFS_DIR, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory() && dirent.name !== 'pdfs')
  .map(dirent => dirent.name);

if (briefDirs.length === 0) {
  console.log('No executive briefs found in exports/briefs/');
  process.exit(0);
}

// Start temporary static HTTP server on random available port
const server = http.createServer((req, res) => {
  let relativeUrl = decodeURIComponent(req.url.split('?')[0]);
  if (relativeUrl.endsWith('/')) relativeUrl += 'index.html';

  let filePath = path.join(ROOT_DIR, relativeUrl);
  if (!fs.existsSync(filePath)) {
    filePath = path.join(SITE_DIR, relativeUrl);
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
    const ext = path.extname(filePath);
    const contentType = ext === '.html' ? 'text/html' : ext === '.css' ? 'text/css' : ext === '.svg' ? 'image/svg+xml' : 'text/plain';
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
});

server.listen(0, async () => {
  const port = server.address().port;
  console.log(`🚀 [Brief PDF Exporter] Generating PDFs across ${briefDirs.length} brief pages on port ${port}...`);

  let browser;
  try {
    browser = await chromium.launch({ channel: 'chrome', headless: true });
  } catch (e) {
    browser = await chromium.launch({ headless: true });
  }
  const page = await browser.newPage();

  let generatedCount = 0;

  for (const slug of briefDirs) {
    const url = `http://localhost:${port}/exports/briefs/${slug}/`;
    const pdfPath = path.join(PDF_OUTPUT_DIR, `${slug}-executive-brief-mike-hall.pdf`);

    try {
      await page.goto(url, { waitUntil: 'load', timeout: 5000 });

      // Emulate print media
      await page.emulateMedia({ media: 'print' });

      await page.pdf({
        path: pdfPath,
        format: 'Letter',
        printBackground: true,
        margin: { top: '0.4in', right: '0.4in', bottom: '0.4in', left: '0.4in' },
        scale: 0.95
      });

      console.log(`  ✓ Generated: ${path.relative(ROOT_DIR, pdfPath)}`);
      generatedCount++;
    } catch (err) {
      console.error(`  ❌ Failed to generate PDF for ${slug}:`, err.message);
    }
  }

  await browser.close();
  server.close();
  console.log(`✅ [Brief PDF Exporter] Successfully generated ${generatedCount} executive brief PDFs.`);
});
