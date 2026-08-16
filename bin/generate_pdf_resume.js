#!/usr/bin/env node

/**
 * bin/generate_pdf_resume.js
 * Generates an executive PDF resume package from the installed local site.
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const SITE_DIR = path.join(ROOT_DIR, '_site');
const EXPORTS_SRC_DIR = path.join(ROOT_DIR, 'exports');
const EXPORTS_DIST_DIR = path.join(SITE_DIR, 'exports');

async function generatePDF() {
  console.log('📄 Launching Google Chrome for PDF generation...');
  const launchOptions = { headless: true };
  if (fs.existsSync('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome')) {
    launchOptions.executablePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  }
  const browser = await chromium.launch(launchOptions);
  const context = await browser.newContext();
  const page = await context.newPage();

  // Target local URL or fallback to rendered _site file
  const localUrl = 'https://just3ws.localhost/';
  const fileUrl = `file://${path.join(SITE_DIR, 'index.html')}`;

  try {
    console.log(`🌐 Navigating to ${localUrl}...`);
    await page.goto(localUrl, { waitUntil: 'networkidle', timeout: 15000 });
  } catch (err) {
    console.warn(`⚠️ Local Nginx fallback to local _site file: ${err.message}`);
    await page.goto(fileUrl, { waitUntil: 'networkidle', timeout: 15000 });
  }

  // Ensure directories exist
  if (!fs.existsSync(EXPORTS_SRC_DIR)) {
    fs.mkdirSync(EXPORTS_SRC_DIR, { recursive: true });
  }
  if (!fs.existsSync(EXPORTS_DIST_DIR)) {
    fs.mkdirSync(EXPORTS_DIST_DIR, { recursive: true });
  }

  const pdfPathSrc = path.join(EXPORTS_SRC_DIR, 'resume.pdf');
  const pdfPathDist = path.join(EXPORTS_DIST_DIR, 'resume.pdf');

  console.log('🖨️ Rendering print-optimized PDF package...');
  await page.pdf({
    path: pdfPathSrc,
    format: 'Letter',
    printBackground: true,
    margin: {
      top: '0.5in',
      right: '0.5in',
      bottom: '0.5in',
      left: '0.5in',
    },
  });

  // Copy to site dist
  fs.copyFileSync(pdfPathSrc, pdfPathDist);

  console.log(`✅ PDF Resume exported successfully:`);
  console.log(`   - Source: ${pdfPathSrc}`);
  console.log(`   - Dist:   ${pdfPathDist}`);

  await browser.close();
}

generatePDF().catch((err) => {
  console.error('❌ PDF generation failed:', err);
  process.exit(1);
});
