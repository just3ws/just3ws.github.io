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

// Parse CLI arguments
function parseArgs() {
  const args = process.argv.slice(2);
  let destDir = null;
  let showHelp = false;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--dest' || args[i] === '-d') {
      destDir = args[++i];
    } else if (args[i] === '--help' || args[i] === '-h') {
      showHelp = true;
    } else if (!args[i].startsWith('-')) {
      destDir = args[i];
    }
  }

  return { destDir, showHelp };
}

const { destDir: customDestDir, showHelp } = parseArgs();

if (showHelp) {
  console.log(`
Usage: node bin/generate_pdf_resume.js [options] [destination_dir]

Generates print-optimized vector PDF resumes for all archetypes
and exports them to $HOME/Desktop/resumes by default.

Options:
  -d, --dest <dir>   Target directory for desktop resume PDFs
                     (default: $HOME/Desktop/resumes)
  -h, --help         Show this help message
`);
  process.exit(0);
}

const DEFAULT_DESKTOP_RESUMES_DIR = process.env.DESKTOP_RESUMES_DIR ||
  path.join(process.env.HOME || '/Users/mike', 'Desktop', 'resumes');
const DESKTOP_RESUMES_DIR = customDestDir ? path.resolve(customDestDir) : DEFAULT_DESKTOP_RESUMES_DIR;
const LEGACY_DESKTOP_DIR = path.join(process.env.HOME || '/Users/mike', 'Desktop');

const RESUME_TARGETS = [
  {
    slug: 'resume',
    path: '/resume.html',
    pdfName: 'resume.pdf',
    isCanonical: true,
    desktopFriendlyName: 'Mike Hall - Staff Software Engineer Resume.pdf'
  },
  {
    slug: 'mike-hall-staff-systems-architect',
    path: '/resumes/mike-hall-staff-systems-architect/',
    desktopFriendlyName: 'Mike Hall - Staff Systems Architect & Software Engineer Resume.pdf'
  },
  {
    slug: 'mike-hall-senior-ruby-rails-contractor',
    path: '/resumes/mike-hall-senior-ruby-rails-contractor/',
    desktopFriendlyName: 'Mike Hall - Senior & Lead Software Engineer, Ruby on Rails Resume.pdf'
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
  },
  {
    slug: 'ats-import-resume',
    pdfName: 'ats-import-resume.pdf',
    isAts: true,
    fileSrc: path.join(EXPORTS_RESUMES_SRC, 'ats-import-resume.html'),
    textSrc: path.join(EXPORTS_RESUMES_SRC, 'ats-import-resume.txt'),
    desktopFriendlyName: 'Mike Hall - Resume (ATS Import Autopopulate).pdf',
    desktopTextFriendlyName: 'Mike Hall - Resume (ATS Import Autopopulate).txt'
  }
];

async function generatePDFs() {
  console.log('📄 Launching Google Chrome for PDF generation...');
  // Prefer Playwright's pinned browser so PDF output stays reproducible across
  // local Chrome upgrades and avoids coupling generation to a GUI install.
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();

  // Ensure directories exist (mkdir -p)
  [EXPORTS_SRC_DIR, EXPORTS_DIST_DIR, EXPORTS_RESUMES_SRC, EXPORTS_RESUMES_DIST, DESKTOP_RESUMES_DIR].forEach(dir => {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  });

  for (const target of RESUME_TARGETS) {
    const page = await context.newPage();

    if (target.isAts) {
      const atsUrl = `file://${target.fileSrc}`;
      console.log(`🌐 Loading ATS import template from ${atsUrl}...`);
      await page.goto(atsUrl, { waitUntil: 'load', timeout: 15000 });
    } else {
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
    }

    const pdfName = target.pdfName || `${target.slug}-resume.pdf`;
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
      if (pdfPathSrc !== canonicalSrc) {
        fs.copyFileSync(pdfPathSrc, canonicalSrc);
      }
      if (pdfPathDist !== canonicalDist) {
        fs.copyFileSync(pdfPathSrc, canonicalDist);
      }
      const genericLegacyDesktop = path.join(LEGACY_DESKTOP_DIR, 'resume.pdf');
      if (fs.existsSync(genericLegacyDesktop)) {
        try { fs.unlinkSync(genericLegacyDesktop); } catch (e) {}
      }
    }

    // Copy to Desktop/resumes with human-friendly title
    if (target.desktopFriendlyName) {
      const desktopDest = path.join(DESKTOP_RESUMES_DIR, target.desktopFriendlyName);
      fs.copyFileSync(pdfPathSrc, desktopDest);
      console.log(`   - Desktop Resumes (PDF): ${desktopDest}`);

      // If accompanied by a dedicated plaintext ATS file, copy to Desktop/resumes as well
      if (target.textSrc && target.desktopTextFriendlyName && fs.existsSync(target.textSrc)) {
        const textDest = path.join(DESKTOP_RESUMES_DIR, target.desktopTextFriendlyName);
        fs.copyFileSync(target.textSrc, textDest);
        console.log(`   - Desktop Resumes (TXT): ${textDest}`);
      }

      // Clean up legacy loose file on Desktop root if present to keep desktop tidy
      if (DESKTOP_RESUMES_DIR !== LEGACY_DESKTOP_DIR && fs.existsSync(LEGACY_DESKTOP_DIR)) {
        const legacyFile = path.join(LEGACY_DESKTOP_DIR, target.desktopFriendlyName);
        if (fs.existsSync(legacyFile)) {
          try {
            fs.unlinkSync(legacyFile);
            console.log(`   - Cleaned root desktop duplicate: ${legacyFile}`);
          } catch (e) {}
        }
      }
    }

    console.log(`✅ ${target.slug} PDF exported successfully:`);
    console.log(`   - Named Slug:  ${pdfPathSrc}`);
    console.log(`   - Site Dist:   ${pdfPathDist}`);

    await page.close();
  }

  await browser.close();
  console.log(`\n🎉 All resume PDFs rendered and exported cleanly to ${DESKTOP_RESUMES_DIR}`);
}

generatePDFs().catch((err) => {
  console.error('❌ PDF generation failed:', err);
  process.exit(1);
});
