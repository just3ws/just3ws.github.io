const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const https = require('https');

const targets = [
  { id: 'chicago-code-camp', domain: 'chicagocodecamp.com' },
  { id: 'ugtastic', domain: 'ugtastic.com' },
  { id: 'ugl-st', domain: 'ugl.st' }
];

async function getTimestamps(domain) {
  return new Promise((resolve, reject) => {
    const url = `https://web.archive.org/cdx/search/cdx?url=${domain}&output=json&filter=statuscode:200&collapse=timestamp:6`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json.slice(1).map(row => row[1]));
        } catch (e) {
          resolve([]);
        }
      });
    }).on('error', reject);
  });
}

async function capture() {
  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();

  const outputDir = path.join(__dirname, '..', 'assets', 'images', 'portfolio', 'completionist');
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

  for (const target of targets) {
    console.log(`\n🔭 Discovery for ${target.id}...`);
    const timestamps = await getTimestamps(target.domain);
    console.log(`  Found ${timestamps.length} potential monthly snapshots.`);

    // Limit to 24 per project for this run to avoid infinite loop, 
    // picking a spread if there are many.
    const step = Math.max(1, Math.floor(timestamps.length / 24));
    const curated = timestamps.filter((_, i) => i % step === 0).slice(0, 24);

    console.log(`  Targeting ${curated.length} snapshots for capture...`);

    for (const ts of curated) {
      const filename = `${target.id}-${ts}.png`;
      const fullPath = path.join(outputDir, filename);
      if (fs.existsSync(fullPath)) continue;

      const url = `https://web.archive.org/web/${ts}/${target.domain}`;
      console.log(`  📸 Capturing ${ts}...`);

      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
        await page.evaluate(() => {
          ['#wm-ipp-base', '#wm-ipp', '.wm-shaded-border'].forEach(s => {
            const el = document.querySelector(s);
            if (el) el.style.display = 'none';
          });
          document.body.style.paddingTop = '0';
        });
        await page.waitForTimeout(2000);
        await page.screenshot({ path: fullPath });
      } catch (err) {
        console.error(`  ✕ Error ${ts}: ${err.message.split('\n')[0]}`);
      }
    }
  }

  await browser.close();
}

capture().catch(console.error);
