#!/usr/bin/env node

/**
 * bin/export_brief_pdfs.js
 * Generates print-optimized 1-page PDF documents for all executive pitch briefs in exports/briefs/
 */

const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
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

// Start temporary static HTTP server on _site directory
const PORT = 4188;
const server = http.createServer((req, res) => {
  let filePath = path.join(SITE_DIR, req.url);
  if (filePath.endsWith('/')) filePath += 'index.html';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
    const ext = path.extname(filePath);
    const contentType = ext === '.html' ? 'text/html' : ext === '.css' ? 'text/css' : 'text/plain';
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
});

server.listen(PORT, async () => {
  console.log(`🚀 [Brief PDF Exporter] Generating PDFs across ${briefDirs.length} brief pages...`);

  let browser;
  try {
    browser = await chromium.launch({ channel: 'chrome', headless: true });
  } catch (e) {
    browser = await chromium.launch({ headless: true });
  }
  const page = await browser.newPage();

  let generatedCount = 0;

  for (const slug of briefDirs) {
    const url = `http://localhost:${PORT}/exports/briefs/${slug}/`;
    const pdfPath = path.join(PDF_OUTPUT_DIR, `${slug}-executive-brief-mike-hall.pdf`);

    try {
      await page.goto(url, { waitUntil: 'networkidle' });

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
