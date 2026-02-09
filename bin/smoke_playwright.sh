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
SESSION="ci-seo-smoke"
PWCLI="npx --yes --package @playwright/cli playwright-cli --session ${SESSION}"

python3 -m http.server "$PORT" --directory _site >/tmp/playwright-smoke-server.log 2>&1 &
SERVER_PID="$!"
cleanup() {
  $PWCLI close >/dev/null 2>&1 || true
  if [ -n "${BROWSER_PID:-}" ] && kill -0 "$BROWSER_PID" >/dev/null 2>&1; then
    kill "$BROWSER_PID" >/dev/null 2>&1 || true
    wait "$BROWSER_PID" >/dev/null 2>&1 || true
  fi
  if kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  rm -rf .playwright-cli
}
trap cleanup EXIT

$PWCLI open "${BASE_URL}/" >/dev/null 2>&1 &
BROWSER_PID="$!"
sleep 2
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

assert_route "/"
assert_route "/history/"
assert_route "/writing/"
assert_route "/interviews/"
assert_route "/videos/"

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

assert_legacy_deprecated() {
  route="$1"
  $PWCLI goto "${BASE_URL}${route}" >/dev/null
  $PWCLI eval '() => {
    const canonical = document.querySelector("link[rel=\"canonical\"]")?.getAttribute("href");
    if (canonical !== "https://www.just3ws.com/") throw new Error(`unexpected canonical: ${canonical}`);
    const robots = (document.querySelector("meta[name=\"robots\"]")?.getAttribute("content") || "").toLowerCase();
    if (!robots.includes("noindex")) throw new Error(`legacy page missing noindex: ${robots}`);
    return true;
  }' >/dev/null
}

assert_root_seo
assert_legacy_deprecated "/history/"
assert_legacy_deprecated "/writing/"
assert_legacy_deprecated "/interviews/"
assert_legacy_deprecated "/videos/"

# Resume must always render correctly with expected identity markers.
$PWCLI goto "${BASE_URL}/" >/dev/null
$PWCLI eval '() => {
  const text = document.body.textContent || "";
  if (!text.includes("Mike Hall")) throw new Error("resume missing name");
  if (!text.includes("Staff Software Engineer")) throw new Error("resume missing role");
  return true;
}' >/dev/null
