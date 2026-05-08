const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const targets = [
  {
    id: 'chicago-code-camp',
    domain: 'chicagocodecamp.com',
    // Expanded list of timestamps for wider spread
    timestamps: [
      '20090421015908', '20090602163755', '20090828081931', '20091025104349',
      '20100210083006', '20100617000653', '20110202180524', '20110618044602',
      '20111129043854', '20120415023527', '20120720233851', '20121006011522'
    ]
  },
  {
    id: 'ugtastic',
    domain: 'ugtastic.com',
    timestamps: [
      '20120516101641', '20120717082432', '20130104123545', '20130629083524',
      '20130831054519', '20131205192420', '20140205124846', '20140414060409',
      '20140616110016', '20140922113756', '20150104201752', '20150415064144'
    ]
  },
  {
    id: 'ugl-st',
    domain: 'ugl.st',
    timestamps: [
      '20140111160057', '20141217083739', '20141222063128'
    ]
  }
];

async function capture() {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  const outputDir = path.join(__dirname, '..', 'assets', 'images', 'portfolio', 'batch-2');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  for (const target of targets) {
    console.log(`Processing Batch 2 for ${target.id}...`);
    
    for (const ts of target.timestamps) {
      const url = `https://web.archive.org/web/${ts}/${target.domain}`;
      const filename = `${target.id}-${ts}.png`;
      const fullPath = path.join(outputDir, filename);

      if (fs.existsSync(fullPath)) {
        console.log(`  Skipping ${ts} (already exists)`);
        continue;
      }

      console.log(`  Capturing ${url}...`);

      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 90000 });
        
        // Advanced cleanup for Wayback toolbar
        await page.evaluate(() => {
          const selectors = ['#wm-ipp-base', '#wm-ipp-print', '.wm-shaded-border', '#wm-ipp'];
          selectors.forEach(s => {
            const el = document.querySelector(s);
            if (el) el.style.display = 'none';
          });
          document.body.style.paddingTop = '0';
        });

        await page.waitForTimeout(3000);
        await page.screenshot({ path: fullPath });
        console.log(`  ✓ Saved to ${filename}`);
      } catch (err) {
        console.error(`  ✕ Failed to capture ${ts}: ${err.message}`);
      }
    }
  }

  await browser.close();
  console.log('\nBatch 2 Capture Complete. Images saved in assets/images/portfolio/batch-2/');
}

capture().catch(err => {
  console.error(err);
  process.exit(1);
});
