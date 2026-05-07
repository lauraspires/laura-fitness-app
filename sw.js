const CACHE_NAME = 'health-hub-v13';
const STATIC_ASSETS = [
  '/health-hub/manifest.json',
  '/health-hub/icons/icon-192.png',
  '/health-hub/icons/icon-512.png'
];

// Install: pre-cache only static assets (not index.html)
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

// Activate: wipe all old caches immediately
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// Fetch strategy:
// - HTML (navigation): network first, fall back to cache
// - Everything else: cache first, fall back to network
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  if (!event.request.url.startsWith(self.location.origin)) return;

  const isNavigation = event.request.mode === 'navigate' ||
    event.request.url.includes('index.html') ||
    event.request.url.endsWith('/health-hub/') ||
    event.request.url.endsWith('/health-hub');

  if (isNavigation) {
    // Network first for HTML — always get the freshest version
    event.respondWith(
      fetch(event.request)
        .then(response => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
          return response;
        })
        .catch(() => caches.match(event.request))
    );
  } else {
    // Cache first for static assets
    event.respondWith(
      caches.match(event.request).then(cached => {
        if (cached) return cached;
        return fetch(event.request).then(response => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
          }
          return response;
        });
      })
    );
  }
});
