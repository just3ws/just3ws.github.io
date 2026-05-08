const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const targets = [
  {
    id: 'chicago-code-camp',
    domain: 'chicagocodecamp.com',
    timestamps: ["20090326085241","20090515202443","20090728010700","20090930010125","20091105092351","20100108183043","20100314180408","20100516112634","20100717212210","20110719170617"]
  },
  {
    id: 'ugtastic',
    domain: 'ugtastic.com',
    timestamps: ["20120414040704","20120616110405","20120717082432","20121101071521","20121203140904","20130204072611","20131001174806","20131104125527","20140313235944","20140414060409"]
  },
  {
    id: 'ugl-st',
    domain: 'ugl.st',
    timestamps: ["20140111160057", "20141217083739"]
  }
];

async function capture() {
  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();

  const outputDir = path.join(__dirname, '..', 'assets', 'images', 'portfolio', 'batch-3');
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

  for (const target of targets) {
    console.log(`Processing Batch 3 for ${target.id}...`);
    for (const ts of target.timestamps) {
      const url = `https://web.archive.org/web/${ts}/${target.domain}`;
      const filename = `${target.id}-${ts}.png`;
      const fullPath = path.join(outputDir, filename);

      if (fs.existsSync(fullPath)) continue;
      console.log(`  📸 Capturing ${ts}...`);

      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 90000 });
        await page.evaluate(() => {
          ['#wm-ipp-base', '#wm-ipp', '.wm-shaded-border'].forEach(s => {
            const el = document.querySelector(s);
            if (el) el.style.display = 'none';
          });
          document.body.style.paddingTop = '0';
        });
        await page.waitForTimeout(3000);
        await page.screenshot({ path: fullPath });
      } catch (err) {
        console.error(`  ✕ Failed ${ts}: ${err.message.split('\n')[0]}`);
      }
    }
  }

  await browser.close();
}

capture().catch(console.error);
