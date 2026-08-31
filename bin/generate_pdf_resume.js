#!/usr/bin/env node

/**
 * bin/generate_pdf_resume.js
 * Generates print-optimized vector PDF resume packages for all archetypes
 * and the canonical resume from the installed local site.
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const SITE_DIR = path.join(ROOT_DIR, '_site');
const EXPORTS_SRC_DIR = path.join(ROOT_DIR, 'exports');
const EXPORTS_DIST_DIR = path.join(SITE_DIR, 'exports');
const EXPORTS_RESUMES_SRC = path.join(EXPORTS_SRC_DIR, 'resumes');
const EXPORTS_RESUMES_DIST = path.join(EXPORTS_DIST_DIR, 'resumes');
const DESKTOP_DIR = '/Users/mike/Desktop';

const RESUME_TARGETS = [
  {
    slug: 'mike-hall-principal-software-engineer',
    path: '/resumes/mike-hall-principal-software-engineer/',
    isCanonical: true,
    desktopFriendlyName: 'Mike Hall - Principal Systems Architect & Software Engineer Resume.pdf'
  },
  {
    slug: 'mike-hall-senior-ruby-rails-contractor',
    path: '/resumes/mike-hall-senior-ruby-rails-contractor/',
    desktopFriendlyName: 'Mike Hall - Senior _ Lead Ruby on Rails Developer (Contract _ High-Velocity IC).pdf'
  },
  {
    slug: 'mike-hall-staff-platform-lead',
    path: '/resumes/mike-hall-staff-platform-lead/',
    desktopFriendlyName: 'Mike Hall - Staff Platform & Enablement Lead Resume.pdf'
  },
  {
    slug: 'mike-hall-founding-staff-engineer',
    path: '/resumes/mike-hall-founding-staff-engineer/',
    desktopFriendlyName: 'Mike Hall - Founding Staff Engineer (AI & 0-to-1) Resume.pdf'
  },
  {
    slug: 'mike-hall-observability-resilience-specialist',
    path: '/resumes/mike-hall-observability-resilience-specialist/',
    desktopFriendlyName: 'Mike Hall - Staff Observability & Resilience Architect Resume.pdf'
  }
];

async function generatePDFs() {
  console.log('📄 Launching Google Chrome for PDF generation...');
  const launchOptions = { headless: true };
  if (fs.existsSync('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome')) {
    launchOptions.executablePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  }
  const browser = await chromium.launch(launchOptions);
  const context = await browser.newContext();

  // Ensure directories exist
  [EXPORTS_SRC_DIR, EXPORTS_DIST_DIR, EXPORTS_RESUMES_SRC, EXPORTS_RESUMES_DIST].forEach(dir => {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  });

  for (const target of RESUME_TARGETS) {
    const page = await context.newPage();
    const localUrl = `https://just3ws.localhost${target.path}`;
    const fileUrl = `file://${path.join(SITE_DIR, target.path, 'index.html')}`;

    try {
      console.log(`🌐 Navigating to ${localUrl}...`);
      await page.goto(localUrl, { waitUntil: 'networkidle', timeout: 15000 });
      await page.waitForSelector('.resume-intro', { timeout: 5000 });
    } catch (err) {
      console.warn(`⚠️ Local Nginx fallback to local _site file: ${err.message}`);
      await page.goto(fileUrl, { waitUntil: 'networkidle', timeout: 15000 });
      await page.waitForSelector('.resume-intro', { timeout: 5000 });
    }

    const pdfName = `${target.slug}-resume.pdf`;
    const pdfPathSrc = path.join(EXPORTS_SRC_DIR, pdfName);
    const pdfPathDist = path.join(EXPORTS_DIST_DIR, pdfName);
    const pdfPathArchetypeSrc = path.join(EXPORTS_RESUMES_SRC, `${target.slug}.pdf`);
    const pdfPathArchetypeDist = path.join(EXPORTS_RESUMES_DIST, `${target.slug}.pdf`);

    console.log(`🖨️ Rendering vector PDF package for ${target.slug}...`);
    await page.pdf({
      path: pdfPathSrc,
      format: 'Letter',
      printBackground: true,
      margin: {
        top: '0.3in',
        right: '0.3in',
        bottom: '0.3in',
        left: '0.3in',
      },
    });

    // Copy to site dist and archetype exports folder
    fs.copyFileSync(pdfPathSrc, pdfPathDist);
    fs.copyFileSync(pdfPathSrc, pdfPathArchetypeSrc);
    fs.copyFileSync(pdfPathSrc, pdfPathArchetypeDist);

    // If canonical, keep exports/resume.pdf for internal backward compatibility
    if (target.isCanonical) {
      const canonicalSrc = path.join(EXPORTS_SRC_DIR, 'resume.pdf');
      const canonicalDist = path.join(EXPORTS_DIST_DIR, 'resume.pdf');
      fs.copyFileSync(pdfPathSrc, canonicalSrc);
      fs.copyFileSync(pdfPathSrc, canonicalDist);
      const genericDesktop = path.join(DESKTOP_DIR, 'resume.pdf');
      if (fs.existsSync(genericDesktop)) {
        try { fs.unlinkSync(genericDesktop); } catch (e) {}
      }
    }

    // Copy to Desktop with human-friendly title
    if (fs.existsSync(DESKTOP_DIR) && target.desktopFriendlyName) {
      const desktopDest = path.join(DESKTOP_DIR, target.desktopFriendlyName);
      fs.copyFileSync(pdfPathSrc, desktopDest);
      console.log(`   - Desktop:     ${desktopDest}`);
    }

    console.log(`✅ ${target.slug} PDF exported successfully:`);
    console.log(`   - Named Slug:  ${pdfPathSrc}`);
    console.log(`   - Site Dist:   ${pdfPathDist}`);

    await page.close();
  }

  await browser.close();
  console.log('\n🎉 All resume PDFs rendered and exported cleanly.');
}

generatePDFs().catch((err) => {
  console.error('❌ PDF generation failed:', err);
  process.exit(1);
});

