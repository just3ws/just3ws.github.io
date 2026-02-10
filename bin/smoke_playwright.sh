#!/usr/bin/env sh
set -e

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required for Playwright smoke checks." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for local preview server." >&2
  exit 1
fi

PORT="${PORT:-4173}"
BASE_URL="http://127.0.0.1:${PORT}"
SESSION_BASE="${GITHUB_RUN_ID:-$$}"
SESSION="ci-seo-smoke-${SESSION_BASE}"
NPM_CACHE_DIR="${TMPDIR:-/tmp}/npm-cache-${SESSION}"
export npm_config_cache="${NPM_CACHE_DIR}"
PWCLI="npx --yes --package @playwright/cli playwright-cli --session ${SESSION}"

python3 -m http.server "$PORT" --directory _site >/tmp/playwright-smoke-server.log 2>&1 &
SERVER_PID="$!"
cleanup() {
  $PWCLI close >/dev/null 2>&1 || true
  if kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  rm -rf "${NPM_CACHE_DIR}"
  rm -rf .playwright-cli
}
trap cleanup EXIT

$PWCLI open "${BASE_URL}/" >/dev/null
$PWCLI goto "${BASE_URL}/" >/dev/null

assert_route() {
  route="$1"
  $PWCLI goto "${BASE_URL}${route}" >/dev/null
  $PWCLI eval '() => {
    const title = document.title && document.title.trim();
    if (!title) throw new Error("missing title");
    const h1 = document.querySelector("h1")?.textContent?.trim();
    if (!h1) throw new Error("missing h1");
    return { title, h1 };
  }' >/dev/null
}

published_routes="$(ruby -rrexml/document -e '
  doc = REXML::Document.new(File.read("_site/sitemap.xml"))
  routes = []
  doc.elements.each("urlset/url/loc") do |loc|
    path = loc.text.to_s.sub(%r{\Ahttps?://[^/]+}, "")
    path = "/" if path.empty?
    path = "#{path}/" unless path.end_with?("/")
    routes << path
  end
  puts routes.uniq.sort
')"

if [ -z "$published_routes" ]; then
  echo "No published routes discovered from _site/sitemap.xml" >&2
  exit 1
fi

echo "$published_routes" | while IFS= read -r route; do
  [ -z "$route" ] && continue
  assert_route "$route"
done

assert_root_seo() {
  $PWCLI goto "${BASE_URL}/" >/dev/null
  $PWCLI eval '() => {
    const canonical = document.querySelector("link[rel=\"canonical\"]")?.getAttribute("href");
    if (canonical !== "https://www.just3ws.com/") throw new Error(`unexpected root canonical: ${canonical}`);
    const robots = (document.querySelector("meta[name=\"robots\"]")?.getAttribute("content") || "").toLowerCase();
    if (!robots.includes("index") || robots.includes("noindex")) throw new Error(`unexpected root robots: ${robots}`);
    return true;
  }' >/dev/null
}

assert_home_seo() {
  $PWCLI goto "${BASE_URL}/home/" >/dev/null
  $PWCLI eval '() => {
    const canonical = document.querySelector("link[rel=\"canonical\"]")?.getAttribute("href");
    if (canonical !== "https://www.just3ws.com/home/") throw new Error(`unexpected home canonical: ${canonical}`);
    const robots = (document.querySelector("meta[name=\"robots\"]")?.getAttribute("content") || "").toLowerCase();
    if (!robots.includes("index") || robots.includes("noindex")) throw new Error(`unexpected home robots: ${robots}`);
    return true;
  }' >/dev/null
}

assert_semantic_a11y_contract() {
  route="$1"
  $PWCLI goto "${BASE_URL}${route}" >/dev/null
  $PWCLI eval "() => {
    const lang = (document.documentElement.getAttribute('lang') || '').trim();
    if (!lang) throw new Error('missing html[lang]');

    const mains = document.querySelectorAll('main');
    if (mains.length !== 1) throw new Error('expected exactly one <main>');

    const h1s = Array.from(document.querySelectorAll('h1')).map((el) => (el.textContent || '').trim()).filter(Boolean);
    if (h1s.length !== 1) throw new Error('expected exactly one non-empty <h1>');

    const skip = document.querySelector('a.skip-link');
    if (!skip) throw new Error('missing skip-link');
    if ((skip.getAttribute('href') || '').trim() !== '#main-content') throw new Error('skip-link href must target #main-content');
    if (!document.getElementById('main-content')) throw new Error('missing #main-content target');

    const unlabeledNav = document.querySelector('nav:not([aria-label]):not([aria-labelledby])');
    if (unlabeledNav) throw new Error('found nav without accessible label');

    const imagesMissingAlt = Array.from(document.querySelectorAll('img')).filter((img) => !img.hasAttribute('alt'));
    if (imagesMissingAlt.length > 0) throw new Error('found image missing alt attribute');

    return true;
  }" >/dev/null
}

assert_resume_structured_data() {
  $PWCLI goto "${BASE_URL}/" >/dev/null
  $PWCLI eval "() => {
    const jsonLd = Array.from(document.querySelectorAll('script[type=\"application/ld+json\"]'))
      .map((s) => s.textContent || '')
      .join('\\n');
    if (!jsonLd.includes('\"@type\":\"Person\"')) throw new Error('resume missing Person JSON-LD');
    return true;
  }" >/dev/null
}

assert_root_seo
assert_home_seo
assert_semantic_a11y_contract "/"
assert_semantic_a11y_contract "/home/"
assert_resume_structured_data

# Resume must always render correctly with expected identity markers.
$PWCLI goto "${BASE_URL}/" >/dev/null
$PWCLI eval '() => {
  const text = document.body.textContent || "";
  if (!text.includes("Mike Hall")) throw new Error("resume missing name");
  if (!text.includes("Staff Software Engineer")) throw new Error("resume missing role");
  return true;
}' >/dev/null
