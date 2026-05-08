const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const targets = [
  {
    id: 'chicago-code-camp',
    domain: 'chicagocodecamp.com',
    timestamps: [
      '20090326085241', '20091206205549', '20100415112136', '20100818140356',
      '20110518024157', '20110819194523', '20120107113807', '20120503210642',
      '20120822010129', '20121228074319'
    ]
  },
  {
    id: 'ugtastic',
    domain: 'ugtastic.com',
    timestamps: [
      '20120414040704', '20121203140904', '20130307081827', '20130708045226',
      '20131104125527', '20140105115755', '20140515085029', '20141009011502',
      '20141205004313'
    ]
  },
  {
    id: 'ugl-st',
    domain: 'ugl.st',
    timestamps: [
      '20140111160057', '20141217083739'
    ]
  },
  {
    id: 'phalanx-duel',
    url: 'https://phalanxduel.com',
    isDirect: true
  }
];

async function capture() {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  const outputDir = path.join(__dirname, '..', 'assets', 'images', 'portfolio');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  for (const target of targets) {
    console.log(`Processing ${target.id}...`);
    
    if (target.isDirect) {
      await page.goto(target.url, { waitUntil: 'networkidle' });
      await page.screenshot({ path: path.join(outputDir, `${target.id}.png`) });
      continue;
    }

    for (let i = 0; i < target.timestamps.length; i++) {
      const ts = target.timestamps[i];
      const url = `https://web.archive.org/web/${ts}/${target.domain}`;
      console.log(`  Capturing ${url}...`);

      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });
        
        // Hide Wayback toolbar and some common noise
        await page.addStyleTag({
          content: `
            #wm-ipp-base, #wm-ipp-print, .wm-shaded-border { display: none !important; }
            body { padding-top: 0 !important; }
          `
        });

        // Wait a bit for images to load within the archive
        await page.waitForTimeout(2000);

        const filename = `${target.id}-${ts}.png`;
        await page.screenshot({ path: path.join(outputDir, filename) });
      } catch (err) {
        console.error(`  Failed to capture ${ts}: ${err.message}`);
      }
    }
  }

  await browser.close();
}

capture().catch(err => {
  console.error(err);
  process.exit(1);
});
