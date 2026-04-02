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
    expect(box.width).toBeGreaterThan(20);
    expect(box.width).toBeLessThan(40);
    expect(box.height).toBe(box.width); // Should be square/circular
  });

  test('Resume renders correctly and is professional', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('h1')).toContainText('Mike Hall');
    
    await page.screenshot({ path: 'tmp/screenshots/resume.png', fullPage: true });
    
    // Check for achievement highlights
    const achievements = page.locator('.achievement-highlights');
    await expect(achievements.first()).toBeVisible();
    
    // Check for impact badges
    const impactBadge = page.locator('.achievement-meta.impact');
    if (await impactBadge.count() > 0) {
      await expect(impactBadge.first()).toBeVisible();
    }
  });

  test('Navigation is functional and consistent', async ({ page }) => {
    await page.goto('/home/');
    const resumeLink = page.locator('.site-nav-links a', { hasText: 'Resume' });
    await resumeLink.click();
    await expect(page).toHaveURL(/\/$/);
    
    const avatar = page.locator('.site-nav-avatar');
    await expect(avatar).toBeVisible();
  });
});
