// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Site Layout and Aesthetics', () => {
  test('Home page renders correctly', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.goto('/home/');
    await expect(page).toHaveTitle(/Mike Hall \| Principal Software Engineer/);
    await expect(page.locator('.leadership-eyebrow').first()).toHaveText('Principal Software Engineer');
    await expect(page.locator('h1')).toContainText('complex software systems');
    await expect(page.locator('main')).not.toContainText('Director of Engineering');
    await expect(page.locator('main')).toContainText('Phalanx Duel');
    await expect(page.locator('main a[href="/panoramic-view/"]')).toHaveCount(0);
    const homeHeadingSize = Number.parseFloat(await page.locator('h1').evaluate((element) => getComputedStyle(element).fontSize));
    expect(homeHeadingSize).toBeLessThanOrEqual(60);
    const heroActions = page.locator('.leadership-hero .leadership-actions');
    await expect(heroActions.getByRole('link', { name: 'Read my résumé' })).toHaveAttribute('href', '/');
    await expect(heroActions.getByRole('link', { name: 'See selected work' })).toHaveAttribute('href', '/portfolio/');
    await expect(page.getByRole('link', { name: 'Complete history' })).toHaveAttribute('href', '/history/');
    await expect(page.getByRole('link', { name: 'Contact Mike' })).toHaveAttribute('href', '/contact/');

    // Screenshot for visual audit
    await page.screenshot({ path: 'tmp/screenshots/home.png', fullPage: true });

    // Check header visibility and sticky behavior
    const header = page.locator('header.site-header');
    await expect(header).toBeVisible();
    
    // Check nav avatar
    const avatar = page.locator('.site-nav-avatar');
    await expect(avatar).toBeVisible();
    
    // Validate avatar dimensions (ensuring it's not collapsed or oversized)
    const box = await avatar.boundingBox();
    expect(box.width).toBeGreaterThan(30);
    expect(box.width).toBeLessThan(55);
    expect(box.height).toBe(box.width); // Should be square/circular

    await page.getByRole('button', { name: 'Toggle Kanagawa Wave Theme' }).click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'kanagawa');
    const themedSurface = await page.locator('.leadership-pattern').evaluate((element) => getComputedStyle(element).backgroundColor);
    expect(themedSurface).toBe('rgb(42, 42, 55)');
    await page.screenshot({ path: 'tmp/screenshots/home-kanagawa.png', fullPage: true });
  });

  test('Resume renders correctly and is professional', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.goto('/');
    await expect(page.locator('h1')).toContainText('Mike Hall');
    await expect(page.locator('.resume-header .title')).toHaveText('Principal Software Engineer');
    await expect(page.locator('#summary')).toContainText('discovers, maps, and modernizes critical software assets');
    await expect(page.locator('.resume-intro')).toBeVisible();
    await expect(page.locator('.resume-focus-index li')).toHaveCount(4);
    await expect(page.locator('.resume-focus-index')).toContainText('Technical Leadership');
    await expect(page.locator('.resume-quick-exports')).toHaveCount(0);
    await expect(page.locator('#experience .position').first()).toContainText('Development Manager');
    await expect(page.locator('#experience .position').first()).toContainText('founder transition');
    
    // Capture full page screenshot for manual review
    await page.screenshot({ path: 'tmp/screenshots/resume.png', fullPage: true });
    
    // 1. Verify Achievement Highlights
    const achievementSection = page.locator('.achievement-highlights');
    await expect(achievementSection.first()).toBeVisible();

    // 2. Verify Skills Dashboard
    const skillsDashboard = page.locator('.skills-dashboard');
    await expect(skillsDashboard).toBeVisible();
    
    const categoryLabel = page.locator('.skills-category .category-name');
    await expect(categoryLabel.first()).toBeVisible();
    await expect(categoryLabel.first()).toContainText(/Technical Leadership/i);

    const skillItem = page.locator('.skills-list li');
    await expect(skillItem.first()).toBeVisible();

    const fullTimeline = page.getByRole('link', { name: 'Full Timeline' });
    await expect(fullTimeline).toHaveAttribute('href', '/history/');
  });

  test('Resume remains readable at mobile width', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto('/');

    const resume = page.locator('.ats-resume-content');
    await expect(resume).toBeVisible();
    await page.screenshot({ path: 'tmp/screenshots/mobile-resume-top.png' });
    const metrics = await resume.evaluate((element) => ({
      scrollWidth: element.scrollWidth,
      clientWidth: element.clientWidth,
    }));
    expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth + 1);

    await page.screenshot({ path: 'tmp/screenshots/mobile-resume.png', fullPage: true });
  });

  test('Full history uses the shared resume system', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.goto('/history/');

    await expect(page.locator('.resume-intro')).toBeVisible();
    await expect(page.locator('.resume-header .title')).toHaveText('Principal Software Engineer');
    await expect(page.locator('.resume-focus-index li')).toHaveCount(4);
    await expect(page.getByRole('heading', { name: 'Full Career History' })).toBeVisible();
    expect(await page.locator('#experience .position').count()).toBeGreaterThan(10);
    await page.screenshot({ path: 'tmp/screenshots/history.png', fullPage: true });
  });

  test('Full history remains readable at mobile width', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await page.goto('/history/');

    const history = page.locator('.resume-history-content');
    await expect(history).toBeVisible();
    const metrics = await history.evaluate((element) => ({
      scrollWidth: element.scrollWidth,
      clientWidth: element.clientWidth,
    }));
    expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth + 100);
    await page.screenshot({ path: 'tmp/screenshots/mobile-history-top.png' });
    await page.screenshot({ path: 'tmp/screenshots/mobile-history.png', fullPage: true });
  });

  test('Current position detail is linked from the resume', async ({ page }) => {
    await page.goto('/');
    const currentRole = page.locator('#experience .position').first().getByRole('link', { name: 'Development Manager' });
    await expect(currentRole).toHaveAttribute('href', '/resume/positions/emr-bear/');
    await currentRole.click();
    await expect(page).toHaveURL(/\/resume\/positions\/emr-bear\/$/);
    await expect(page.locator('main')).toContainText('Role & Career Context');
  });

  test.skip('Panoramic View explains the method without exposing implementation names', async ({ page }) => {
    await page.goto('/panoramic-view/');

    await expect(page).toHaveTitle(/Panoramic View/);
    await expect(page.locator('h1')).toHaveText('Panoramic View');
    await expect(page.getByRole('heading', { name: 'A journey across. A system wave down and back.' })).toBeVisible();
    await expect(page.getByRole('heading', { name: 'The Simple Loop of Discovery' })).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Where vision meets reality.' })).toBeVisible();
    await expect(page.locator('.pv-premise')).toContainText('implemented domain model');
    await expect(page.locator('.pv-premise')).toContainText('where is the delta?');
    await expect(page.locator('.pv-actor-scope')).toContainText('Rails platforms were the flagship proving ground.');
    await expect(page.locator('.pv-actor-scope')).toContainText('agentic AI system');
    await expect(page.getByText('Legacy System Modernization', { exact: true })).toBeVisible();
    await expect(page.getByText('Cross-System Integration & Cartography', { exact: true })).toBeVisible();
    await expect(page.locator('main')).not.toContainText('EMR-Bear');
    await expect(page.locator('main')).not.toContainText('OneMain');

    const diagram = page.getByRole('img', { name: 'Panoramic View journey and system-wave model' });
    await expect(diagram).toBeVisible();

    await page.screenshot({ path: 'tmp/screenshots/panoramic-view.png', fullPage: true });
  });

  test.skip('Panoramic View remains readable at mobile width', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/panoramic-view/');

    const content = page.locator('.pv-page');
    await expect(content).toBeVisible();
    const metrics = await content.evaluate((element) => ({
      scrollWidth: element.scrollWidth,
      clientWidth: element.clientWidth,
    }));
    expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth + 1);

    await page.screenshot({ path: 'tmp/screenshots/mobile-panoramic-view.png', fullPage: true });
  });

  test('Taxonomy uses the professional palette in both themes', async ({ page }) => {
    await page.goto('/taxonomy/');

    await expect(page.locator('link[rel="stylesheet"][href^="/assets/css/site.css?v="]')).toHaveCount(1);
    const title = page.getByRole('heading', { name: 'Follow the people. Trace the ideas.' });
    await expect(title).toBeVisible();
    await expect(page.locator('main')).toContainText('Not a leaderboard. Not a social graph.');
    await expect(page.locator('main')).toContainText('200+');
    await expect(page.getByRole('heading', { name: 'Prefer names to constellations?' })).toBeVisible();
    await expect(page.locator('#graph-network canvas')).toBeVisible();
    await expect(page.locator('#taxonomyTableBody tr').first()).toBeVisible();

    const defaultPresentation = await page.evaluate(() => ({
      title: getComputedStyle(document.querySelector('.intel-title')).color,
      ledgerRadius: getComputedStyle(document.querySelector('.stat-card')).borderRadius,
    }));
    expect(defaultPresentation).toEqual({
      title: 'rgb(37, 43, 43)',
      ledgerRadius: '0px',
    });
    await page.screenshot({ path: 'tmp/screenshots/taxonomy.png', fullPage: true });

    const table = page.locator('#taxonomyTable');
    const firstEntityLink = page.locator('#taxonomyTableBody').getByRole('link').first();
    await expect(firstEntityLink).toBeVisible();
    const tableMetrics = await table.evaluate((element) => ({
      scrollWidth: element.parentElement.scrollWidth,
      clientWidth: element.parentElement.clientWidth,
    }));
    expect(tableMetrics.scrollWidth).toBeLessThanOrEqual(tableMetrics.clientWidth + 1);

    const search = page.getByRole('textbox', { name: 'Search the entity index' });
    await search.fill('Ruby on Rails');
    await expect(page.locator('#taxonomyTableBody')).toContainText('Ruby on Rails');
    await expect(page.locator('#taxonomyTableBody tr')).toHaveCount(1);

    await search.focus();
    const focusStyle = await search.evaluate((element) => ({
      outlineStyle: getComputedStyle(element).outlineStyle,
      outlineWidth: getComputedStyle(element).outlineWidth,
    }));
    expect(focusStyle.outlineStyle).toBe('solid');
    expect(focusStyle.outlineWidth).not.toBe('0px');

    await page.getByRole('combobox', { name: 'Narrow the field' }).selectOption('Conference');
    await expect(page.getByRole('combobox', { name: 'Narrow the field' })).toHaveValue('Conference');
    await search.fill('');
    await page.getByRole('combobox', { name: 'Narrow the field' }).selectOption('ALL');

    await page.getByRole('button', { name: 'Toggle Kanagawa Wave Theme' }).click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'kanagawa');

    const kanagawaColors = await page.evaluate(() => ({
      title: getComputedStyle(document.querySelector('.intel-title')).color,
      page: getComputedStyle(document.querySelector('.taxonomy-page')).backgroundColor,
      canvas: getComputedStyle(document.querySelector('.graph-canvas-container')).backgroundColor,
    }));
    expect(kanagawaColors).toEqual({
      title: 'rgb(220, 215, 186)',
      page: 'rgb(31, 31, 40)',
      canvas: 'rgb(22, 22, 29)',
    });
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: 'tmp/screenshots/taxonomy-kanagawa.png', fullPage: true });
  });

  test('Taxonomy remains bounded and readable at mobile width', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/taxonomy/');

    await expect(page.locator('.taxonomy-page')).toBeVisible();
    await expect(page.locator('#graph-network canvas')).toBeVisible();
    const viewportMetrics = await page.evaluate(() => ({
      viewportWidth: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
    }));
    expect(viewportMetrics.documentWidth).toBeLessThanOrEqual(viewportMetrics.viewportWidth + 1);
    await page.screenshot({ path: 'tmp/screenshots/mobile-taxonomy.png', fullPage: true });

    await page.getByRole('button', { name: 'Toggle Kanagawa Wave Theme' }).click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'kanagawa');
    const kanagawaMetrics = await page.evaluate(() => ({
      viewportWidth: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
    }));
    expect(kanagawaMetrics.documentWidth).toBeLessThanOrEqual(kanagawaMetrics.viewportWidth + 1);
    await page.screenshot({ path: 'tmp/screenshots/mobile-taxonomy-kanagawa.png', fullPage: true });
  });

  test('Timeline uses the editorial palette and preserves era filtering', async ({ page }) => {
    await page.goto('/timeline/');

    const title = page.getByRole('heading', { name: 'Interactive Historical Timeline' });
    await expect(title).toBeVisible();
    await expect(page.locator('.timeline-era-block').first()).toBeVisible();

    const defaultColors = await page.evaluate(() => ({
      title: getComputedStyle(document.querySelector('.timeline-page .intel-title')).color,
      accent: getComputedStyle(document.querySelector('.timeline-page')).getPropertyValue('--timeline-accent').trim(),
      heroBorder: getComputedStyle(document.querySelector('.timeline-page .intel-hero')).borderTopColor,
    }));
    expect(defaultColors).toEqual({
      title: 'rgb(37, 43, 43)',
      accent: '#0f7773',
      heroBorder: 'rgb(15, 119, 115)',
    });

    const railsEra = page.getByRole('button', { name: '2014: Rails Boom & GOTO' });
    await railsEra.click();
    await expect(page.locator('.timeline-era-block')).toHaveCount(1);
    await expect(page.locator('.era-title-display')).toContainText('Rails');

    const firstEraButton = page.getByRole('button', { name: 'All Eras (2009-2026)' });
    await firstEraButton.focus();
    const focusStyle = await firstEraButton.evaluate((element) => ({
      outlineStyle: getComputedStyle(element).outlineStyle,
      outlineWidth: getComputedStyle(element).outlineWidth,
    }));
    expect(focusStyle.outlineStyle).toBe('solid');
    expect(focusStyle.outlineWidth).not.toBe('0px');

    await page.getByRole('button', { name: 'Toggle Kanagawa Wave Theme' }).click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'kanagawa');
    const kanagawaTitle = await title.evaluate((element) => getComputedStyle(element).color);
    expect(kanagawaTitle).toBe('rgb(220, 215, 186)');
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: 'tmp/screenshots/timeline.png', fullPage: true });
  });

  test('Timeline remains bounded at mobile width in both themes', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/timeline/');

    const measure = () => page.evaluate(() => ({
      viewportWidth: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
    }));
    let metrics = await measure();
    expect(metrics.documentWidth).toBeLessThanOrEqual(metrics.viewportWidth + 1);
    await page.screenshot({ path: 'tmp/screenshots/mobile-timeline.png', fullPage: true });

    await page.getByRole('button', { name: 'Toggle Kanagawa Wave Theme' }).click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'kanagawa');
    metrics = await measure();
    expect(metrics.documentWidth).toBeLessThanOrEqual(metrics.viewportWidth + 1);
    await page.screenshot({ path: 'tmp/screenshots/mobile-timeline-kanagawa.png', fullPage: true });
  });

  test('Navigation is functional and consistent', async ({ page }) => {
    await page.goto('/home/');
    const resumeLink = page.locator('.site-nav-links a', { hasText: 'Resume' });
    await resumeLink.click();
    await expect(page).toHaveURL(/\/$/);
    
    const avatar = page.locator('.site-nav-avatar');
    await expect(avatar).toBeVisible();
  });

  test('Mobile responsiveness check', async ({ page }) => {
    // Set viewport to a typical mobile size
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/home/');
    
    // Header should adjust for mobile (vertical layout in my SCSS)
    const nav = page.locator('.site-nav');
    const navBox = await nav.boundingBox();
    
    // In mobile view, the nav-links should be visible and accessible
    const navLinks = page.locator('.site-nav-links');
    await expect(navLinks).toBeVisible();

    const viewportMetrics = await page.evaluate(() => ({
      viewportWidth: window.innerWidth,
      documentWidth: document.documentElement.scrollWidth,
    }));
    expect(viewportMetrics.documentWidth).toBeLessThanOrEqual(viewportMetrics.viewportWidth + 1);
    const homeHeadingSize = Number.parseFloat(await page.locator('h1').evaluate((element) => getComputedStyle(element).fontSize));
    expect(homeHeadingSize).toBeLessThanOrEqual(34);

    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({ path: 'tmp/screenshots/mobile-home.png' });

    const archiveDropdown = page.locator('.nav-dropdown', { hasText: 'Archive' });
    await archiveDropdown.locator('.dropdown-caret').click();
    const archiveMenu = archiveDropdown.locator('.nav-dropdown-menu');
    await expect(archiveMenu).toBeVisible();
    const menuBox = await archiveMenu.boundingBox();
    expect(menuBox.x).toBeGreaterThanOrEqual(0);
    expect(menuBox.x + menuBox.width).toBeLessThanOrEqual(375);

    await page.screenshot({ path: 'tmp/screenshots/mobile-home-menu.png' });
  });

  test('Engagements page renders correctly with availability status and service packages', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.goto('/engagements/');
    await expect(page).toHaveTitle(/Fractional Principal Engineering & Technical Advisory/);
    await expect(page.locator('h1')).toContainText('Fractional Principal Engineering');
    await expect(page.locator('.engagements-header')).toBeVisible();
    await expect(page.locator('.engagements-models')).toBeVisible();
    await page.screenshot({ path: 'tmp/screenshots/engagements.png', fullPage: true });
  });

  test('Executive pitch brief page renders cleanly with PDF download and email actions', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.goto('/exports/briefs/nextpatient-staff-software-engineer/');
    await expect(page.locator('h1')).toContainText('NextPatient');
    await expect(page.locator('.status-badge')).toHaveText('Executive Pitch Brief');
    await expect(page.getByRole('link', { name: 'Download PDF 📄' })).toHaveAttribute('href', /nextpatient-staff-software-engineer-executive-brief-mike-hall\.pdf$/);
    await expect(page.getByRole('link', { name: 'Email Recruiter ✉️' })).toBeVisible();
    await page.screenshot({ path: 'tmp/screenshots/brief-nextpatient.png', fullPage: true });

    await page.getByRole('button', { name: 'Toggle Kanagawa Wave Theme' }).click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'kanagawa');
    await page.screenshot({ path: 'tmp/screenshots/brief-nextpatient-kanagawa.png', fullPage: true });
  });

  test('Command Palette (Cmd+K) opens, filters sitemap index, and navigates', async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.goto('/home/');

    // Press Meta+K to open palette
    await page.keyboard.press('Meta+k');
    const backdrop = page.locator('#cmdPaletteBackdrop');
    await expect(backdrop).toHaveClass(/is-open/);

    // Type 'groupon position' in search input
    const input = page.locator('#cmdPaletteInput');
    await input.fill('groupon position');

    // Wait for Groupon position item to appear
    const item = page.locator('#cmdPaletteResults .cmd-item', { hasText: 'Groupon' }).first();
    await expect(item).toBeVisible();

    // Click item to navigate
    await item.click();
    await page.waitForURL(/\/resume\/positions\/groupon\//);
    await expect(page.locator('h1')).toContainText('Resume Position: Groupon');
  });
});
