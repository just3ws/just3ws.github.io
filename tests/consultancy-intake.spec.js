// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Consultancy Intake Lifecycle', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the root (the consultancy landing page)
    await page.goto('/');
  });

  test('Consultancy landing page is at root', async ({ page }) => {
    await expect(page).toHaveTitle(/Rails & Postgres Consultancy/);
    await expect(page.locator('h1')).toContainText("Your Rails system shouldn't be a haunted house.");
  });

  test('Intake form is correctly configured for Formspree', async ({ page }) => {
    const form = page.locator('form.intake-form');
    
    // Check Formspree endpoint
    await expect(form).toHaveAttribute('action', 'https://formspree.io/f/xaqvqrrw');
    await expect(form).toHaveAttribute('method', 'POST');
    await expect(form).toHaveAttribute('enctype', 'multipart/form-data');

    // Check hidden fields
    const honeypot = page.locator('input[name="_gotcha"]');
    await expect(honeypot).toBeHidden();
    
    const nextRedirect = page.locator('input[name="_next"]');
    await expect(nextRedirect).toHaveValue('https://www.just3ws.com/consultancy/thanks/');
  });

  test('Full form submission sends correct data', async ({ page }) => {
    // Fill out the form fields
    await page.selectOption('select[name="primary-pain-point"]', 'Slow Queries / Lock Contention');
    await page.fill('textarea[name="symptom-description"]', 'Our production database is experiencing high lock contention during checkout peaks.');
    
    // Mock files for upload
    await page.setInputFiles('input[name="schema-definition"]', {
      name: 'schema.rb',
      mimeType: 'text/plain',
      buffer: Buffer.from('create_table "users", force: :cascade do |t| ... end')
    });

    await page.fill('input[name="requested-start-date"]', '2026-06-01');
    await page.check('input[name="read-only-access-available"]');
    await page.fill('input[name="_replyto"]', 'founder@startup.com');

    // Intercept the POST request to Formspree
    let postData;
    await page.route('https://formspree.io/f/xaqvqrrw', async (route) => {
      const request = route.request();
      postData = request.postData();
      // Mock a successful response and redirect to the success page
      await route.fulfill({
        status: 302,
        headers: {
          'location': 'http://localhost:4173/consultancy/thanks/'
        }
      });
    });

    // Submit the form
    await page.click('button[type="submit"]');

    // Verify we arrived at the thanks page
    await expect(page).toHaveURL(/\/consultancy\/thanks\/$/);
    await expect(page.locator('h1')).toContainText('Intake Received.');

    // Verify the intercepted data (Basic check for presence of fields)
    expect(postData).toContain('primary-pain-point');
    expect(postData).toContain('Slow Queries / Lock Contention');
    expect(postData).toContain('founder@startup.com');
  });

  test('Success page renders correctly', async ({ page }) => {
    await page.goto('/consultancy/thanks/');
    await expect(page.locator('h1')).toContainText('Intake Received.');
    await expect(page.locator('.next-steps')).toBeVisible();
    
    const homeLink = page.locator('a', { hasText: 'Return to Home' });
    await expect(homeLink).toHaveAttribute('href', '/');
  });

  test('Resume footer has backlink to consultancy', async ({ page }) => {
    await page.goto('/resume/');
    const footerCTA = page.locator('.footer-cta');
    await expect(footerCTA).toBeVisible();
    await expect(footerCTA).toContainText('Need Rails/Postgres diagnostics?');
    
    const backlink = footerCTA.locator('a');
    await expect(backlink).toHaveAttribute('href', '/');
  });
});
