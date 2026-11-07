// Retired BoloBit build (April 2026). This file replaces that build's entry script.
// A browser that still has the April page cached loads it: refresh the cached page
// and reload once, so the visitor lands on the current site.
(() => {
  const KEY = 'bolobit-retired-build-reloaded';
  let first = false;
  try { first = !sessionStorage.getItem(KEY); sessionStorage.setItem(KEY, '1'); } catch { first = false; }
  if (!first) {
    const root = document.getElementById('root') || document.body;
    root.textContent = 'BoloBit has been updated. Please refresh this page.';
    return;
  }
  fetch(location.href, { cache: 'reload', credentials: 'same-origin' })
    .catch(() => {})
    .finally(() => location.reload());
})();
