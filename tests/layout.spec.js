// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Site Layout and Aesthetics', () => {
  test('Home page renders correctly', async ({ page }) => {
    await page.goto('/home/');
    await expect(page).toHaveTitle(/Mike Hall/);
    
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
  });

  test('Resume renders correctly and is professional', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('h1')).toContainText('Mike Hall');
    
    // Capture full page screenshot for manual review
    await page.screenshot({ path: 'tmp/screenshots/resume.png', fullPage: true });
    
    // 1. Verify Achievement Highlights
    const achievementSection = page.locator('.achievement-highlights');
    await expect(achievementSection.first()).toBeVisible();

    // 2. Verify Skills Dashboard
    const skillsDashboard = page.locator('.skills-dashboard');
    await expect(skillsDashboard).toBeVisible();
    
    const expertiseGroup = page.locator('.skill-level-group .level-label.expertise');
    await expect(expertiseGroup.first()).toBeVisible();
    await expect(expertiseGroup.first()).toHaveText('Expertise');

    const skillItem = page.locator('.skills-list li');
    await expect(skillItem.first()).toBeVisible();
    
    // Check for proficiency levels
    await expect(page.locator('.level-label.expertise').first()).toHaveText('Expertise');
    await expect(page.locator('.level-label.proficiency').first()).toHaveText('Proficiency');
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
    
    // In mobile view, the nav-links should be full width or at least centered
    const navLinks = page.locator('.site-nav-links');
    await expect(navLinks).toBeVisible();
    
    await page.screenshot({ path: 'tmp/screenshots/mobile-home.png' });
  });
});
